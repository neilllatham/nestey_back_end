// src/routes/reviews.js
import express from "express";
import prisma from "../prisma/client.js";

const router = express.Router();

// Test mode override
const TEST_MODE = process.env.TEST_MODE === "true";

function canEdit(review) {
  if (TEST_MODE) return true;
  return review.review_status === "Draft";
}

router.get("/test", (req, res) => {
  res.send("Reviews route OK");
});

router.put("/:id", async (req, res) => {
  try {
    const reviewId = Number(req.params.id);

    // Use correct model name and primary key field
    const review = await prisma.employee_reviews.findUnique({
      where: { review_id: reviewId }
    });

    if (!review) {
      return res.status(404).json({ error: "Review not found" });
    }

    if (!canEdit(review)) {
      return res.status(403).json({ error: "Review is locked." });
    }

    const updated = await prisma.employee_reviews.update({
      where: { review_id: reviewId },
      data: {
        employee_overall_comments: req.body.employee_overall_comments,
        manager_overall_comments: req.body.manager_overall_comments,
        employee_overall_rating: req.body.employee_overall_rating,
        manager_overall_rating: req.body.manager_overall_rating
      }
    });

    res.json(updated);

  } catch (err) {
    console.error("Update error:", err);
    res.status(500).json({ error: "Failed to update review", details: err.message });
  }
});

export default router;
