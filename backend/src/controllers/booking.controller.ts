import { Request, Response } from "express";
import prisma from "../config/prisma.js";

export async function getBookings(
  _req: Request,
  res: Response
) {
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
    console.error("Get bookings error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch bookings",
    });
  }
}

export async function getBookingById(
  req: Request,
  res: Response
) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking ID",
      });
    }

    const booking = await prisma.booking.findUnique({
      where: { id },
    });

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    return res.json({
      success: true,
      data: booking,
    });
  } catch (error) {
    console.error("Get booking error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch booking",
    });
  }
}

export async function createBooking(
  req: Request,
  res: Response
) {
  try {
    const {
      name,
      email,
      phone,
      eventDate,
      eventType,
      location,
      message,
      userId,
    } = req.body;

    if (
      !name ||
      !email ||
      !phone ||
      !eventDate ||
      !eventType ||
      !location
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Name, email, phone, event date, event type and location are required",
      });
    }

    const booking = await prisma.booking.create({
      data: {
        name,
        email,
        phone,
        eventDate: new Date(eventDate),
        eventType,
        location,
        message: message || null,
        userId: userId ? Number(userId) : null,
      },
    });

    return res.status(201).json({
      success: true,
      message: "Booking request submitted successfully",
      data: booking,
    });
  } catch (error) {
    console.error("Create booking error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create booking",
    });
  }
}

export async function updateBooking(
  req: Request,
  res: Response
) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking ID",
      });
    }

    const existingBooking = await prisma.booking.findUnique({
      where: { id },
    });

    if (!existingBooking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    const {
      name,
      email,
      phone,
      eventDate,
      eventType,
      location,
      message,
      status,
    } = req.body;

    const validStatuses = [
      "PENDING",
      "CONFIRMED",
      "CANCELLED",
      "COMPLETED",
    ];

    if (
      status !== undefined &&
      !validStatuses.includes(status)
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid booking status",
      });
    }

    const booking = await prisma.booking.update({
      where: { id },
      data: {
        ...(name !== undefined && { name }),
        ...(email !== undefined && { email }),
        ...(phone !== undefined && { phone }),
        ...(eventDate !== undefined && {
          eventDate: new Date(eventDate),
        }),
        ...(eventType !== undefined && { eventType }),
        ...(location !== undefined && { location }),
        ...(message !== undefined && {
          message: message || null,
        }),
        ...(status !== undefined && {
          status,
        }),
      },
    });

    return res.json({
      success: true,
      message: "Booking updated successfully",
      data: booking,
    });
  } catch (error) {
    console.error("Update booking error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update booking",
    });
  }
}

export async function deleteBooking(
  req: Request,
  res: Response
) {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking ID",
      });
    }

    const existingBooking = await prisma.booking.findUnique({
      where: { id },
    });

    if (!existingBooking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    await prisma.booking.delete({
      where: { id },
    });

    return res.json({
      success: true,
      message: "Booking deleted successfully",
    });
  } catch (error) {
    console.error("Delete booking error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to delete booking",
    });
  }
}