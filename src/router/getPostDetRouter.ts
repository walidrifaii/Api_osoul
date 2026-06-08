import express from "express";
import {
  editPost,
  getPostDet,
  incrementViewCount,
} from "../controller/getPostDetails";
import { deletePost } from "../controller/userPosts";

// Public routes (no auth required)
export const publicPostDetRouter = express.Router();
publicPostDetRouter.post("/post-details", getPostDet);
publicPostDetRouter.patch("/increment-view", incrementViewCount);

// Protected routes (auth required - protect middleware applied in index.ts)
export const protectedPostDetRouter = express.Router();
protectedPostDetRouter.put("/edit-post/:id", editPost);
protectedPostDetRouter.delete("/delete-post/:id", deletePost);
