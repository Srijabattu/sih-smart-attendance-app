# Smart Curriculum Backend

Run:
1. Create `.env` with MONGO_URI and JWT_SECRET
2. `npm install`
3. `npm run dev` (requires nodemon) or `npm start`

APIs:
- POST /api/auth/register
- POST /api/auth/login
- POST /api/attendance/mark
- GET  /api/attendance/class/:classId
- GET  /api/attendance/student/:studentId
- POST /api/planner/upsert
- GET  /api/planner/:studentId/:date
