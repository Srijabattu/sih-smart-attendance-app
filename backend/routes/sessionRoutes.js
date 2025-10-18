// backend/routes/sessionRoutes.js
const express = require('express');
const router = express.Router();
const Session = require('../models/Session');
const Attendance = require('../models/Attendance');

function generateSessionId(classId) {
  const rand = Math.floor(Math.random() * 900000) + 100000;
  return `${classId}_${rand}`;
}

// POST /api/session/create
// body: { classId, teacherId, ttlMinutes (optional) }
router.post('/create', async (req, res) => {
  try {
    const { classId, teacherId, ttlMinutes } = req.body;
    if (!classId || !teacherId) return res.status(400).json({ error: 'Missing fields' });

    const sessionId = generateSessionId(classId);
    const ttl = typeof ttlMinutes === 'number' ? ttlMinutes : 10; // default 10 minutes
    const expiresAt = new Date(Date.now() + ttl * 60 * 1000);

    const session = await Session.create({ sessionId, classId, teacherId, expiresAt });
    return res.json({ sessionId: session.sessionId, classId: session.classId, expiresAt: session.expiresAt });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/session/:sessionId/attendees
router.get('/:sessionId/attendees', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = await Session.findOne({ sessionId });
    if (!session) return res.status(404).json({ error: 'Session not found' });

    const attendees = await Attendance.find({ sessionId }).sort({ timestamp: 1 });
    return res.json({ session: { sessionId: session.sessionId, classId: session.classId, expiresAt: session.expiresAt }, attendees });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
