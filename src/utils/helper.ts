import { pool } from "../config/dp";
import crypto from "crypto";
import bcrypt from "bcrypt";

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

export const sendOTP = async (phone: string) => {
  const sendPhone = `${phone}`;
  const Osoul = "447860042244";
  const CheckDail = "SELECT COUNT(*) AS count from otps WHERE phone=$1";
  try {
    const queryCheckLimit = await pool.query(CheckDail, [phone]);
    if ((queryCheckLimit.rowCount ?? 0) >= 10) {
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
      "INSERT INTO otps (phone, otp_hash, expires_at) VALUES ($1, $2, $3)",
      [phone, hashedOTP, expiresAt]
    );
    return { message: "OTP Sent" };
  } catch (error) {
    console.error("Error Sending OTP:", (error as Error).message);
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
