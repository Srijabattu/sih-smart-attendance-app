// backend/models/Planner.js
const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
  id: { type: String, required: true },
  title: { type: String, default: '' },
  description: { type: String, default: '' },
  startTime: { type: String, default: '' },
  endTime: { type: String, default: '' },
  durationMinutes: { type: Number, default: 0 },
  tags: { type: [String], default: [] },
  completed: { type: Boolean, default: false },
  source: { type: String, default: 'manual' }
}, { _id: false });

const PlannerSchema = new mongoose.Schema({
  studentId: { type: String, required: true }, // store as string for simplicity
  date: { type: String, required: true }, // yyyy-MM-dd
  tasks: { type: [TaskSchema], default: [] }
}, { timestamps: true });

module.exports = mongoose.models.Planner || mongoose.model('Planner', PlannerSchema);
