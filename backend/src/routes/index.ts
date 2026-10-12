import { Router } from "express";
import {
  getMusic,
  getMusicById,
  createMusic,
} from "../controllers/music.controller.js";

const router = Router();

router.get("/music", getMusic);

router.get("/music/:id", getMusicById);

router.post("/music", createMusic);

export default router;