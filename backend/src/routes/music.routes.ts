import { Router } from "express";

import {
  getMusic,
  getMusicById,
  createMusic,
  updateMusic,
  deleteMusic,
} from "../controllers/music.controller.js";
import {
  authenticate,
  requireAdmin,
} from "../middleware/auth.middleware.js";

const router = Router();

router.get("/", getMusic);

router.get("/:id", getMusicById);

router.post("/", authenticate, requireAdmin, createMusic);

router.put("/:id", authenticate, requireAdmin, updateMusic);

router.delete("/:id", authenticate, requireAdmin, deleteMusic);

export default router;