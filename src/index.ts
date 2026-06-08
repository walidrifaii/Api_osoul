import dotenv from "dotenv";
dotenv.config();

import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import cors from "cors";
import { connectDB } from "./config/dp";
import { protect } from "./middleware/protect";

//routes
import authRoute from "./router/userAuthRoute";
import CreateRoute from "./router/createRoute";
import {
  publicPostsRouter,
  protectedPostsRouter,
} from "./router/getPosts";
import {
  publicPostDetRouter,
  protectedPostDetRouter,
} from "./router/getPostDetRouter";
import { publicAdminRouter, protectedAdminRouter } from "./router/adminControlRoute";

const PORT = process.env.PORT || 3000;

/* Configeration */
const app = express();
connectDB();
app.use(helmet());
app.use(helmet.crossOriginResourcePolicy({ policy: "cross-origin" }));
app.use(morgan("common"));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: false, limit: "10mb" }));
app.use(
  cors({
    origin: ["https://www.osoulqatar.com", "http://localhost:8082", "http://localhost:3000"],
    methods: ["GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
    optionsSuccessStatus: 200,
  })
);

// app test
app.get("/", (_req, res) => {
  res.json({ message: "Server is running" });
});

// Public routes (no auth required)
app.use("/auth", authRoute);
app.use("/", publicPostsRouter);
app.use("/", publicPostDetRouter);
app.use("/", publicAdminRouter);

// Protected routes (auth required)
app.use("/", protect, CreateRoute);
app.use("/", protect, protectedPostsRouter);
app.use("/", protect, protectedPostDetRouter);
app.use("/", protect, protectedAdminRouter);

// Server
function startServer(port: number) {
  const server = app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });

  server.on("error", (err: any) => {
    if (err.code === "EADDRINUSE") {
      console.log(`Port ${port} is in use, trying port ${port + 1}...`);
      startServer(port + 1);
    } else {
      console.error("Server error:", err);
    }
  });
}

startServer(Number(PORT));
