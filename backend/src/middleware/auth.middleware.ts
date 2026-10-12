import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "change-this-secret";

export interface AuthRequest extends Request {
  user?: {
    id: number;
    email: string;
    role: string;
  };
}

export function authenticate(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  const authorization = req.headers.authorization;

  if (!authorization) {
    return res.status(401).json({
      success: false,
      message: "Authentication required",
    });
  }

  const [scheme, token] = authorization.split(" ");

  if (scheme !== "Bearer" || !token) {
    return res.status(401).json({
      success: false,
      message: "Invalid authorization header",
    });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);

    if (
      typeof decoded !== "object" ||
      decoded === null ||
      typeof decoded.id !== "number" ||
      typeof decoded.email !== "string" ||
      typeof decoded.role !== "string"
    ) {
      return res.status(401).json({
        success: false,
        message: "Invalid token payload",
      });
    }

    req.user = {
      id: decoded.id,
      email: decoded.email,
      role: decoded.role,
    };

    next();
  } catch {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
}

export function requireAdmin(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: "Authentication required",
    });
  }

  if (req.user.role !== "ADMIN") {
    return res.status(403).json({
      success: false,
      message: "Admin access required",
    });
  }

  next();
}