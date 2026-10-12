import { Request, Response } from "express";
import prisma from "../config/prisma.js";

export async function getVideos(req: Request, res: Response) {
  try {
    const videos = await prisma.video.findMany({
      where: {
        isPublished: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.json({
      success: true,
      data: videos,
    });
  } catch (error) {
    console.error("Get videos error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch videos",
    });
  }
}

export async function getVideoById(req: Request, res: Response) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid video ID",
      });
    }

    const video = await prisma.video.findUnique({
      where: {
        id,
      },
    });

    if (!video) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    return res.json({
      success: true,
      data: video,
    });
  } catch (error) {
    console.error("Get video error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch video",
    });
  }
}

export async function createVideo(req: Request, res: Response) {
  try {
    const {
      title,
      description,
      thumbnail,
      videoUrl,
      isPublished,
    } = req.body;

    if (!title || !videoUrl) {
      return res.status(400).json({
        success: false,
        message: "Title and video URL are required",
      });
    }

    const video = await prisma.video.create({
      data: {
        title,
        description: description || null,
        thumbnail: thumbnail || null,
        videoUrl,
        isPublished:
          isPublished !== undefined
            ? Boolean(isPublished)
            : true,
      },
    });

    return res.status(201).json({
      success: true,
      message: "Video created successfully",
      data: video,
    });
  } catch (error) {
    console.error("Create video error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create video",
    });
  }
}

export async function updateVideo(req: Request, res: Response) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid video ID",
      });
    }

    const existingVideo = await prisma.video.findUnique({
      where: {
        id,
      },
    });

    if (!existingVideo) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    const {
      title,
      description,
      thumbnail,
      videoUrl,
      isPublished,
    } = req.body;

    const video = await prisma.video.update({
      where: {
        id,
      },
      data: {
        ...(title !== undefined && { title }),
        ...(description !== undefined && {
          description: description || null,
        }),
        ...(thumbnail !== undefined && {
          thumbnail: thumbnail || null,
        }),
        ...(videoUrl !== undefined && { videoUrl }),
        ...(isPublished !== undefined && {
          isPublished: Boolean(isPublished),
        }),
      },
    });

    return res.json({
      success: true,
      message: "Video updated successfully",
      data: video,
    });
  } catch (error) {
    console.error("Update video error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update video",
    });
  }
}

export async function deleteVideo(req: Request, res: Response) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid video ID",
      });
    }

    const existingVideo = await prisma.video.findUnique({
      where: {
        id,
      },
    });

    if (!existingVideo) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    await prisma.video.delete({
      where: {
        id,
      },
    });

    return res.json({
      success: true,
      message: "Video deleted successfully",
    });
  } catch (error) {
    console.error("Delete video error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to delete video",
    });
  }
}