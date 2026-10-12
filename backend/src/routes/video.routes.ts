import { Router } from "express";

import {
  getVideos,
  getVideoById,
  createVideo,
  updateVideo,
  deleteVideo,
} from "../controllers/video.controller.js";

const router = Router();

router.get("/", getVideos);

router.get("/:id", getVideoById);

router.post("/", createVideo);

router.put("/:id", updateVideo);

router.delete("/:id", deleteVideo);

export default router;