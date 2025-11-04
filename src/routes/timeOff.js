// src/routes/timeOff.js
import express from "express";
import prisma from "../prisma/client.js";

const router = express.Router();

// GET all time-off requests
router.get("/", async (req, res) => {
  try {
    const requests = await prisma.time_off_requests.findMany({
      include: { employees: true },
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
    const { employee_id, start_date, end_date, type } = req.body;

    if (!employee_id || !start_date || !end_date || !type) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const start = new Date(start_date);
    const end = new Date(end_date);

    if (isNaN(start) || isNaN(end)) {
      return res.status(400).json({ error: "Invalid date format" });
    }

    if (end < start) {
      return res.status(400).json({ error: "end_date must be on or after start_date" });
    }

    const msPerDay = 1000 * 60 * 60 * 24;
    const days_requested = Math.round((end - start) / msPerDay) + 1;

    const newRequest = await prisma.time_off_requests.create({
      data: {
        employee_id: Number(employee_id),
        type,
        start_date: start,
        end_date: end,
        days_requested: Number(days_requested),
        status: "Pending",
      },
    });

    res.status(201).json(newRequest);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET balance for an employee
router.get("/balance", async (req, res) => {
  try {
    const { employee_id } = req.query;
    if (!employee_id) {
      return res.status(400).json({ error: "Missing employee_id query parameter" });
    }

    // Defensive: if the Prisma model isn't present, return diagnostics
    if (!prisma.time_off_accruals) {
      // expose the available top-level keys on the client to help debugging
      const keys = Object.keys(prisma).filter((k) => typeof prisma[k] !== "function" ? true : true);
      return res.status(500).json({ error: "Prisma model time_off_accruals is not available", models: keys });
    }

    const accruals = await prisma.time_off_accruals.findMany({
      where: { employee_id: Number(employee_id) },
      orderBy: { year: "desc" },
    });

    // summarize by type
    const summary = accruals.reduce((acc, a) => {
      const t = a.type ?? "Unknown";
      const accrued = a.accrued_days ? Number(a.accrued_days) : 0;
      const used = a.used_days ? Number(a.used_days) : 0;
      const remaining = a.remaining_days ? Number(a.remaining_days) : accrued - used;

      if (!acc[t]) acc[t] = { total_accrued: 0, total_used: 0, total_remaining: 0, by_year: [] };
      acc[t].total_accrued += accrued;
      acc[t].total_used += used;
      acc[t].total_remaining += remaining;
      acc[t].by_year.push({ year: a.year, accrued_days: accrued, used_days: used, remaining_days: remaining });
      return acc;
    }, {});

    res.json({ accruals, summary });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT update status
router.put("/:id", async (req, res) => {
  try {
    const { status } = req.body;
    if (!status) return res.status(400).json({ error: "Missing status" });

    const updated = await prisma.time_off_requests.update({
      where: { request_id: Number(req.params.id) },
      data: { status },
    });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
