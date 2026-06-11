/**
 * Local dev only. For production, use scripts/create-test-user.sql in DbGate.
 *
 * Usage:
 *   npm run create-test-user:local
 */
require("dotenv").config();
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const { Pool } = require("pg");

const LOCAL_DATABASE_URL =
  "postgresql://postgres:123456789@localhost:5432/osoul";
const TEST_USER = {
  user_phone: "97455551234",
  full_name_en: "Test User",
  full_name_ar: "مستخدم تجريبي",
  user_type: "individual",
};
const TEST_OTP = "1234";
const TEST_OTP_HASH =
  "$2b$10$DXlefH0jdL0d24BZy1R0gek4KvBOz1p0hxAVxbfiTdd7OlJYC9/Pe";

async function main() {
  const databaseUrl = process.argv.includes("--local")
    ? LOCAL_DATABASE_URL
    : process.env.DATABASE_URL || LOCAL_DATABASE_URL;

  const pool = new Pool({ connectionString: databaseUrl });
  const userId = crypto.randomUUID();

  try {
    const existing = await pool.query(
      "SELECT * FROM users WHERE user_phone = $1",
      [TEST_USER.user_phone]
    );

    let user;
    if (existing.rows.length > 0) {
      const updated = await pool.query(
        `UPDATE users
         SET pending = false,
             is_active = true,
             full_name_en = $2,
             full_name_ar = $3,
             user_type = $4
         WHERE user_phone = $1
         RETURNING *`,
        [
          TEST_USER.user_phone,
          TEST_USER.full_name_en,
          TEST_USER.full_name_ar,
          TEST_USER.user_type,
        ]
      );
      user = updated.rows[0];
      console.log("Updated existing test user.");
    } else {
      const inserted = await pool.query(
        `INSERT INTO users (
          user_id, user_phone, full_name_en, full_name_ar,
          user_type, pending, is_active
        ) VALUES ($1, $2, $3, $4, $5, false, true)
        RETURNING *`,
        [
          userId,
          TEST_USER.user_phone,
          TEST_USER.full_name_en,
          TEST_USER.full_name_ar,
          TEST_USER.user_type,
        ]
      );
      user = inserted.rows[0];
      console.log("Created new test user.");
    }

    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

    await pool.query("DELETE FROM otps WHERE phone = $1", [user.user_phone]);
    await pool.query(
      "INSERT INTO otps (phone, otp_hash, expires_at, used) VALUES ($1, $2, $3, false)",
      [user.user_phone, TEST_OTP_HASH, expiresAt]
    );

    const token = jwt.sign(
      {
        user_id: user.user_id,
        full_name_ar: user.full_name_ar,
        full_name_en: user.full_name_en,
        user_phone: user.user_phone,
      },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    console.log("\n=== Local test user ready ===");
    console.log("Phone:  ", user.user_phone);
    console.log("OTP:    ", TEST_OTP);
    console.log("Token:  ", token);
    console.log("\nProduction: use scripts/create-test-user.sql + fix-test-otp.sql in DbGate.");
  } finally {
    await pool.end();
  }
}

main().catch((err) => {
  console.error("Failed:", err.message);
  process.exit(1);
});
