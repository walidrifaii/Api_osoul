import { pool } from "../config/dp";
import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import { getUserByPhone } from "../utils/helper";
import cron from "node-cron";
import { sendOTP } from "../utils/helper";
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
  const values = [
    user_id,
    user_phone,
    full_name_en,
    full_name_ar,
    commercial_registeration,
    company_name_en,
    company_name_ar,
    user_type,
  ];
  try {
    const tem = await pool.query(
      "SELECT * FROM users WHERE user_phone=$1 AND pending=true",
      [user_phone]
    );
    if (tem.rows.length > 0) {
      sendOTP(user_phone);

      res
        .status(200)
        .json({ message: "User Registered but still pending", isValid: true });
      return;
    }
    const result = await pool.query(query, values);
    if ((result.rowCount ?? 0) > 0) {
      sendOTP(user_phone);
      res.status(200).json({ isValid: true });
      return;
    } else {
      console.log("User could not be registered");
      res
        .status(400)
        .json({ message: "User could not be registered", isValid: false });
      return;
    }
  } catch (err) {
    console.log("user reg error:", (err as Error).message);
    res.status(500).json({
      message: "Signup failed",
      error: (err as Error).message,
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
    const { phone, otp } = req.body;

    // Input validation
    if (!otp || !/^\d{4}$/.test(otp)) {
      res.status(400).json({ error: "OTP must be 4 digits", isVerfied: false });
      return;
    }

    let normalizedPhone = "";
    if (phone.slice(0, 3) != "974") {
      normalizedPhone = `974${phone}`;
    } else {
      normalizedPhone = phone;
    }

    // All users go through proper OTP verification (no bypasses)
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

    const result = await getUserByPhone(normalizedPhone);
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
    await pool.query("UPDATE otps SET used = true WHERE id = $1", [id]);
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
  let normalizedPhone = "";
  if (phone.slice(0, 3) != "974") {
    normalizedPhone = `974${phone}`;
  } else {
    normalizedPhone = phone;
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
