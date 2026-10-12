import { Router } from "express";

import { uploadMusic } from "../middleware/upload.middleware.js";
import { uploadMusicFile } from "../controllers/upload.controller.js";
import {
  authenticate,
  requireAdmin,
} from "../middleware/auth.middleware.js";

const router = Router();

router.post(
  "/music",
  authenticate,
  requireAdmin,
  uploadMusic.single("audio"),
  uploadMusicFile
);

export default router;