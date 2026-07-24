import express, { NextFunction, Request, Response } from "express";
import { createPost } from "../controller/createPost";
import multer from "multer";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    // Phone photos (esp. iPhone) are often well above 5MB.
    fileSize: 20 * 1024 * 1024,
    files: 8,
  },
  fileFilter: (_req, file, cb) => {
    const mime = (file.mimetype || "").toLowerCase();
    const name = (file.originalname || "").toLowerCase();
    const isImageMime = mime.startsWith("image/");
    const isHeicName =
      name.endsWith(".heic") ||
      name.endsWith(".heif") ||
      mime === "image/heic" ||
      mime === "image/heif" ||
      mime === "application/octet-stream";

    if (isImageMime || isHeicName) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed"));
    }
  },
});

const router = express.Router();

function handleMulterUpload(req: Request, res: Response, next: NextFunction) {
  // .any() accepts images/image/photos field names used by different clients.
  upload.any()(req, res, (err: unknown) => {
    if (!err) {
      next();
      return;
    }

    if (err instanceof multer.MulterError) {
      if (err.code === "LIMIT_FILE_SIZE") {
        res.status(400).json({
          error: "Each image must be 20MB or smaller",
          message: "Each image must be 20MB or smaller",
          isSuccess: false,
          success: false,
        });
        return;
      }
      if (err.code === "LIMIT_FILE_COUNT") {
        res.status(400).json({
          error: "Maximum 4 images allowed per post",
          message: "Maximum 4 images allowed per post",
          isSuccess: false,
          success: false,
        });
        return;
      }
      res.status(400).json({
        error: err.message,
        message: err.message,
        isSuccess: false,
        success: false,
      });
      return;
    }

    const message =
      err instanceof Error ? err.message : "Invalid image upload";
    res.status(400).json({
      error: message,
      message,
      isSuccess: false,
      success: false,
    });
  });
}

router.post("/create-post", handleMulterUpload, createPost);

export default router;
