import express from "express";
import { protect } from "../middleware/protect";
import {
  registerDevicePushToken,
  linkDeviceToUser,
  unlinkDeviceFromUser,
} from "../controller/devicePush";

const router = express.Router();

router.post("/register-push-token", registerDevicePushToken);
router.post("/link-user", protect, linkDeviceToUser);
router.post("/unlink-user", protect, unlinkDeviceFromUser);

export default router;
