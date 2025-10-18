// frontend/lib/screens/student_dashboard.dart
import 'package:flutter/material.dart';
import 'attendance_scanner.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  final Map user;
  const StudentDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<dynamic> attendance = [];
  Map planner = {};
  late String today;

  // Recommendations state
  List<dynamic> recommendations = [];
  bool recLoading = false;
  bool loadingPlanner = true;

  @override
  void initState() {
    super.initState();
    today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchRecommendations();
    });
  }

  Future<void> loadData() async {
    final id = widget.user['studentId'] ?? widget.user['id'] ?? '';
    setState(() => loadingPlanner = true);
    try {
      final a = await ApiService.getAttendanceByStudent(id);
      final p = await ApiService.getPlanner(id, today);
      setState(() {
        attendance = a;
        planner = p;
      });
    } catch (e) {
      setState(() {
        attendance = [];
        planner = {};
      });
    } finally {
      setState(() => loadingPlanner = false);
    }
  }

  Future<void> fetchRecommendations() async {
    setState(() {
      recLoading = true;
      recommendations = [];
    });

    final id = widget.user['studentId'] ?? widget.user['id'] ?? '';
    final freeSlots = [{'start': '14:00', 'end': '15:00'}];
    final profile = {
      'interests': widget.user['interests'] ?? ['coding', 'reading'],
      'careerGoals': widget.user['careerGoals'] ?? [],
      'strengths': widget.user['strengths'] ?? []
    };

    final body = {
      'studentId': id,
      'date': today,
      'freeSlots': freeSlots,
      'profile': profile,
      'maxResults': 6
    };

    final res = await ApiService.getRecommendations(body);
    setState(() {
      recommendations = (res != null && res['recommendations'] is List)
          ? res['recommendations'] as List<dynamic>
          : <dynamic>[];
      recLoading = false;
    });
  }

  double attendancePercent() {
    final unique = attendance.map((e) => e['classId']).toSet().length;
    final percent = (unique / 10.0) * 100;
    return percent.clamp(0, 100);
  }

  Future<void> openScanner() async {
    final id = widget.user['studentId'] ?? widget.user['id'] ?? '';
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScanner(studentId: id)));
    await loadData();
  }

  Future<void> _addRecommendationToPlanner(Map<String, dynamic> rec) async {
    final id = widget.user['studentId'] ?? widget.user['id'] ?? '';
    final startTime = rec['sessionStart'] ?? '00:00';
    final endTime = rec['sessionEnd'] ?? '00:00';
    final task = {
      'id': rec['id'] ?? '${rec['title']}_${DateTime.now().millisecondsSinceEpoch}',
      'title': rec['title'] ?? '',
      'description': rec['description'] ?? '',
      'startTime': startTime,
      'endTime': endTime,
      'durationMinutes': rec['duration'] ?? 15,
      'tags': rec['tags'] ?? [],
      'completed': false,
      'source': 'recommendation'
    };

    final body = {'studentId': id, 'date': today, 'task': task};
    final res = await ApiService.upsertPlanner(body);
    if (res != null && res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to planner')));
      await loadData();
    } else {
      final err = res != null ? (res['error'] ?? 'Unknown error') : 'No response';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add: $err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = attendancePercent();
    return Scaffold(
      appBar: AppBar(title: Text('Student Dashboard - ${widget.user['name'] ?? ''}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                // Header row
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Welcome, ${widget.user['name'] ?? 'Student'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton(onPressed: openScanner, child: const Text('Scan QR (Mark Attendance)')),
                ]),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: const Text('Attendance %'),
                    subtitle: LinearProgressIndicator(value: percent / 100),
                    trailing: Text('${percent.toStringAsFixed(1)}%'),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      // Left: Planner (takes 55% width)
                      Expanded(
                        flex: 55,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Today Planner', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: loadingPlanner
                                  ? const Center(child: CircularProgressIndicator())
                                  : planner['tasks'] != null && planner['tasks'] is List
                                      ? ListView.separated(
                                          itemCount: (planner['tasks'] as List).length,
                                          separatorBuilder: (_, __) => const Divider(),
                                          itemBuilder: (_, idx) {
                                            final t = planner['tasks'][idx];
                                            return ListTile(
                                              title: Text(t['title'] ?? ''),
                                              subtitle: Text(t['description'] ?? ''),
                                              trailing: Checkbox(value: t['completed'] ?? false, onChanged: (v) {}),
                                            );
                                          },
                                        )
                                      : ListView(
                                          children: const [
                                            ListTile(title: Text('No planned tasks for today')),
                                          ],
                                        ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Right: Recommendations (takes 45% width)
                      Expanded(
                        flex: 45,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  const Text('Suggested Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  TextButton(onPressed: fetchRecommendations, child: const Text('Refresh')),
                                ]),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: recLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : recommendations.isEmpty
                                          ? const Text('No suggestions. Tap Refresh.')
                                          : ListView.separated(
                                              itemCount: recommendations.length,
                                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                                              itemBuilder: (_, i) {
                                                final r = recommendations[i];
                                                return ListTile(
                                                  title: Text(r['title'] ?? ''),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(r['description'] ?? ''),
                                                      const SizedBox(height: 6),
                                                      Text('⏱ ${r['duration'] ?? ''} mins • tags: ${(r['tags'] ?? []).join(', ')}',
                                                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                    ],
                                                  ),
                                                  isThreeLine: true,
                                                  trailing: ElevatedButton(
                                                    onPressed: () => _addRecommendationToPlanner(Map<String, dynamic>.from(r)),
                                                    child: const Text('Add'),
                                                  ),
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
