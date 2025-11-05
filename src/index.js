// version market : github new repo

// src/index.js
import express from "express";
import cors from "cors";
import timeOffRoutes from "./routes/timeOff.js";
import benefitsRoutes from "./routes/benefits.js";
import chatRoutes from "./routes/chat.js";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("✅ Nestey backend is running");
});

app.use("/api/timeoff", timeOffRoutes);
app.use("/api/benefits", benefitsRoutes);
app.use("/api/chat", chatRoutes);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () =>
  console.log(`🚀 Server running at http://localhost:${PORT}`)
);
