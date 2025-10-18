// backend/routes/recommendationRoutes.js
const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const Planner = require('../models/Planner');

// load activities dataset
const activitiesPath = path.join(__dirname, '../data/activities.json');
let activities = [];
try {
  activities = JSON.parse(fs.readFileSync(activitiesPath, 'utf8'));
} catch (e) {
  console.error('Failed to load activities.json', e);
  activities = [];
}

// scoring helper
function scoreActivity(activity, profile, freeSlotMinutes) {
  let score = 0;
  const interests = (profile?.interests || []).map(i => i.toString().toLowerCase());
  const goalsText = (profile?.careerGoals || []).join(' ').toLowerCase();

  // tag-match
  for (const tag of (activity.tags || [])) {
    if (interests.includes(tag.toString().toLowerCase())) score += 30;
  }

  // goal substring match
  if (goalsText && (activity.title + ' ' + (activity.description || '')).toLowerCase().includes(goalsText)) {
    score += 20;
  }

  // duration fit
  const dur = activity.duration || 15;
  if (dur <= freeSlotMinutes) score += 25;
  else if (dur <= freeSlotMinutes + 10) score += 10;

  // wellbeing boost
  if ((activity.tags || []).includes('wellbeing')) score += 5;

  // small randomness to diversify
  score += Math.floor(Math.random() * 5);

  return score;
}

// POST /api/recommendations
// body: { studentId, date, freeSlots: [{start:'HH:mm', end:'HH:mm'}], profile: {...}, maxResults: 5 }
router.post('/', async (req, res) => {
  try {
    const { studentId, date, freeSlots, profile, maxResults } = req.body;
    if (!studentId || !date || !Array.isArray(freeSlots)) {
      return res.status(400).json({ error: 'Missing fields: studentId, date, freeSlots required' });
    }

    // helper to convert HH:mm -> minutes
    function toMinutes(hm) {
      const [h, m] = String(hm).split(':').map(Number);
      return (h || 0) * 60 + (m || 0);
    }

    const proposals = [];

    for (const slot of freeSlots) {
      const startM = toMinutes(slot.start);
      const endM = toMinutes(slot.end);
      const slotMinutes = Math.max(0, endM - startM);
      if (slotMinutes <= 0) continue;

      // score every activity for this slot
      const scored = activities.map(a => {
        return { activity: a, score: scoreActivity(a, profile || {}, slotMinutes), slotMinutes };
      })
      // allow slightly longer ones (trim possible)
      .filter(x => x.activity.duration <= slotMinutes + 10)
      .sort((a,b) => b.score - a.score);

      const top = scored.slice(0, 3);
      for (const t of top) {
        proposals.push({
          sessionStart: slot.start,
          sessionEnd: slot.end,
          slotMinutes: t.slotMinutes,
          id: t.activity.id,
          title: t.activity.title,
          description: t.activity.description,
          duration: t.activity.duration,
          tags: t.activity.tags,
          score: t.score
        });
      }
    }

    // dedupe by id keeping highest score
    const map = new Map();
    for (const p of proposals) {
      const existing = map.get(p.id);
      if (!existing || p.score > existing.score) map.set(p.id, p);
    }
    let results = Array.from(map.values()).sort((a,b) => b.score - a.score);
    const limit = maxResults ? Number(maxResults) : 5;
    results = results.slice(0, limit);

    return res.json({ recommendations: results });
  } catch (err) {
    console.error('Recommendation error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/planner/upsert
// body: { studentId, date, task }
router.post('/upsert', async (req, res) => {
  try {
    const { studentId, date, task } = req.body;
    if (!studentId || !date || !task) return res.status(400).json({ error: 'Missing fields' });

    let planner = await Planner.findOne({ studentId, date });
    if (!planner) {
      planner = await Planner.create({ studentId, date, tasks: [task] });
      return res.json({ success: true, planner });
    } else {
      // push task (no duplicate checking in MVP)
      planner.tasks.push(task);
      await planner.save();
      return res.json({ success: true, planner });
    }
  } catch (err) {
    console.error('Planner upsert error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/planner/:studentId/:date
router.get('/:studentId/:date', async (req, res) => {
  try {
    const { studentId, date } = req.params;
    const planner = await Planner.findOne({ studentId, date });
    return res.json(planner || { studentId, date, tasks: [] });
  } catch (err) {
    console.error('Get planner error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
