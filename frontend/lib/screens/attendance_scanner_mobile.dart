// frontend/lib/screens/attendance_scanner_mobile.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AttendanceScannerMobile extends StatefulWidget {
  final String studentId;
  const AttendanceScannerMobile({Key? key, required this.studentId})
      : super(key: key);

  @override
  State<AttendanceScannerMobile> createState() =>
      _AttendanceScannerMobileState();
}

class _AttendanceScannerMobileState extends State<AttendanceScannerMobile> {
  bool _scanned = false;
  bool _processing = false;
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleCode(String code) async {
    if (_scanned) return;
    if (code.isEmpty) return;

    setState(() {
      _scanned = true;
      _processing = true;
    });

    try {
      final res = await ApiService.markAttendance(widget.studentId, code);
      setState(() {
        _processing = false;
      });

      final msg = res?['message']?.toString() ?? 'Attendance marked';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _processing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _submitManualCode() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      _handleCode(code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a class code')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Scanner')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Manual Attendance Entry',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter the class code provided by your teacher',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Class Code',
                    hintText: 'e.g., CS101_1234',
                    prefixIcon: Icon(Icons.code),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                  onSubmitted: (_) => _submitManualCode(),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _processing ? null : _submitManualCode,
                  icon: const Icon(Icons.check),
                  label: const Text('Mark Attendance'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'To enable QR code scanning:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Run "flutter pub get" in terminal\n2. Restart the app\n3. Camera scanner will be available',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_processing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
