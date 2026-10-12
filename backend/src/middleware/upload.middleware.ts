import multer from "multer";
import path from "path";
import fs from "fs";

const musicUploadPath = path.join(
  process.cwd(),
  "uploads",
  "music"
);

if (!fs.existsSync(musicUploadPath)) {
  fs.mkdirSync(musicUploadPath, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, musicUploadPath);
  },

  filename: (_req, file, cb) => {
    const extension = path.extname(
      file.originalname
    ).toLowerCase();

    const safeName = path
      .basename(file.originalname, extension)
      .replace(/[^a-zA-Z0-9-_]/g, "-")
      .toLowerCase();

    const filename = `${Date.now()}-${safeName}${extension}`;

    cb(null, filename);
  },
});

const fileFilter: multer.Options["fileFilter"] = (
  _req,
  file,
  cb
) => {
  const allowedMimeTypes = [
    "audio/mpeg",
    "audio/mp3",
    "audio/wav",
    "audio/x-wav",
    "application/octet-stream",
  ];

  const allowedExtensions = [".mp3", ".wav"];

  const extension = path
    .extname(file.originalname)
    .toLowerCase();

  if (
    allowedMimeTypes.includes(file.mimetype) &&
    allowedExtensions.includes(extension)
  ) {
    cb(null, true);
    return;
  }

  cb(
    new Error(
      "Only MP3 and WAV audio files are allowed"
    )
  );
};

export const uploadMusic = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 50 * 1024 * 1024,
  },
});