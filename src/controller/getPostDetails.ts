import CloudinaryCon from "../config/cloudinary";
import { pool } from "../config/dp";
import { Request, Response } from "express";
import { isAdminUser } from "../utils/helper";

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
      const postDetails = queryResult.rows[0];
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
    console.log(req.body);
    const postId = req.body.post_id;
    const updateViewCountQuery = `UPDATE posts SET viewscnt = viewscnt + $2 where id = $1 RETURNING viewscnt;`;
    const updateViewCountValues = [postId, 1];
    const result = await pool.query(
      updateViewCountQuery,
      updateViewCountValues
    );
    console.log("Returning 200: View count updated successfully");
    res.status(200).json({
      newViewsValue: result.rows[0].viewscnt,
      message: "View count updated successfully",
    });
  } catch (error) {
    console.log(error);
    console.log("Returning 500: Failed to update view count");
    res.status(500).json({ message: "Failed to update view count" });
  }
};

export const deletePost = async (req: Request, res: Response) => {
  const postId = req.params.id;
  try {
    const result = await pool.query(
      "DELETE FROM posts WHERE id = $1 RETURNING *",
      [postId]
    );
    if (result.rowCount === 0) {
      console.log("Returning 404: Post not found");
      return res.status(404).json({ message: "Post not found" });
    }
    console.log("Returning 200: Post deleted successfully");
    res.status(200).json({ message: "Post deleted successfully" });
  } catch (err) {
    console.error("Error deleting post:", err);
    console.log("Returning 500: Server error while deleting post");
    res.status(500).json({ message: "Server error while deleting post" });
  }
};

// PUT /posts/:id
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
    // images, // base64 strings
    address,
    latitude,
    longitude,
    post_user_id,
    curr_user_id,
  } = req.body;
  console.log("EditPost body:", req.body);
  const post_id = req.params.id;
  // Allow admin user to bypass checks
  const isAdmin = await isAdminUser(curr_user_id);
  if (!isAdmin) {
    if (!post_user_id || !curr_user_id) {
      console.log("Returning 400: User IDs are required");
      res.status(400).json({ message: "User IDs are required" });
      return;
    }
    if (post_user_id !== curr_user_id) {
      console.log("Returning 403: You are not authorized");
      res.status(403).json({ message: "You are not authorized" });
      return;
    }
  }

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
        address      = CASE WHEN $13::text IS NOT NULL THEN $13 ELSE NULL END,
        location     = CASE
                         WHEN $14::double precision IS NOT NULL
                          AND $15::double precision IS NOT NULL
                         THEN ST_MakePoint($15, $14)::geography
                         ELSE NULL
                       END
      WHERE id = $16
      RETURNING *;
    `;

    const result = await pool.query(updateQuery, [
      caption, // $1
      city_id, // $2
      sale_type_id, // $3
      category_id, // $4
      is_direct, // $5
      condition_id, // $6
      area ?? null, // $7
      building ?? null, // $8
      price, // $9
      rooms ?? null, // $10
      toilets ?? null, // $11
      land_area ?? null, // $12
      // newImageUrls, // $13
      // newPublicIds, // $14
      address ?? null, // $15 13
      latitude ?? null, // $16 14
      longitude ?? null, // $17 15
      post_id, // $18 16
    ]);

    if (!result.rows.length) {
      console.log("No post found with ID:", post_id);
      console.log("Returning 404: Post not found or not yours");
      res.status(404).json({ message: "Post not found or not yours" });
      return;
    }

    console.log("Returning 200: Post updated successfully");
    res.json({
      message: "Post updated successfully",
      post: result.rows[0],
    });
  } catch (err) {
    console.error("EditPost error:", err);
    console.log("Returning 500: Server error");
    res.status(500).json({ message: "Server error" });
  }
};
