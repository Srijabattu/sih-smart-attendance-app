// backend/controllers/plannerController.js
const Planner = require('../models/Planner');

/**
 * Upsert planner: push a task into planner.tasks for (studentId, date)
 * Request body: { studentId: string, date: string, task: object }
 * Response: { success: true, planner: <updated_doc> } on success
 */
exports.upsertPlanner = async (req, res) => {
  try {
    console.log('PLANNER UPSERT REQ:', new Date().toISOString());
    console.log(JSON.stringify(req.body, null, 2));

    const { studentId, date, task } = req.body;
    if (!studentId || !date || !task) {
      return res.status(400).json({ error: 'Missing studentId, date or task' });
    }

    // ensure task has an id
    const t = Object.assign({}, task);
    if (!t.id) t.id = `t_${Date.now()}`;

    const filter = { studentId: String(studentId), date: String(date) };
    const update = {
      $push: { tasks: t },
      $setOnInsert: { studentId: String(studentId), date: String(date) }
    };
    const opts = { upsert: true, new: true, setDefaultsOnInsert: true };

    const updated = await Planner.findOneAndUpdate(filter, update, opts).lean();

    if (!updated) {
      // fallback create
      const created = await Planner.create({ studentId, date, tasks: [t] });
      console.log('PLANNER CREATED:', JSON.stringify(created, null, 2));
      return res.json({ success: true, planner: created });
    }

    console.log('PLANNER UPDATED:', JSON.stringify(updated, null, 2));
    return res.json({ success: true, planner: updated });

  } catch (err) {
    console.error('upsertPlanner error:', err);
    return res.status(500).json({ error: err.message || String(err) });
  }
};

/**
 * Get planner for student & date
 * GET /api/planner/:studentId/:date
 */
exports.getPlanner = async (req, res) => {
  try {
    const { studentId, date } = req.params;
    if (!studentId || !date) return res.status(400).json({ error: 'Missing params' });
    const doc = await Planner.findOne({ studentId: String(studentId), date: String(date) }).lean();
    if (!doc) return res.json({ studentId, date, tasks: [] });
    return res.json(doc);
  } catch (e) {
    console.error('getPlanner error', e);
    return res.status(500).json({ error: e.message || String(e) });
  }
};
