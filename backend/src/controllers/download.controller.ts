import { Request, Response } from "express";
import prisma from "../config/prisma.js";

export async function downloadMusic(req: Request, res: Response) {
  try {
    const key = Array.isArray(req.params.key) ? req.params.key[0] : req.params.key;

    if (!key) {
      return res.status(400).json({
        success: false,
        message: "Download key is required",
      });
    }

    const item = await prisma.download.findUnique({
      where: {
        downloadKey: key,
      },
      include: {
        payment: true,
        music: true,
      },
    });

    if (!item) {
      return res.status(404).json({
        success: false,
        message: "Download link not found",
      });
    }

    if (item.payment.status !== "COMPLETED") {
      return res.status(403).json({
        success: false,
        message: "A successful payment is required",
      });
    }

    if (item.expiresAt && item.expiresAt < new Date()) {
      return res.status(403).json({
        success: false,
        message: "Download link has expired",
      });
    }

    if (!item.music.audioUrl) {
      return res.status(404).json({
        success: false,
        message: "Audio file is not available",
      });
    }

    await prisma.download.update({
      where: {
        id: item.id,
      },
      data: {
        downloadedAt: new Date(),
      },
    });

    return res.json({
      success: true,
      downloadUrl: item.music.audioUrl,
    });
  } catch (error) {
    console.error("Download music error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to process download",
    });
  }
}

export const getDownload = downloadMusic;