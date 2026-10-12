import { Router } from "express";
import { downloadMusic } from "../controllers/download.controller.js";

const router = Router();

router.get("/:key", downloadMusic);

export default router;