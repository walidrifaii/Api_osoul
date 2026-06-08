import { Request, Response } from "express";
import { pool } from "../config/dp";
import CloudinaryCon from "../config/cloudinary";
import { canCreatePost } from "../utils/helper";
export const createPost = async (req: Request, res: Response) => {
  let {
    user_id,
    caption,
    city_id,
    sale_type_id,
    category_id,
    isDirect,
    condition_id,
    area,
    location,
    address,
    building,
    price,
    rooms,
    toilets,
    land_area,
    images,
  } = req.body;
  let publicImagesIds: string[] = [];
  if (!isDirect) {
    isDirect = req.body.is_direct;
  }

  // Input validation
  if (!user_id) {
    res.status(400).json({ error: "user_id is required" });
    return;
  }
  if (!caption || caption.trim().length < 10) {
    res.status(400).json({ error: "Caption must be at least 10 characters" });
    return;
  }
  if (!city_id || isNaN(Number(city_id))) {
    res.status(400).json({ error: "Valid city_id is required" });
    return;
  }
  if (!sale_type_id || isNaN(Number(sale_type_id))) {
    res.status(400).json({ error: "Valid sale_type_id is required" });
    return;
  }
  if (!category_id || isNaN(Number(category_id))) {
    res.status(400).json({ error: "Valid category_id is required" });
    return;
  }
  if (!condition_id || isNaN(Number(condition_id))) {
    res.status(400).json({ error: "Valid condition_id is required" });
    return;
  }

  if (!(await canCreatePost(user_id))) {
    res
      .status(403)
      .json({ isLimit: true, message: "You have reached your post limit." });
    return;
  }
  // Validation: convert empty strings to null for numeric fields
  function toNullableNumber(value: any): number | null {
    if (value === "" || value === undefined || value === null || value === 0)
      return null;
    const num = Number(value);
    return isNaN(num) ? null : num;
  }

  price = toNullableNumber(price);
  rooms = toNullableNumber(rooms);
  toilets = toNullableNumber(toilets);
  land_area = toNullableNumber(land_area);
  const locationCoordinates =
    location != null
      ? JSON.parse(location)
      : { latitude: null, longitude: null };

  try {
    const userCheckQuery = "SELECT is_active FROM users WHERE user_id = $1";
    const userCheckResult = await pool.query(userCheckQuery, [user_id]);
    if (
      userCheckResult.rows.length === 0 ||
      !userCheckResult.rows[0].is_active
    ) {
      res.status(403).json({
        isSuccess: false,
        message: "User is not active or does not exist",
      });
      return;
    }
    const query = `
    INSERT INTO posts (
      user_id,
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
      images,       -- TEXT[] of URLs
      public_ids,   -- TEXT[] of Cloudinary public_ids
      address,      -- nullable text
      location      -- geography point
    )
    VALUES (
      $1, $2, $3, $4, $5, $6, $7,
      $8, $9, $10, $11, $12, $13,
      $14,          -- uploadedImageUrls       (TEXT[])
      $15,          -- publicImagesIds        (TEXT[])
      CASE
        WHEN $16::text IS NOT NULL THEN $16::text
        ELSE NULL
      END,
      -- location: only if both lat & lon provided
      CASE
        WHEN $17::double precision IS NOT NULL
        AND $18::double precision IS NOT NULL
        THEN ST_MakePoint($18, $17)::geography
        ELSE NULL
      END
    )
    RETURNING id;
  `;
    const imageUploadPromises: Promise<string>[] = [];
    if (req.files && (req.files as Express.Multer.File[]).length > 0) {
      const files = req.files as Express.Multer.File[];

      for (const file of files) {
        const uploadPromise = new Promise<string>((resolve, reject) => {
          const stream = CloudinaryCon.uploader.upload_stream(
            {
              folder: "uploads",
              quality: "auto:low",
              fetch_format: "auto",
            },
            (err, result) => {
              if (err || !result)
                return reject(err || new Error("Upload failed"));
              resolve(result.secure_url);
              publicImagesIds.push(result.public_id);
            }
          );

          stream.end(file.buffer); // send the buffer as stream
        });

        imageUploadPromises.push(uploadPromise);
      }
    }
    if (images && Array.isArray(images)) {
      const base64UploadPromises = images.map((image: string) =>
        CloudinaryCon.uploader
          .upload(image, {
            folder: "uploads",
            quality: "auto:low",
            fetch_format: "auto",
          })
          .then((result) => {
            publicImagesIds.push(result.public_id);
            return result.secure_url;
          })
      );

      imageUploadPromises.push(...base64UploadPromises);
    }

    if (imageUploadPromises.length === 0) {
      res.status(400).json({ error: "No valid images received." });
      return;
    }

    // Enforce max 4 images per post
    if (imageUploadPromises.length > 4) {
      res.status(400).json({ error: "Maximum 4 images allowed per post." });
      return;
    }

    const uploadedImageUrls = await Promise.all(imageUploadPromises);
    const values = [
      user_id, // $1
      caption, // $2
      city_id, // $3
      sale_type_id, // $4
      category_id, // $5
      isDirect, // $6
      condition_id, // $7
      area ?? null, // $8
      building ?? null, // $9
      price, // $10
      rooms ?? null, // $11
      toilets ?? null, // $12
      land_area ?? null, // $13
      uploadedImageUrls, // $14 → TEXT[] of URLs
      publicImagesIds, // $15 → TEXT[] of public_ids
      address ?? null, // $16
      locationCoordinates.latitude ?? null, // $17
      locationCoordinates.longitude ?? null, // $18
    ];
    const result = await pool.query(query, values);
    const insertedId = result.rows[0].id;
    res
      .status(201)
      .json({ message: "Post created successfully", postId: insertedId });
  } catch (error) {
    console.error("Error creating post:", error);
    res.status(500).json({ error: "Failed to create post" });
  }
};
