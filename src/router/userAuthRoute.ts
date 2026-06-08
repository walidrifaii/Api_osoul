import express from "express";
import { registerUser, Login } from "../controller/userAuth";
import { LoginAdmin, RegAdmin } from "../controller/adminAuth";
import { verfiyUser, deleteUser } from "../controller/userAuth";
import { SendOTPController } from "../controller/userAuth";
const router = express.Router();

router.post("/register", registerUser);
router.post("/login", Login);
router.post("/admin-reg", RegAdmin);
router.post("/admin-login", LoginAdmin);
router.post("/verfiy-phone", verfiyUser);
router.post("/delete-user", deleteUser);
router.post("/send-otp", SendOTPController);
export default router;
