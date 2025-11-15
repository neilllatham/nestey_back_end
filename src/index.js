// version market : github new repo

// src/index.js
import express from "express";
import cors from "cors";
import timeOffRoutes from "./routes/timeOff.js";
import benefitsRoutes from "./routes/benefits.js";
import chatRoutes from "./routes/chat.js";
import personalRoutes from "./routes/personal.js";
import reviewRoutes from "./routes/reviews.js";  // <-- Add reviews
import goalsRoutes from "./routes/goals.js";     // <-- Add goals

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("✅ Nestey backend is running");
});

// Register API routes
app.use("/api/timeoff", timeOffRoutes);
app.use("/api/benefits", benefitsRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/personal", personalRoutes);
app.use("/api/reviews", reviewRoutes); // <-- Correct prefix
app.use("/api/goals", goalsRoutes);    // <-- Add goals API

const PORT = process.env.PORT || 3001;
app.listen(PORT, () =>
  console.log(`🚀 Server running at http://localhost:${PORT}`)
);
