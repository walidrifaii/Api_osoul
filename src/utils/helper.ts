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

export const sendOTP = async (phone: string) => {
  const normalizedPhone = normalizeQatarPhone(phone);
  const sendPhone = normalizedPhone;
  const Osoul = "447860042244";
  const CheckDail = "SELECT COUNT(*) AS count from otps WHERE phone=$1";
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
      return { message: "OTP Sent" };
    }

    const queryCheckLimit = await pool.query(CheckDail, [normalizedPhone]);
    const otpCount = Number(queryCheckLimit.rows[0]?.count ?? 0);
    if (otpCount >= 10) {
      return { limit: true };
    }
    const otp = crypto.randomInt(1000, 10000).toString();
    const hashedOTP = await bcrypt.hash(otp, 10);

    const body = {
      messages: [
        {
          from: Osoul,
          to: sendPhone,
          content: {
            templateName: "whatsapp_otp",
            templateData: {
              body: {
                placeholders: [otp],
              },
              buttons: [
                {
                  type: "URL",
                  parameter: otp,
                },
              ],
            },
            language: "en_US",
          },
        },
      ],
    };

    const api = process.env.INFOBIP_API_KEY;
    const baseURL = process.env.INFOBIP_BASE_URL;
    if (!baseURL) {
      throw new Error(
        "INFOBIP_BASE_URL is not defined in environment variables"
      );
    }
    const resInfo = await fetch(baseURL, {
      method: "POST",
      headers: {
        Authorization: `App ${api}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
    const expiresAt = new Date(Date.now() + 60 * 1000);

    await pool.query(
      "INSERT INTO otps (phone, otp_hash, expires_at, used) VALUES ($1, $2, $3, false)",
      [normalizedPhone, hashedOTP, expiresAt]
    );
    return { message: "OTP Sent" };
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
