// frontend/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/teacher_dashboard.dart';

void main() {
  runApp(const SmartCurriculumApp());
}

class SmartCurriculumApp extends StatelessWidget {
  const SmartCurriculumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Curriculum',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: LoginScreen(),
    );
  }
}

// A simple navigator function you can call after login
void navigateAfterLogin(BuildContext context, Map<String, dynamic> user, String role) {
  if (role == 'teacher') {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherDashboard()));
  } else {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudentDashboard(user: user)));
  }
}
