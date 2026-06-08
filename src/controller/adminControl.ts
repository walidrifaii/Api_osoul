import { pool } from "../config/dp";
import { Request, Response } from "express";

export const activeUsers = async (req: Request, res: Response) => {
  const user_id = req.query.user_id;
  if (!user_id) {
    res.status(400).json({ message: "User ID is required" });
    return;
  }
  const query =
    "update users set is_active = true where user_id = $1 returning *;";
  try {
    const result = await pool.query(query, [user_id]);
    if ((result.rowCount ?? 0) > 0) {
      console.log("User activated successfully");
      res
        .status(200)
        .json({ message: "User activated successfully", user: result.rows[0] });
    } else {
      res.status(404).json({ message: "User not found" });
    }
  } catch (error) {
    console.error("Error activating user:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
export const deactiveUsers = async (req: Request, res: Response) => {
  const user_id = req.query.user_id;
  if (!user_id) {
    res.status(400).json({ message: "User ID is required" });
    return;
  }
  const query =
    "update users set is_active = false where user_id = $1 returning *;";
  try {
    const result = await pool.query(query, [user_id]);
    if ((result.rowCount ?? 0) > 0) {
      console.log("User deactivated successfully");
      res.status(200).json({
        message: "User deactivated successfully",
        user: result.rows[0],
      });
    } else {
      res.status(404).json({ message: "User not found" });
    }
  } catch (error) {
    console.error("Error deactivating user:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getAllActiveUsers = async (req: Request, res: Response) => {
  const query = `
    SELECT 
      user_id, 
      user_phone, 
      full_name_ar, 
      company_name_ar, 
      user_type, 
      created_at
      FROM users
      WHERE is_active = true AND pending = false;
  `;

  try {
    const result = await pool.query(query);
    if ((result.rowCount ?? 0) > 0) {
      console.log("Users fetched successfully");
      res.status(200).json(result.rows);
    } else {
      res.status(404).json({ message: "No users found" });
    }
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getAllDeActiveUsers = async (req: Request, res: Response) => {
  const query = `
    SELECT 
      user_id, 
      user_phone, 
      full_name_ar, 
      company_name_ar, 
      user_type, 
      created_at
      FROM users
      WHERE is_active = false AND pending = false;
  `;

  try {
    const result = await pool.query(query);
    if ((result.rowCount ?? 0) > 0) {
      console.log("Users fetched successfully");
      res.status(200).json(result.rows);
    } else {
      res.status(404).json({ message: "No users found" });
    }
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getAllPosts = async (req: Request, res: Response) => {
  const query = `
    SELECT 
      p.id, 
      u.full_name_ar AS user_full_name_ar,
      u.user_phone AS user_phone,
      u.company_name_ar AS company_name_ar,
      u.commercial_registeration AS commercial_registeration,
      u.user_type AS user_type
    FROM posts p
    JOIN users u ON p.user_id = u.user_id;
  `;
  const query2 = `SELECT c.name AS category_name FROM posts p
    JOIN categories c ON p.category_id = c.id;`;

  try {
    const result = await pool.query(query);
    if ((result.rowCount ?? 0) > 0) {
      const categoryResult = await pool.query(query2);
      const dataToSend = [...result.rows, ...categoryResult.rows];
      res.status(200).json(dataToSend);
    } else {
      res.status(404).json({ message: "No posts found" });
    }
  } catch (error) {
    console.error("Error fetching posts:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const isActiveUser = async (req: Request, res: Response) => {
  //later we should check for token middleware protection for all routes ??
  const user_id = req.query.user_id;
  if (!user_id) {
    res.status(400).json({ message: "User ID is required" });
    return;
  }
  const query = "SELECT is_active FROM users WHERE user_id = $1;";
  try {
    const result = await pool.query(query, [user_id]);
    if ((result.rowCount ?? 0) > 0) {
      res.status(200).json({ is_active: result.rows[0].is_active });
    } else {
      res.status(404).json({ message: "User not found" });
    }
  } catch (error) {
    console.error("Error checking user activation:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
