// frontend/lib/screens/attendance_scanner.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AttendanceScanner extends StatefulWidget {
  final String studentId;
  const AttendanceScanner({Key? key, required this.studentId}) : super(key: key);
  @override
  State<AttendanceScanner> createState() => _AttendanceScannerState();
}

class _AttendanceScannerState extends State<AttendanceScanner> {
  final TextEditingController _controller = TextEditingController();
  bool submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitClassId() async {
    final classId = _controller.text.trim();
    if (classId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a class code')));
      return;
    }

    setState(() => submitting = true);
    try {
  final res = await ApiService.markAttendance(widget.studentId, classId);
  String msg = 'Attendance marked';

  if (res != null && res['message'] != null) {
    msg = res['message'].toString();
  }

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  await Future.delayed(const Duration(seconds: 1));
  if (mounted) Navigator.pop(context);
} catch (e) {
if (mounted) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Error: $e')));
}
  }
  setState(() => submitting = false);
}


  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Class Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text(isWeb ? 'Enter (or paste) the class code displayed on Teacher’s screen:' : 'Scan or enter the class code displayed on Teacher’s screen:'),
          const SizedBox(height: 12),
          TextField(controller: _controller, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g., CS101_1234')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: submitting ? null : _submitClassId,
            child: submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Submit Attendance'),
          ),
          if (isWeb)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Tip: On web, use the class code text shown under the teacher’s QR. For mobile, scanning camera is supported in mobile builds.', style: TextStyle(color: Colors.grey[700])),
            )
        ]),
      ),
    );
  }
}
