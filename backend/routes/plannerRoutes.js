// backend/routes/plannerRoutes.js
const express = require('express');
const router = express.Router();
const { upsertPlanner, getPlanner } = require('../controllers/plannerController');

router.post('/upsert', upsertPlanner);
router.get('/:studentId/:date', getPlanner);

module.exports = router;
