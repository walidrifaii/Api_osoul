import { Pool } from "pg";
import dotenv from "dotenv";
dotenv.config();
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // Internal Docker/EazyPanel Postgres does not support SSL.
  // Set DATABASE_SSL=true only for external cloud DBs that require it (e.g. Render).
  ssl:
    process.env.DATABASE_SSL === "true"
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
