import { pool } from "../config/dp";
import { Request, Response } from "express";
import { AuthRequest } from "../middleware/protect";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import { getUserByPhone } from "../utils/helper";
import cron from "node-cron";
import { sendOTP } from "../utils/helper";
import {
  isTestLoginPhone,
  normalizeOtp,
  normalizeQatarPhone,
  TEST_LOGIN_OTP,
} from "../utils/testAuth";
cron.schedule("*/20 * * * *", async () => {
  try {
    await pool.query(
      `DELETE FROM users
       WHERE pending = true`
    );
    await pool.query(
      `DELETE FROM otps
       WHERE expires_at < NOW()`
    );

    console.log("Cleaned up expired pending users");
  } catch (err) {
    console.error("Cleanup error:", err);
  }
});

export const registerUser = async (req: Request, res: Response) => {
  const {
    user_phone,
    full_name_en,
    full_name_ar,
    company_name_en,
    company_name_ar,
    commercial_registeration,
    user_type,
  } = req.body;

  // Input validation
  if (!user_phone || !/^974\d{8}$/.test(user_phone)) {
    res
      .status(400)
      .json({ message: "Invalid phone format (must be 974 + 8 digits)", isValid: false });
    return;
  }
  if (!full_name_en || full_name_en.trim().length === 0) {
    res
      .status(400)
      .json({ message: "English full name is required", isValid: false });
    return;
  }
  if (!full_name_ar || full_name_ar.trim().length === 0) {
    res
      .status(400)
      .json({ message: "Arabic full name is required", isValid: false });
    return;
  }
  if (user_type && user_type !== "individual" && user_type !== "business") {
    res
      .status(400)
      .json({ message: "user_type must be 'individual' or 'business'", isValid: false });
    return;
  }

  const user_id = crypto.randomUUID();

  const query = `
    INSERT INTO users (
      user_id,
      user_phone,
      full_name_en,
      full_name_ar,
      commercial_registeration,
      company_name_en,
      company_name_ar,
      user_type
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING *;
  `;
  try {
    const normalizedPhone = normalizeQatarPhone(user_phone);
    if (!/^974\d{8}$/.test(normalizedPhone)) {
      res.status(400).json({
        message: "Invalid phone format (must be 974 + 8 digits)",
        isValid: false,
      });
      return;
    }

    const existing = await pool.query(
      "SELECT user_id, pending FROM users WHERE user_phone=$1 LIMIT 1",
      [normalizedPhone]
    );

    if (existing.rows.length > 0) {
      if (existing.rows[0].pending === true) {
        sendOTP(normalizedPhone);
        res.status(200).json({
          message: "User Registered but still pending",
          isValid: true,
        });
        return;
      }

      // Fully registered (pending=false) — UNIQUE would reject INSERT anyway
      res.status(409).json({
        message: "Phone number already registered",
        isValid: false,
      });
      return;
    }

    const result = await pool.query(query, [
      user_id,
      normalizedPhone,
      full_name_en,
      full_name_ar,
      commercial_registeration,
      company_name_en,
      company_name_ar,
      user_type,
    ]);
    if ((result.rowCount ?? 0) > 0) {
      sendOTP(normalizedPhone);
      res.status(200).json({ isValid: true });
      return;
    }

    console.log("User could not be registered");
    res
      .status(400)
      .json({ message: "User could not be registered", isValid: false });
  } catch (err) {
    const pgError = err as Error & { code?: string };
    console.log("user reg error:", pgError.message);
    if (pgError.code === "23505") {
      res.status(409).json({
        message: "Phone number already registered",
        isValid: false,
      });
      return;
    }
    res.status(500).json({
      message: "Signup failed",
      error: pgError.message,
      isValid: false,
    });
  }
};

export const Login = async (req: Request, res: Response) => {
  const { user_phone } = req.body;

  // Input validation
  if (!user_phone || !/^974\d{8}$/.test(user_phone)) {
    res
      .status(400)
      .json({ message: "Invalid phone format (must be 974 + 8 digits)", isValid: false });
    return;
  }

  try {
    const query = "SELECT * from users WHERE user_phone = $1 AND pending=false";
    const values = [user_phone];
    const result = await pool.query(query, values);
    if ((result.rowCount ?? 0) > 0) {
      await sendOTP(user_phone);
      res.status(200).json({ message: "Login Successfully", isValid: true });
    } else {
      res.status(404).json({
        message: "No user registered with this phone number",
        isValid: false,
      });
    }
  } catch (err) {
    console.log("log in failed:", (err as Error).message);
    res.status(500).json({
      message: "Login failed",
      error: (err as Error).message,
      isValid: false,
    });
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  const user_id = req.query.user_id;
  try {
    const deleteSQL = await pool.query("DELETE FROM users WHERE user_id=$1", [
      user_id,
    ]);
    if ((deleteSQL.rowCount ?? 0) > 0) {
      res
        .status(200)
        .json({ message: "your account has been deleted", deleted: true });
    } else {
      res
        .status(200)
        .json({ message: "error deleteing account", deleted: false });
    }
  } catch (error) {
    console.error("Delete user error:", (error as Error).message);
    res
      .status(404)
      .json({ message: "Couldn't delete account", deleted: false });
  }
};

export const verfiyUser = async (req: Request, res: Response) => {
  try {
    const { phone, otp: rawOtp } = req.body;
    const otp = normalizeOtp(rawOtp);

    // Input validation
    if (!otp || !/^\d{4}$/.test(otp)) {
      res.status(400).json({ error: "OTP must be 4 digits", isVerfied: false });
      return;
    }

    if (!phone) {
      res.status(400).json({ error: "Phone is required", isVerfied: false });
      return;
    }

    const normalizedPhone = normalizeQatarPhone(phone);
    if (!/^974\d{8}$/.test(normalizedPhone)) {
      res.status(400).json({ error: "Invalid phone format", isVerfied: false });
      return;
    }

    const isFixedTestLogin =
      isTestLoginPhone(normalizedPhone) && otp === TEST_LOGIN_OTP;

    let otpRowId: number | null = null;

    if (!isFixedTestLogin) {
      const { rows } = await pool.query(
        "SELECT id, otp_hash, expires_at, used FROM otps WHERE phone=$1 ORDER BY created_at DESC LIMIT 1",
        [normalizedPhone]
      );
      if (rows.length === 0) {
        res
          .status(400)
          .json({ error: "No OTP requested for this number", isVerfied: false });
        return;
      }
      const { id, otp_hash, expires_at, used } = rows[0];
      if (used) {
        res.status(400).json({ error: "OTP already used", isVerfied: false });
        return;
      }
      if (new Date() > expires_at) {
        res.status(400).json({ error: "OTP expired", isVerfied: false });
        return;
      }

      const enteredHash = await bcrypt.compare(otp, otp_hash);
      if (!enteredHash) {
        res.status(400).json({ error: "Invalid OTP", isVerfied: false });
        return;
      }
      otpRowId = id;
    }

    const result = await getUserByPhone(normalizedPhone);
    if (!result) {
      res.status(404).json({
        error: "No user registered with this phone number",
        isVerfied: false,
      });
      return;
    }
    const user = {
      user_id: result.user_id,
      user_phone: result.user_phone,
      full_name_ar: result.full_name_ar,
      full_name_en: result.full_name_en,
      company_name_en: result.company_name_en,
      company_name_ar: result.company_name_ar,
      user_type: result.user_type,
      commercial_registeration: result.commercial_registeration,
      is_active: result.is_active,
    };
    const data2Token = {
      user_id: user.user_id,
      full_name_ar: user.full_name_ar,
      full_name_en: user.full_name_en,
      user_phone: user.user_phone,
    };

    const token = jwt.sign(data2Token, process.env.JWT_SECRET as string, {
      expiresIn: "7d",
    });
    res.status(200).json({
      message: "Log in Succeded and phone verfied",
      token,
      user,
      isVerfied: true,
    });
    if (otpRowId !== null) {
      await pool.query("UPDATE otps SET used = true WHERE id = $1", [otpRowId]);
    } else {
      await pool.query(
        "UPDATE otps SET used = true WHERE phone = $1 AND used = false",
        [normalizedPhone]
      );
    }
    await pool.query("UPDATE users SET pending = false WHERE user_phone = $1", [
      normalizedPhone,
    ]);
    return;
  } catch (err) {
    console.error("OTP verification error:", (err as Error).message);
    res
      .status(500)
      .json({ message: "OTP verification failed", isVerfied: false });
    return;
  }
};

export const SendOTPController = async (req: Request, res: Response) => {
  const { phone } = req.body;
  const normalizedPhone = normalizeQatarPhone(phone);
  if (!/^974\d{8}$/.test(normalizedPhone)) {
    res.status(400).json({ isSent: false, message: "Invalid phone format" });
    return;
  }
  try {
    await sendOTP(normalizedPhone);
    res.status(202).json({ isSent: true, message: "otp sent" });
  } catch (error) {
    console.error("OTP send error:", (error as Error).message);
    res.status(400).json({ isSent: false, message: "otp send failed" });
    return;
  }
};

import { validateAndParsePushTokenBody } from "../utils/pushTokenParsing";

export const registerPushToken = async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const user = authReq.user as { user_id?: string } | undefined;
  const userId = user?.user_id;
  const { device_id, app_version } = req.body;

  if (!userId) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  const parsed = validateAndParsePushTokenBody(req.body);
  if (!parsed.ok) {
    res.status(parsed.status).json({
      message: parsed.message,
      ...(parsed.push_app_id ? { push_app_id: parsed.push_app_id } : {}),
    });
    return;
  }

  const {
    pushToken,
    platform,
    tokenType: resolvedTokenType,
    environment,
    preferredLanguage,
    pushAppId,
  } = parsed.data;

  try {
    const updateQueries = [
      {
        sql: `UPDATE users
              SET expo_push_token = $1,
                  push_platform = $2,
                  push_token_type = $3,
                  push_environment = $4,
                  preferred_language = $5
              WHERE user_id = $6`,
        params: [
          pushToken,
          platform,
          resolvedTokenType,
          environment,
          preferredLanguage,
          userId,
        ],
      },
      {
        sql: `UPDATE users
              SET expo_push_token = $1,
                  push_platform = $2,
                  push_token_type = $3,
                  push_environment = $4
              WHERE user_id = $5`,
        params: [
          pushToken,
          platform,
          resolvedTokenType,
          environment,
          userId,
        ],
      },
      {
        sql: "UPDATE users SET expo_push_token = $1, push_platform = $2 WHERE user_id = $3",
        params: [pushToken, platform, userId],
      },
      {
        sql: "UPDATE users SET expo_push_token = $1 WHERE user_id = $2",
        params: [pushToken, userId],
      },
    ];

    let updated = false;
    for (const query of updateQueries) {
      try {
        await pool.query(query.sql, query.params);
        updated = true;
        break;
      } catch {
        continue;
      }
    }

    if (!updated) {
      throw new Error("Failed to update push token columns");
    }

    if (typeof device_id === "string" && device_id.trim()) {
      try {
        await pool.query(
          `INSERT INTO device_push_tokens (
             device_id, push_token, push_platform, push_token_type,
             push_environment, preferred_language, user_id, app_version,
             last_opened_at, updated_at
           )
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())
           ON CONFLICT (device_id) DO UPDATE SET
             push_token = EXCLUDED.push_token,
             push_platform = EXCLUDED.push_platform,
             push_token_type = EXCLUDED.push_token_type,
             push_environment = EXCLUDED.push_environment,
             preferred_language = EXCLUDED.preferred_language,
             user_id = EXCLUDED.user_id,
             app_version = COALESCE(EXCLUDED.app_version, device_push_tokens.app_version),
             last_opened_at = NOW(),
             updated_at = NOW()`,
          [
            device_id.trim(),
            pushToken,
            platform,
            resolvedTokenType,
            environment,
            preferredLanguage,
            userId,
            typeof app_version === "string" ? app_version.trim() : null,
          ]
        );
      } catch (deviceError) {
        console.warn(
          "Device push token link on login failed:",
          (deviceError as Error).message
        );
      }
    }

    res.status(200).json({
      message: "Push token registered",
      push_platform: platform,
      push_token_type: resolvedTokenType,
      push_environment: environment,
      preferred_language: preferredLanguage,
      push_app_id: pushAppId,
    });
  } catch (error) {
    console.error("Push token registration error:", (error as Error).message);
    res.status(500).json({ message: "Failed to register push token" });
  }
};

export const unregisterPushToken = async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const user = authReq.user as { user_id?: string } | undefined;
  const userId = user?.user_id;
  const { device_id } = req.body;

  if (!userId) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  try {
    const clearQueries = [
      `UPDATE users
       SET expo_push_token = NULL,
           push_platform = NULL,
           push_token_type = NULL,
           push_environment = NULL
       WHERE user_id = $1`,
      `UPDATE users
       SET expo_push_token = NULL, push_platform = NULL
       WHERE user_id = $1`,
      "UPDATE users SET expo_push_token = NULL WHERE user_id = $1",
    ];

    for (const sql of clearQueries) {
      try {
        await pool.query(sql, [userId]);
        break;
      } catch {
        continue;
      }
    }

    if (typeof device_id === "string" && device_id.trim()) {
      try {
        await pool.query(
          `UPDATE device_push_tokens
           SET user_id = NULL, updated_at = NOW()
           WHERE device_id = $1 AND user_id = $2`,
          [device_id.trim(), userId]
        );
      } catch (deviceError) {
        console.warn(
          "Device unlink on logout failed:",
          (deviceError as Error).message
        );
      }
    }

    res.status(200).json({ message: "Push token unregistered" });
  } catch (error) {
    console.error("Push token unregister error:", (error as Error).message);
    res.status(500).json({ message: "Failed to unregister push token" });
  }
};
