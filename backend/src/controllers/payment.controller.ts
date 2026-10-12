import { Request, Response } from "express";
import crypto from "crypto";
import prisma from "../config/prisma.js";

const DOWNLOAD_PRICE = 700;

export async function createMusicPayment(
  req: Request,
  res: Response
) {
  try {
    const musicId = Number(req.params.musicId);

    if (!Number.isInteger(musicId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid music ID",
      });
    }

    const music = await prisma.music.findUnique({
      where: { id: musicId },
    });

    if (!music) {
      return res.status(404).json({
        success: false,
        message: "Music not found",
      });
    }

    const payment = await prisma.payment.create({
      data: {
        reference: `MUSIC-${Date.now()}-${musicId}`,
        amount: music.price || DOWNLOAD_PRICE,
        method:
          req.body.method === "CARD"
            ? "CARD"
            : "MOBILE_MONEY",
        phone: req.body.phone || null,
        email: req.body.email || null,
        musicId: music.id,
      },
    });

    return res.status(201).json({
      success: true,
      reference: payment.reference,
      amount: payment.amount,
      status: payment.status,
      message:
        "Payment request created. Connect the selected provider to complete payment.",
    });
  } catch (error) {
    console.error("Create music payment error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create payment",
    });
  }
}

export const createDownloadPayment = createMusicPayment;

export async function createDonationPayment(
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

    const payment = await prisma.payment.create({
      data: {
        reference: `DONATION-${Date.now()}`,
        amount,
        method:
          req.body.method === "CARD"
            ? "CARD"
            : "MOBILE_MONEY",
        phone: req.body.phone || null,
        email: req.body.email || null,
      },
    });

    await prisma.donation.create({
      data: {
        amount,
        name: req.body.name || null,
        email: req.body.email || null,
        message: req.body.message || null,
        paymentId: payment.id,
      },
    });

    return res.status(201).json({
      success: true,
      reference: payment.reference,
      amount: payment.amount,
      status: payment.status,
      message: "Donation payment request created.",
    });
  } catch (error) {
    console.error("Create donation payment error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create donation payment",
    });
  }
}

export async function completePayment(
  req: Request,
  res: Response
) {
  try {
    const reference = Array.isArray(req.params.reference)
      ? req.params.reference[0]
      : req.params.reference;

    if (!reference) {
      return res.status(400).json({
        success: false,
        message: "Payment reference is required",
      });
    }

    const payment = await prisma.payment.findUnique({
      where: { reference },
      include: {
        music: true,
        downloads: true,
      },
    });

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: "Payment not found",
      });
    }

    /*
     * If payment was already completed, return
     * the existing download key instead of creating
     * another download record.
     */
    if (payment.status === "COMPLETED") {
      const existingDownload = payment.downloads[0] || null;

      return res.json({
        success: true,
        message: "Payment is already completed",
        payment,
        download: existingDownload
          ? {
              downloadKey: existingDownload.downloadKey,
              expiresAt: existingDownload.expiresAt,
            }
          : null,
      });
    }

    const updatedPayment = await prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: "COMPLETED",
      },
    });

    let download = null;

    if (payment.musicId && payment.music) {
      download = await prisma.download.create({
        data: {
          musicId: payment.musicId,
          paymentId: payment.id,
          downloadKey: crypto.randomBytes(32).toString("hex"),
          expiresAt: new Date(
            Date.now() + 24 * 60 * 60 * 1000
          ),
        },
      });
    }

    return res.json({
      success: true,
      message: "Payment completed successfully",
      payment: updatedPayment,
      download: download
        ? {
            downloadKey: download.downloadKey,
            expiresAt: download.expiresAt,
          }
        : null,
    });
  } catch (error) {
    console.error("Complete payment error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to complete payment",
    });
  }
}