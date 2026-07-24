import { Request, Response } from "express";
import { pool } from "../config/dp";
import { canCreatePost } from "../utils/helper";
import {
  uploadBase64Image,
  uploadImageBuffer,
} from "../utils/imageStorage";

type LocationCoords = {
  latitude: number | null;
  longitude: number | null;
};

function toNullableNumber(value: unknown): number | null {
  if (value === "" || value === undefined || value === null || value === 0) {
    return null;
  }
  const num = Number(value);
  return Number.isNaN(num) ? null : num;
}

function toBoolean(value: unknown, fallback = false): boolean {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value === 1;
  if (typeof value === "string") {
    const normalized = value.trim().toLowerCase();
    if (["true", "1", "yes"].includes(normalized)) return true;
    if (["false", "0", "no", ""].includes(normalized)) return false;
  }
  return fallback;
}

function parseLocation(
  location: unknown,
  latitude?: unknown,
  longitude?: unknown
): LocationCoords {
  const fromLatLon = {
    latitude: toNullableNumber(latitude),
    longitude: toNullableNumber(longitude),
  };

  if (
    fromLatLon.latitude != null &&
    fromLatLon.longitude != null
  ) {
    return fromLatLon;
  }

  if (location == null || location === "") {
    return { latitude: null, longitude: null };
  }

  let parsed: unknown = location;
  if (typeof location === "string") {
    try {
      parsed = JSON.parse(location);
    } catch {
      return { latitude: null, longitude: null };
    }
  }

  if (!parsed || typeof parsed !== "object") {
    return { latitude: null, longitude: null };
  }

  const record = parsed as Record<string, unknown>;
  return {
    latitude: toNullableNumber(record.latitude ?? record.lat),
    longitude: toNullableNumber(
      record.longitude ?? record.lng ?? record.lon
    ),
  };
}

export const createPost = async (req: Request, res: Response) => {
  let imagePaths: string[] = [];

  try {
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
      latitude,
      longitude,
    } = req.body;

    if (isDirect === undefined || isDirect === null || isDirect === "") {
      isDirect = req.body.is_direct;
    }

    if (!user_id) {
      res.status(400).json({ error: "user_id is required" });
      return;
    }
    if (!caption || String(caption).trim().length < 10) {
      res.status(400).json({ error: "Caption must be at least 10 characters" });
      return;
    }
    if (!city_id || Number.isNaN(Number(city_id))) {
      res.status(400).json({ error: "Valid city_id is required" });
      return;
    }
    if (!sale_type_id || Number.isNaN(Number(sale_type_id))) {
      res.status(400).json({ error: "Valid sale_type_id is required" });
      return;
    }
    if (!category_id || Number.isNaN(Number(category_id))) {
      res.status(400).json({ error: "Valid category_id is required" });
      return;
    }
    if (!condition_id || Number.isNaN(Number(condition_id))) {
      res.status(400).json({ error: "Valid condition_id is required" });
      return;
    }

    if (!(await canCreatePost(user_id))) {
      res.status(403).json({
        isLimit: true,
        message: "You have reached your post limit.",
      });
      return;
    }

    price = toNullableNumber(price);
    rooms = toNullableNumber(rooms);
    toilets = toNullableNumber(toilets);
    land_area = toNullableNumber(land_area);
    const isDirectBool = toBoolean(isDirect, false);
    const locationCoordinates = parseLocation(location, latitude, longitude);

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
      images,
      public_ids,
      address,
      location
    )
    VALUES (
      $1, $2, $3, $4, $5, $6, $7,
      $8, $9, $10, $11, $12, $13,
      $14,
      $15,
      CASE
        WHEN $16::text IS NOT NULL THEN $16::text
        ELSE NULL
      END,
      CASE
        WHEN $17::double precision IS NOT NULL
        AND $18::double precision IS NOT NULL
        THEN ST_MakePoint($18, $17)::geography
        ELSE NULL
      END
    )
    RETURNING id;
  `;

    const imageUploadPromises: Promise<{ url: string; path: string }>[] = [];

    if (req.files && (req.files as Express.Multer.File[]).length > 0) {
      const files = req.files as Express.Multer.File[];
      for (const file of files) {
        imageUploadPromises.push(
          uploadImageBuffer(
            file.buffer,
            file.originalname || `upload_${Date.now()}.jpg`,
            file.mimetype
          )
        );
      }
    }

    if (images) {
      const imageList = Array.isArray(images)
        ? images
        : typeof images === "string"
          ? (() => {
              try {
                const parsed = JSON.parse(images);
                return Array.isArray(parsed) ? parsed : [images];
              } catch {
                return [images];
              }
            })()
          : [];

      for (const image of imageList) {
        if (typeof image === "string" && image.trim()) {
          imageUploadPromises.push(uploadBase64Image(image));
        }
      }
    }

    if (imageUploadPromises.length === 0) {
      res.status(400).json({ error: "No valid images received." });
      return;
    }

    if (imageUploadPromises.length > 4) {
      res.status(400).json({ error: "Maximum 4 images allowed per post." });
      return;
    }

    const uploadedImages = await Promise.all(imageUploadPromises);
    const uploadedImageUrls = uploadedImages.map((image) => image.url);
    imagePaths = uploadedImages.map((image) => image.path);

    const values = [
      user_id,
      caption,
      Number(city_id),
      Number(sale_type_id),
      Number(category_id),
      isDirectBool,
      Number(condition_id),
      area ?? null,
      building ?? null,
      price,
      rooms,
      toilets,
      land_area,
      uploadedImageUrls,
      imagePaths,
      address ?? null,
      locationCoordinates.latitude,
      locationCoordinates.longitude,
    ];

    const result = await pool.query(query, values);
    const insertedId = result.rows[0].id;
    res.status(201).json({
      message: "Post created successfully",
      postId: insertedId,
      isSuccess: true,
    });
  } catch (error) {
    console.error("Error creating post:", error);
    const message =
      error instanceof Error ? error.message : "Failed to create post";

    // Surface known upload/validation failures to the client.
    if (
      message.includes("Image upload failed") ||
      message.includes("Empty image data") ||
      message.includes("HEIC") ||
      message.includes("JPG or PNG")
    ) {
      res.status(400).json({ error: message, isSuccess: false });
      return;
    }

    res.status(500).json({
      error: "Failed to create post",
      message,
      isSuccess: false,
    });
  }
};
