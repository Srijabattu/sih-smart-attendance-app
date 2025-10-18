// backend/models/Session.js
const mongoose = require('mongoose');

const SessionSchema = new mongoose.Schema({
  sessionId: { type: String, required: true, unique: true },
  classId: { type: String, required: true },
  teacherId: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  expiresAt: { type: Date }, // set when creating
  active: { type: Boolean, default: true }
});

module.exports = mongoose.model('Session', SessionSchema);
