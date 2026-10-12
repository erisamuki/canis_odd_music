import { Router } from "express";

import {
  createMusicPayment,
  createDownloadPayment,
  createDonationPayment,
  completePayment,
} from "../controllers/payment.controller.js";

const router = Router();

router.post("/music/:musicId", createMusicPayment);

router.post("/download/:musicId", createDownloadPayment);

router.post("/donation", createDonationPayment);

router.post("/complete/:reference", completePayment);

export default router;