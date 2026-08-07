import { Request } from "express";
import { JwtPayload } from "jsonwebtoken";
import { pool } from "../config/dp";
import crypto from "crypto";
import bcrypt from "bcrypt";
import { AuthRequest } from "../middleware/protect";
import {
  hashTestLoginOtp,
  isTestLoginPhone,
  normalizeQatarPhone,
  TEST_LOGIN_OTP,
} from "./testAuth";

/** App accounts that can moderate any listing (same IDs used in the mobile UI). */
const STAFF_USER_IDS = new Set([
  "801ae98c-66a3-40b6-a34b-9192d248636f",
  "9d341dfe-7237-44fa-8eb2-fca783a67306",
]);

export type AuthActor = {
  userId?: string;
  adminId?: string;
};

export function getAuthActor(req: Request): AuthActor {
  const user = (req as AuthRequest).user;
  if (!user || typeof user === "string") return {};
  const payload = user as JwtPayload & {
    user_id?: string;
    admin_id?: string;
  };
  return {
    userId: typeof payload.user_id === "string" ? payload.user_id : undefined,
    adminId: typeof payload.admin_id === "string" ? payload.admin_id : undefined,
  };
}

export const getUserByPhone = async (user_phone: string) => {
  try {
    const query = "SELECT * FROM users WHERE user_phone = $1";
    const values = [user_phone];
    const result = await pool.query(query, values);
    if ((result.rowCount ?? 0) > 0) {
      return result.rows[0];
    } else {
      return null;
    }
  } catch (err) {
    throw err;
  }
};

export const isAdminUser = async (userId: string): Promise<boolean> => {
  try {
    const result = await pool.query(
      "SELECT admin_id FROM admins WHERE admin_id = $1",
      [userId]
    );
    return (result.rowCount ?? 0) > 0;
  } catch {
    return false;
  }
};

/** True for admins table JWT or known staff app users. */
export async function canModeratePosts(actor: AuthActor): Promise<boolean> {
  if (actor.adminId && (await isAdminUser(actor.adminId))) return true;
  if (actor.userId && STAFF_USER_IDS.has(actor.userId)) return true;
  if (actor.userId && (await isAdminUser(actor.userId))) return true;
  return false;
}

function formatPhoneForWhatsAppNode(phoneDigits: string): string {
  const format = (process.env.WHATSAPP_NODE_PHONE_FORMAT || "DIGITS").toUpperCase();
  if (format === "E164") {
    return phoneDigits.startsWith("+") ? phoneDigits : `+${phoneDigits}`;
  }
  return phoneDigits.replace(/\D/g, "");
}

function otpDeliveryPath(): string {
  const delivery = (process.env.WHATSAPP_NODE_DELIVERY || "otp").toLowerCase();
  if (delivery === "send-campaign") return "/api/otp/send-campaign";
  return "/api/otp/send";
}

function envTrim(name: string): string {
  return (process.env[name] || "").trim().replace(/^["']|["']$/g, "");
}

async function deliverOtpViaWhatsAppNode(phoneDigits: string, code: string) {
  const baseUrl = envTrim("WHATSAPP_NODE_URL").replace(/\/$/, "");
  const token = envTrim("WHATSAPP_NODE_TOKEN");
  const clientId = envTrim("WHATSAPP_NODE_CLIENT_ID");
  const timeoutSec = Number(envTrim("WHATSAPP_NODE_TIMEOUT") || 35);

  if (!baseUrl || !token || !clientId) {
    throw new Error(
      "node_not_configured: set WHATSAPP_NODE_URL, WHATSAPP_NODE_TOKEN, WHATSAPP_NODE_CLIENT_ID"
    );
  }

  const phone = formatPhoneForWhatsAppNode(phoneDigits);
  const message = `Your verification code for Osoul App is ${code}. Valid for 5 minutes. Do not share this code.`;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutSec * 1000);

  try {
    console.log(
      `[OTP] Calling WhatsApp Node ${baseUrl}${otpDeliveryPath()} phone=${phone} clientId=${clientId}`
    );
    const res = await fetch(`${baseUrl}${otpDeliveryPath()}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify({ phone, code, clientId, message }),
      signal: controller.signal,
    });

    let payload: { ok?: boolean; error?: string; message?: string } = {};
    try {
      payload = (await res.json()) as {
        ok?: boolean;
        error?: string;
        message?: string;
      };
    } catch {
      // non-JSON body
    }

    if (!res.ok || payload.ok === false) {
      const detail = payload.error || payload.message || `HTTP ${res.status}`;
      throw new Error(`WhatsApp Node OTP failed: ${detail}`);
    }
  } finally {
    clearTimeout(timer);
  }
}

export const sendOTP = async (phone: string) => {
  const normalizedPhone = normalizeQatarPhone(phone);
  try {
    if (isTestLoginPhone(normalizedPhone)) {
      await pool.query("DELETE FROM otps WHERE phone = $1", [normalizedPhone]);
      const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
      const hashedOTP = await hashTestLoginOtp();
      await pool.query(
        "INSERT INTO otps (phone, otp_hash, expires_at, used) VALUES ($1, $2, $3, false)",
        [normalizedPhone, hashedOTP, expiresAt]
      );
      console.log(
        `[TEST LOGIN] Fixed OTP ${TEST_LOGIN_OTP} for ${normalizedPhone}`
      );
      return { message: "OTP Sent", channel: "test" as const };
    }

    // Only count recent rows — old all-time COUNT silently blocked login OTP
    const queryCheckLimit = await pool.query(
      `SELECT COUNT(*) AS count FROM otps
       WHERE phone = $1 AND created_at > NOW() - INTERVAL '1 hour'`,
      [normalizedPhone]
    );
    const otpCount = Number(queryCheckLimit.rows[0]?.count ?? 0);
    if (otpCount >= 10) {
      const err = new Error("OTP limit reached. Try again in an hour.");
      (err as Error & { code?: string }).code = "OTP_LIMIT";
      throw err;
    }

    const otp = crypto.randomInt(1000, 10000).toString();
    const hashedOTP = await bcrypt.hash(otp, 10);
    const ttlSeconds = Number(process.env.OTP_TTL_SECONDS || 300);

    if (process.env.OTP_WHATSAPP_NODE_ENABLED === "false") {
      throw new Error(
        "WhatsApp OTP is disabled (OTP_WHATSAPP_NODE_ENABLED=false)"
      );
    }

    await deliverOtpViaWhatsAppNode(normalizedPhone, otp);
    console.log(`[OTP] WhatsApp Node accepted delivery for ${normalizedPhone}`);

    const expiresAt = new Date(Date.now() + ttlSeconds * 1000);
    await pool.query(
      "INSERT INTO otps (phone, otp_hash, expires_at, used) VALUES ($1, $2, $3, false)",
      [normalizedPhone, hashedOTP, expiresAt]
    );
    return { message: "OTP Sent", channel: "whatsapp_node" as const };
  } catch (error) {
    console.error("Error Sending OTP:", (error as Error).message);
    throw error;
  }
};

export async function canCreatePost(userId: string): Promise<boolean> {
  const result = await pool.query(
    `
    SELECT COUNT(*) AS count
      FROM posts
     WHERE user_id = $1
       AND created_at >= NOW() - INTERVAL '24 HOURS'
  `,
    [userId]
  );
  const { count } = result.rows[0];

  return count < 5;
}
