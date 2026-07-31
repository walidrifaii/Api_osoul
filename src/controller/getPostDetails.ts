import crypto from "crypto";
import { pool } from "../config/dp";
import { Request, Response } from "express";
import { canModeratePosts, getAuthActor } from "../utils/helper";
import { normalizeImageList } from "../utils/imageStorage";

const MIN_VIEW_INCREMENT = 1;
const MAX_VIEW_INCREMENT = 5;

function randomViewIncrement(): number {
  return crypto.randomInt(MIN_VIEW_INCREMENT, MAX_VIEW_INCREMENT + 1);
}

export const getPostDet = async (req: Request, res: Response) => {
  const post_id = req.query.post_id;
  const user_id = req.query.user_id;
  console.log("this is post id: ", post_id);
  console.log("this is post id: ", user_id);
  const query = `
  SELECT
    p.*,
    JSON_BUILD_OBJECT(
      'longitude', ST_X(p.location::geometry),
      'latitude',  ST_Y(p.location::geometry)
    ) AS location,
    (
      SELECT row_to_json(u)
      FROM (
        SELECT 
          user_phone, 
          user_type, 
          full_name_ar, 
          full_name_en, 
          created_at,
          company_name_en,
          company_name_ar,
          commercial_registeration
        FROM users
        WHERE users.user_id = p.user_id
      ) u
    ) AS "user",
    CASE
      WHEN $2::text IS NULL THEN false
      ELSE EXISTS (
        SELECT 1
        FROM saved_posts sp
        WHERE sp.post_id = p.id
          AND sp.user_id = $2
      )
    END AS is_saved
  FROM posts p
  WHERE p.id = $1;
`;

  const values = [
    post_id ?? null, // $1: the post’s ID
    user_id ?? null, // $2: the viewer’s user_id, or null if none
  ];
  try {
    const queryResult = await pool.query(query, values);
    if ((queryResult.rowCount ?? 0) > 0) {
      const postDetails = {
        ...queryResult.rows[0],
        images: normalizeImageList(queryResult.rows[0].images),
      };
      console.log("Details for post: ", postDetails);
      console.log("Returning 200 with post details");
      res.status(200).json(postDetails);
    } else {
      console.log("Returning 404: Post not found");
      res.status(404).json({ message: "Post not found" });
    }
  } catch (error) {
    console.error("Error fetching post details:", error);
    console.log("Returning 500: Internal server error");
    res.status(500).json({ message: "Internal server error" });
  }
};

export const incrementViewCount = async (req: Request, res: Response) => {
  try {
    const postId = req.body.post_id;
    if (!postId) {
      res.status(400).json({ message: "post_id is required" });
      return;
    }

    const incrementBy = randomViewIncrement();
    const updateViewCountQuery = `UPDATE posts SET viewscnt = viewscnt + $2 WHERE id = $1 RETURNING viewscnt;`;
    const result = await pool.query(updateViewCountQuery, [postId, incrementBy]);

    if ((result.rowCount ?? 0) === 0) {
      res.status(404).json({ message: "Post not found" });
      return;
    }

    res.status(200).json({
      newViewsValue: result.rows[0].viewscnt,
      incrementBy,
      message: "View count updated successfully",
    });
  } catch (error) {
    console.error("Failed to update view count:", error);
    res.status(500).json({ message: "Failed to update view count" });
  }
};

export const deletePost = async (req: Request, res: Response) => {
  // Kept for compatibility; protectedPostDetRouter uses userPosts.deletePost.
  const postId = req.params.id;
  try {
    const result = await pool.query(
      "DELETE FROM posts WHERE id = $1 RETURNING *",
      [postId]
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Post not found" });
    }
    res.status(200).json({ message: "Post deleted successfully" });
  } catch (err) {
    console.error("Error deleting post:", err);
    res.status(500).json({ message: "Server error while deleting post" });
  }
};

// PUT /edit-post/:id
export const editPost = async (req: Request, res: Response) => {
  const {
    caption,
    city_id,
    sale_type_id,
    category_id,
    is_direct,
    condition_id,
    area,
    building,
    price,
    rooms,
    toilets,
    land_area,
    address,
    latitude,
    longitude,
  } = req.body;
  console.log("EditPost body:", req.body);
  const post_id = req.params.id;
  const actor = getAuthActor(req);
  const isDirectValue =
    is_direct !== undefined && is_direct !== null && is_direct !== ""
      ? is_direct
      : req.body.isDirect;

  const isModerator = await canModeratePosts(actor);
  if (!isModerator) {
    if (!actor.userId) {
      res.status(401).json({ message: "Unauthorized" });
      return;
    }
    const ownership = await pool.query(
      "SELECT user_id FROM posts WHERE id = $1",
      [post_id]
    );
    if (ownership.rowCount === 0) {
      res.status(404).json({ message: "Post not found" });
      return;
    }
    if (ownership.rows[0].user_id !== actor.userId) {
      res.status(403).json({ message: "You are not authorized" });
      return;
    }
  }

  const hasCoords =
    latitude !== undefined &&
    latitude !== null &&
    latitude !== "" &&
    longitude !== undefined &&
    longitude !== null &&
    longitude !== "";
  const hasAddress = address !== undefined;

  try {
    const updateQuery = `
      UPDATE posts SET
        caption      = $1,
        city_id      = $2,
        sale_type_id = $3,
        category_id  = $4,
        is_direct    = $5,
        condition_id = $6,
        area         = $7,
        building     = $8,
        price        = $9,
        rooms        = $10,
        toilets      = $11,
        land_area    = $12,
        address      = CASE
                         WHEN $13::boolean THEN $14::text
                         ELSE address
                       END,
        location     = CASE
                         WHEN $15::boolean
                          AND $16::double precision IS NOT NULL
                          AND $17::double precision IS NOT NULL
                         THEN ST_MakePoint($17, $16)::geography
                         ELSE location
                       END,
        updated_at   = CURRENT_TIMESTAMP
      WHERE id = $18
      RETURNING *;
    `;

    const result = await pool.query(updateQuery, [
      caption,
      city_id,
      sale_type_id,
      category_id,
      isDirectValue,
      condition_id,
      area ?? null,
      building ?? null,
      price,
      rooms ?? null,
      toilets ?? null,
      land_area ?? null,
      hasAddress,
      hasAddress ? address ?? null : null,
      hasCoords,
      hasCoords ? Number(latitude) : null,
      hasCoords ? Number(longitude) : null,
      post_id,
    ]);

    if (!result.rows.length) {
      res.status(404).json({ message: "Post not found or not yours" });
      return;
    }

    res.json({
      message: "Post updated successfully",
      post: result.rows[0],
    });
  } catch (err) {
    console.error("EditPost error:", err);
    res.status(500).json({ message: "Server error" });
  }
};
