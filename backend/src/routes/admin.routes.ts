import { Router } from "express";

import prisma from "../config/prisma.js";

import {
  authenticate,
  requireAdmin,
} from "../middleware/auth.middleware.js";

const router = Router();

router.use(authenticate);
router.use(requireAdmin);

/*
|--------------------------------------------------------------------------
| ADMIN DASHBOARD
|--------------------------------------------------------------------------
*/
router.get("/dashboard", async (_req, res) => {
  try {
    const [
      users,
      music,
      videos,
      bookings,
      payments,
      donations,
      downloads,
      musicEarnings,
    ] = await Promise.all([
      prisma.user.count(),
      prisma.music.count(),
      prisma.video.count(),
      prisma.booking.count(),
      prisma.payment.count(),
      prisma.donation.count(),
      prisma.download.count({
        where: {
          downloadedAt: {
            not: null,
          },
        },
      }),
      prisma.payment.aggregate({
        where: {
          status: "COMPLETED",
          musicId: {
            not: null,
          },
        },
        _sum: {
          amount: true,
        },
      }),
    ]);

    return res.json({
      success: true,
      dashboard: {
        users,
        music,
        videos,
        bookings,
        payments,
        donations,
        downloads,
        musicEarnings: musicEarnings._sum.amount ?? 0,
      },
    });
  } catch (error) {
    console.error("Admin dashboard error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load dashboard statistics",
    });
  }
});

/*
|--------------------------------------------------------------------------
| USERS
|--------------------------------------------------------------------------
*/
router.get("/users", async (_req, res) => {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.json({
      success: true,
      data: users,
    });
  } catch (error) {
    console.error("Admin users error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load users",
    });
  }
});

/*
|--------------------------------------------------------------------------|
| MUSIC
|--------------------------------------------------------------------------|
*/
router.get("/music", async (_req, res) => {
  try {
    const [music, downloadCounts] = await Promise.all([
      prisma.music.findMany({
        orderBy: {
          createdAt: "desc",
        },
      }),
      prisma.download.groupBy({
        by: ["musicId"],
        where: {
          downloadedAt: {
            not: null,
          },
        },
        _count: {
          _all: true,
        },
      }),
    ]);

    const downloadsByMusicId = new Map(
      downloadCounts.map(({ musicId, _count }) => [
        musicId,
        _count._all,
      ]),
    );

    return res.json({
      success: true,
      data: music.map((track) => ({
        ...track,
        downloadCount: downloadsByMusicId.get(track.id) ?? 0,
      })),
    });
  } catch (error) {
    console.error("Admin music error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load music",
    });
  }
});

/*
|--------------------------------------------------------------------------
| BOOKINGS
|--------------------------------------------------------------------------
*/
router.get("/bookings", async (_req, res) => {
  try {
    const bookings = await prisma.booking.findMany({
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    console.error("Admin bookings error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load bookings",
    });
  }
});

/*
|--------------------------------------------------------------------------
| PAYMENTS
|--------------------------------------------------------------------------
*/
router.get("/payments", async (_req, res) => {
  try {
    const payments = await prisma.payment.findMany({
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.json({
      success: true,
      data: payments,
    });
  } catch (error) {
    console.error("Admin payments error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load payments",
    });
  }
});

/*
|--------------------------------------------------------------------------
| DONATIONS
|--------------------------------------------------------------------------
*/
router.get("/donations", async (_req, res) => {
  try {
    const donations = await prisma.donation.findMany({
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.json({
      success: true,
      data: donations,
    });
  } catch (error) {
    console.error("Admin donations error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load donations",
    });
  }
});

/*
|--------------------------------------------------------------------------
| DOWNLOADS
|--------------------------------------------------------------------------
*/
router.get("/downloads", async (_req, res) => {
  try {
    const downloads = await prisma.download.findMany({
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.json({
      success: true,
      data: downloads,
    });
  } catch (error) {
    console.error("Admin downloads error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load downloads",
    });
  }
});

/*
|--------------------------------------------------------------------------
| HOMEPAGE CONTENT
|--------------------------------------------------------------------------
*/
router.get("/homepage", async (_req, res) => {
  try {
    const [sliders, socialLinks, siteSettings] = await Promise.all([
      prisma.slider.findMany({
        orderBy: {
          sortOrder: "asc",
        },
      }),
      prisma.socialLink.findMany({
        where: {
          isActive: true,
        },
        orderBy: {
          platform: "asc",
        },
      }),
      prisma.siteSetting.findMany({
        orderBy: {
          key: "asc",
        },
      }),
    ]);

    return res.json({
      success: true,
      data: {
        sliders,
        socialLinks,
        siteSettings,
      },
    });
  } catch (error) {
    console.error("Admin homepage error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load homepage content",
    });
  }
});

/*
|--------------------------------------------------------------------------
| SITE SETTINGS
|--------------------------------------------------------------------------
*/
router.get("/settings", async (_req, res) => {
  try {
    const settings = await prisma.siteSetting.findMany({
      orderBy: {
        key: "asc",
      },
    });

    return res.json({
      success: true,
      data: settings,
    });
  } catch (error) {
    console.error("Admin settings error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to load site settings",
    });
  }
});

export default router;