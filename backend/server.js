// backend/server.js
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const connectDB = require('./config/db');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const attendanceRoutes = require('./routes/attendanceRoutes');
const plannerRoutes = require('./routes/plannerRoutes');
const sessionRoutes = require('./routes/sessionRoutes');
const recommendationRoutes = require('./routes/recommendationRoutes');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(express.json());

connectDB();

app.use('/api/auth', authRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/planner', plannerRoutes);
app.use('/api/session', sessionRoutes);
app.use('/api/recommendations', recommendationRoutes);
app.use('/api/planner', recommendationRoutes);


app.get('/', (req, res) => res.send('Smart Curriculum Backend is up!'));


const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));
