import { Pool } from "pg";
import dotenv from "dotenv";
dotenv.config();
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl:
    process.env.NODE_ENV === "production" || process.env.NODE_ENV === "Test"
      ? { rejectUnauthorized: false }
      : false,
});

async function connectDB() {
  try {
    const client = await pool.connect();
    console.log("Connected to the database!");
    client.release();
  } catch (error) {
    console.error("Error connecting to the database:", error);
  }
}

export { pool, connectDB };
