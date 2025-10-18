// backend/controllers/attendanceController.js
const Attendance = require('../models/Attendance');

/**
 * Mark attendance for a student in a session
 * POST /api/attendance/mark
 * body: { studentId, sessionId }
 */
async function markAttendance(req, res) {
  try {
    const { studentId, sessionId } = req.body;
    if (!studentId || !sessionId) {
      return res.status(400).json({ error: 'Missing studentId or sessionId' });
    }

    // Create attendance record (store studentId as string)
    const doc = await Attendance.create({
      studentId: String(studentId),
      sessionId: String(sessionId)
    });

    return res.json({ success: true, data: doc });
  } catch (err) {
    console.error('markAttendance error:', err);
    return res.status(500).json({ error: err.message || String(err) });
  }
}

/**
 * Get attendance for a class/session
 * GET /api/attendance/class/:sessionId
 */
async function getAttendanceByClass(req, res) {
  try {
    const { sessionId } = req.params;
    if (!sessionId) return res.status(400).json({ error: 'Missing sessionId' });

    const docs = await Attendance.find({ sessionId: String(sessionId) }).lean();
    return res.json({ data: docs });
  } catch (err) {
    console.error('getAttendanceByClass error:', err);
    return res.status(500).json({ error: err.message || String(err) });
  }
}

/**
 * Get attendance records for a specific student
 * GET /api/attendance/student/:studentId
 */
async function getAttendanceByStudent(req, res) {
  try {
    const { studentId } = req.params;
    if (!studentId) return res.status(400).json({ error: 'Missing studentId' });

    const docs = await Attendance.find({ studentId: String(studentId) }).lean();
    return res.json({ data: docs });
  } catch (err) {
    console.error('getAttendanceByStudent error:', err);
    return res.status(500).json({ error: err.message || String(err) });
  }
}

module.exports = { markAttendance, getAttendanceByClass, getAttendanceByStudent };
