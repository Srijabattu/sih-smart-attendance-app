// frontend/lib/widgets/attendance_card.dart
import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String classId;
  final DateTime time;
  AttendanceCard({required this.classId, required this.time});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Class: $classId'),
        subtitle: Text('Time: ${time.toLocal()}'),
      ),
    );
  }
}
