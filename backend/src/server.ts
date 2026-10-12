import path from "path";
import "dotenv/config";
import express from "express";
import cors from "cors";
import helmet from "helmet";

import authRoutes from "./routes/auth.routes.js";
import musicRoutes from "./routes/music.routes.js";
import videoRoutes from "./routes/video.routes.js";
import bookingRoutes from "./routes/booking.routes.js";
import donationRoutes from "./routes/donation.routes.js";
import paymentRoutes from "./routes/payment.routes.js";
import adminRoutes from "./routes/admin.routes.js";
import downloadRoutes from "./routes/download.routes.js";
import uploadRoutes from "./routes/upload.routes.js";

const app = express();

const PORT = Number(process.env.PORT) || 5000;

const uploadRoot = path.join(process.cwd(), "uploads");
console.log("UPLOAD ROOT:", uploadRoot);

app.use(
  helmet({
    crossOriginResourcePolicy: {
      policy: "cross-origin",
    },
  }),
);
app.use(cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files
app.use("/uploads", express.static(uploadRoot));

app.get("/api/health", (_req, res) => {
  res.json({
    success: true,
    message: "CANIS ODD MUSIC API is running",
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/music", musicRoutes);
app.use("/api/videos", videoRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/donations", donationRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/downloads", downloadRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/uploads", uploadRoutes);

// 404 handler must remain last
app.use((_req, res) => {
  res.status(404).json({
    success: false,
    message: "API endpoint not found",
  });
});

app.listen(PORT, () => {
  console.log(
    `CANIS ODD MUSIC API running on http://localhost:${PORT}`
  );
});




