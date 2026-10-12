import { Request, Response } from "express";
import path from "path";

export async function uploadMusicFile(
  req: Request,
  res: Response
) {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No music file uploaded",
      });
    }

    const fileUrl = `/uploads/music/${req.file.filename}`;

    return res.status(201).json({
      success: true,
      message: "Music file uploaded successfully",
      data: {
        filename: req.file.filename,
        originalName: req.file.originalname,
        size: req.file.size,
        mimeType: req.file.mimetype,
        url: fileUrl,
      },
    });
  } catch (error) {
    console.error("Music upload error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to upload music file",
    });
  }
}