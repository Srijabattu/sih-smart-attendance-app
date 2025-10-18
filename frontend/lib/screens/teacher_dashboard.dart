// frontend/lib/screens/teacher_dashboard.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class TeacherDashboard extends StatefulWidget {
  final Map? user;
  const TeacherDashboard({Key? key, this.user}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String? _sessionId;
  bool _loading = false;
  List<dynamic> attendees = [];
  String _msg = '';

  // Local fallback generator
  String _localSession(String classId) {
    final seed = Random().nextInt(999999).toString().padLeft(6, '0');
    return '${classId}_$seed';
  }

  Future<void> _generateForClass(String classId) async {
    setState(() {
      _loading = true;
      _msg = '';
    });

    try {
      // Try server create (if backend has API)
      final teacherId =
          widget.user?['teacherId'] ?? widget.user?['id'] ?? 'teacher_demo';
      final res =
          await ApiService.createSession(classId, teacherId, ttlMinutes: 30);
      if (res != null && res['sessionId'] != null) {
        setState(() {
          _sessionId = res['sessionId'].toString();
          _msg = 'Server session created';
        });
      } else {
        // fallback local
        setState(() {
          _sessionId = _localSession(classId.toLowerCase());
          _msg = 'Local session generated';
        });
      }
    } catch (e) {
      setState(() {
        _sessionId = _localSession(classId.toLowerCase());
        _msg = 'Local session (fallback)';
      });
    } finally {
      setState(() => _loading = false);
      // fetch attendees (initial)
      if (_sessionId != null) await _refreshAttendees();
    }
  }

  Future<void> _refreshAttendees() async {
    if (_sessionId == null) return;
    final res = await ApiService.getSessionAttendees(_sessionId!);
    if (res != null && res['attendees'] is List) {
      setState(() => attendees = res['attendees'] as List<dynamic>);
    } else {
      setState(() => attendees = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use SingleChildScrollView to avoid overflow on small screens
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Classes',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                // Example class list (replace with actual classes)
                ...['CS101', 'MATH201', 'ENG150'].map((c) => ListTile(
                      leading: const Icon(Icons.class_),
                      title: Text('$c - Example Course'),
                      trailing: ElevatedButton(
                        onPressed: _loading ? null : () => _generateForClass(c),
                        child: const Text('Generate QR'),
                      ),
                    )),
                const SizedBox(height: 20),
                // QR + Status area (bounded)
                const Text('QR Code for Current Session',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(18.0),
                          child: CircularProgressIndicator(),
                        ),
                      if (_sessionId != null) ...[
                        // Constrain QR size so it won't overflow
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: 260,
                            height: 260,
                            child: QrImageView(
                              data: _sessionId!,
                              version: QrVersions.auto,
                              size: 260.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Session Code: ${_sessionId!}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(_msg, style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _refreshAttendees,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Attendees'),
                        )
                      ] else if (!_loading)
                        const Text(
                            'No active session. Click Generate QR above.'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Attendees',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Use a bounded container for attendees list
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: attendees.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No attendees yet'),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: attendees.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (_, idx) {
                            final a = attendees[idx];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(
                                  a['name'] ?? a['studentId'] ?? 'Unknown'),
                              subtitle: Text(a['studentId'] ?? ''),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
