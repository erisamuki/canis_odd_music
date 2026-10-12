import { Request, Response } from "express";
import prisma from "../config/prisma.js";

export async function getMusic(req: Request, res: Response) {
  try {
    const music = await prisma.music.findMany({
      where: {
        isPublished: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.json({
      success: true,
      data: music,
    });
  } catch (error) {
    console.error("Get music error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch music",
    });
  }
}

export async function getMusicById(req: Request, res: Response) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid music ID",
      });
    }

    const music = await prisma.music.findUnique({
      where: {
        id,
      },
    });

    if (!music) {
      return res.status(404).json({
        success: false,
        message: "Music not found",
      });
    }

    return res.json({
      success: true,
      data: music,
    });
  } catch (error) {
    console.error("Get music by ID error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch music",
    });
  }
}

export async function createMusic(req: Request, res: Response) {
  try {
    const {
      title,
      artist,
      description,
      coverImage,
      audioUrl,
      price,
      isPublished,
    } = req.body;

    if (!title || !audioUrl) {
      return res.status(400).json({
        success: false,
        message: "Title and audio URL are required",
      });
    }

    const music = await prisma.music.create({
      data: {
        title,
        artist: artist || null,
        description: description || null,
        coverImage: coverImage || null,
        audioUrl,
        price:
          price !== undefined
            ? Number(price)
            : 700,
        isPublished:
          isPublished !== undefined
            ? Boolean(isPublished)
            : true,
      },
    });

    return res.status(201).json({
      success: true,
      message: "Music created successfully",
      data: music,
    });
  } catch (error) {
    console.error("Create music error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create music",
    });
  }
}

export async function updateMusic(req: Request, res: Response) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid music ID",
      });
    }

    const existingMusic = await prisma.music.findUnique({
      where: {
        id,
      },
    });

    if (!existingMusic) {
      return res.status(404).json({
        success: false,
        message: "Music not found",
      });
    }

    const {
      title,
      artist,
      description,
      coverImage,
      audioUrl,
      price,
      isPublished,
    } = req.body;

    const music = await prisma.music.update({
      where: {
        id,
      },
      data: {
        ...(title !== undefined && { title }),
        ...(artist !== undefined && {
          artist: artist || null,
        }),
        ...(description !== undefined && {
          description: description || null,
        }),
        ...(coverImage !== undefined && {
          coverImage: coverImage || null,
        }),
        ...(audioUrl !== undefined && { audioUrl }),
        ...(price !== undefined && {
          price: Number(price),
        }),
        ...(isPublished !== undefined && {
          isPublished: Boolean(isPublished),
        }),
      },
    });

    return res.json({
      success: true,
      message: "Music updated successfully",
      data: music,
    });
  } catch (error) {
    console.error("Update music error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update music",
    });
  }
}

export async function deleteMusic(req: Request, res: Response) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid music ID",
      });
    }

    const existingMusic = await prisma.music.findUnique({
      where: {
        id,
      },
    });

    if (!existingMusic) {
      return res.status(404).json({
        success: false,
        message: "Music not found",
      });
    }

    await prisma.music.delete({
      where: {
        id,
      },
    });

    return res.json({
      success: true,
      message: "Music deleted successfully",
    });
  } catch (error) {
    console.error("Delete music error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to delete music",
    });
  }
}