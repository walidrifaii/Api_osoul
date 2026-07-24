import express, { NextFunction, Request, Response } from "express";
import { createPost } from "../controller/createPost";
import multer from "multer";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB per file
    files: 4, // max 4 files
  },
  fileFilter: (_req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed"));
    }
  },
});

const router = express.Router();

function handleMulterUpload(req: Request, res: Response, next: NextFunction) {
  upload.array("images", 4)(req, res, (err: unknown) => {
    if (!err) {
      next();
      return;
    }

    if (err instanceof multer.MulterError) {
      if (err.code === "LIMIT_FILE_SIZE") {
        res.status(400).json({
          error: "Each image must be 5MB or smaller",
          isSuccess: false,
        });
        return;
      }
      if (err.code === "LIMIT_FILE_COUNT" || err.code === "LIMIT_UNEXPECTED_FILE") {
        res.status(400).json({
          error: "Maximum 4 images allowed per post",
          isSuccess: false,
        });
        return;
      }
      res.status(400).json({ error: err.message, isSuccess: false });
      return;
    }

    const message =
      err instanceof Error ? err.message : "Invalid image upload";
    res.status(400).json({ error: message, isSuccess: false });
  });
}

router.post("/create-post", handleMulterUpload, createPost);

export default router;
