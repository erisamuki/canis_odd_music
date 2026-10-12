import { Request, Response } from "express";
import prisma from "../config/prisma.js";

export async function getDonations(
  _req: Request,
  res: Response
) {
  try {
    const donations = await prisma.donation.findMany({
      include: {
        payment: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.json({
      success: true,
      data: donations,
    });
  } catch (error) {
    console.error("Get donations error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch donations",
    });
  }
}

export async function getDonationById(
  req: Request,
  res: Response
) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid donation ID",
      });
    }

    const donation = await prisma.donation.findUnique({
      where: { id },
      include: {
        payment: true,
      },
    });

    if (!donation) {
      return res.status(404).json({
        success: false,
        message: "Donation not found",
      });
    }

    return res.json({
      success: true,
      data: donation,
    });
  } catch (error) {
    console.error("Get donation error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch donation",
    });
  }
}

export async function createDonation(
  req: Request,
  res: Response
) {
  try {
    const amount = Number(req.body.amount);

    if (!Number.isInteger(amount) || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: "A valid donation amount is required",
      });
    }

    const donation = await prisma.donation.create({
      data: {
        amount,
        name: req.body.name || null,
        email: req.body.email || null,
        message: req.body.message || null,
      },
    });

    return res.status(201).json({
      success: true,
      message: "Donation created successfully",
      data: donation,
    });
  } catch (error) {
    console.error("Create donation error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create donation",
    });
  }
}

export async function updateDonation(
  req: Request,
  res: Response
) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid donation ID",
      });
    }

    const existingDonation =
      await prisma.donation.findUnique({
        where: { id },
      });

    if (!existingDonation) {
      return res.status(404).json({
        success: false,
        message: "Donation not found",
      });
    }

    const amount =
      req.body.amount !== undefined
        ? Number(req.body.amount)
        : undefined;

    if (
      amount !== undefined &&
      (!Number.isInteger(amount) || amount <= 0)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid donation amount",
      });
    }

    const donation = await prisma.donation.update({
      where: { id },
      data: {
        ...(amount !== undefined && { amount }),
        ...(req.body.name !== undefined && {
          name: req.body.name || null,
        }),
        ...(req.body.email !== undefined && {
          email: req.body.email || null,
        }),
        ...(req.body.message !== undefined && {
          message: req.body.message || null,
        }),
      },
    });

    return res.json({
      success: true,
      message: "Donation updated successfully",
      data: donation,
    });
  } catch (error) {
    console.error("Update donation error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update donation",
    });
  }
}

export async function deleteDonation(
  req: Request,
  res: Response
) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid donation ID",
      });
    }

    const existingDonation =
      await prisma.donation.findUnique({
        where: { id },
      });

    if (!existingDonation) {
      return res.status(404).json({
        success: false,
        message: "Donation not found",
      });
    }

    await prisma.donation.delete({
      where: { id },
    });

    return res.json({
      success: true,
      message: "Donation deleted successfully",
    });
  } catch (error) {
    console.error("Delete donation error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to delete donation",
    });
  }
}