/**
 * Seed Walid Rifaii user (97431644306).
 *
 * Usage:
 *   node scripts/seed-walid-user.js
 *   node scripts/seed-walid-user.js --local
 */
require("dotenv").config();
const crypto = require("crypto");
const { Pool } = require("pg");

const LOCAL_DATABASE_URL =
  "postgresql://postgres:123456789@localhost:5432/osoul";

const USER = {
  user_phone: "97431644306",
  full_name_en: "Walid Rifaii",
  full_name_ar: "وليد رفاعي",
  user_type: "individual",
};

async function main() {
  const databaseUrl = process.argv.includes("--local")
    ? LOCAL_DATABASE_URL
    : process.env.DATABASE_URL || LOCAL_DATABASE_URL;

  const pool = new Pool({ connectionString: databaseUrl });

  try {
    const existing = await pool.query(
      "SELECT user_id, user_phone, full_name_en, full_name_ar, pending, is_active FROM users WHERE user_phone = $1",
      [USER.user_phone]
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
         RETURNING user_id, user_phone, full_name_en, full_name_ar, pending, is_active`,
        [
          USER.user_phone,
          USER.full_name_en,
          USER.full_name_ar,
          USER.user_type,
        ]
      );
      user = updated.rows[0];
      console.log("Updated existing user.");
    } else {
      const inserted = await pool.query(
        `INSERT INTO users (
          user_id, user_phone, full_name_en, full_name_ar,
          user_type, pending, is_active
        ) VALUES ($1, $2, $3, $4, $5, false, true)
        RETURNING user_id, user_phone, full_name_en, full_name_ar, pending, is_active`,
        [
          crypto.randomUUID(),
          USER.user_phone,
          USER.full_name_en,
          USER.full_name_ar,
          USER.user_type,
        ]
      );
      user = inserted.rows[0];
      console.log("Created new user.");
    }

    console.log(user);
    console.log("\nUse Login (not Register) with phone:", USER.user_phone);
  } finally {
    await pool.end();
  }
}

main().catch((err) => {
  console.error("Failed:", err.message);
  process.exit(1);
});
