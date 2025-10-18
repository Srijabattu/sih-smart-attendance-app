// backend/routes/attendanceRoutes.js
const express = require('express');
const router = express.Router();

// controller
const attendanceController = require('../controllers/attendanceController');

// POST /api/attendance/mark
router.post('/mark', attendanceController.markAttendance);

// GET /api/attendance/class/:sessionId
router.get('/class/:sessionId', attendanceController.getAttendanceByClass);

// GET /api/attendance/student/:studentId
router.get('/student/:studentId', attendanceController.getAttendanceByStudent);

module.exports = router;
