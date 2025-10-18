// backend/models/User.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  role: { type: String, enum: ['student','teacher','admin'], default: 'student' },
  studentId: { type: String }, // for students
  profile: { type: Object, default: {} }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
