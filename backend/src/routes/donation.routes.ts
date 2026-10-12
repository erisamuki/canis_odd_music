import { Router } from "express";

import {
  getDonations,
  getDonationById,
  createDonation,
  updateDonation,
  deleteDonation,
} from "../controllers/donation.controller.js";

const router = Router();

router.get("/", getDonations);
router.get("/:id", getDonationById);
router.post("/", createDonation);
router.put("/:id", updateDonation);
router.delete("/:id", deleteDonation);

export default router;