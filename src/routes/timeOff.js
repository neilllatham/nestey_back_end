// src/routes/timeOff.js
import express from "express";
import prisma from "../prisma/client.js";

const router = express.Router();

// GET all time-off requests
router.get("/", async (req, res) => {
  try {
    const requests = await prisma.timeOff.findMany({
      include: { employee: true },
      orderBy: { created_at: "desc" },
    });
    res.json(requests);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST new request
router.post("/", async (req, res) => {
  try {
    const { employee_id, start_date, end_date, reason } = req.body;
    const days_requested =
      (new Date(end_date) - new Date(start_date)) / (1000 * 60 * 60 * 24) + 1;

    const newRequest = await prisma.timeOff.create({
      data: {
        employee_id,
        start_date: new Date(start_date),
        end_date: new Date(end_date),
        days_requested,
        reason,
      },
    });

    res.json(newRequest);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT update status
router.put("/:id", async (req, res) => {
  try {
    const { status } = req.body;
    const updated = await prisma.timeOff.update({
      where: { id: Number(req.params.id) },
      data: { status },
    });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
