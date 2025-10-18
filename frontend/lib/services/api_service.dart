import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // detect platform (web vs android emulator)
  static final String baseUrl =
      kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  static Duration requestTimeout = const Duration(seconds: 10);

  // ------------------- AUTH -------------------
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'password': password}))
          .timeout(requestTimeout);
      debugPrint('LOGIN ${res.statusCode} ${res.body}');
      return _safeDecode(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>?> register(
      Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/auth/register');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload))
          .timeout(requestTimeout);
      return _safeDecode(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // ------------------- SESSION -------------------
  static Future<Map<String, dynamic>?> createSession(
      String classId, String teacherId,
      {int ttlMinutes = 10}) async {
    final uri = Uri.parse('$baseUrl/api/session/create');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'classId': classId,
                'teacherId': teacherId,
                'ttlMinutes': ttlMinutes
              }))
          .timeout(requestTimeout);
      debugPrint('CREATE SESSION ${res.statusCode} ${res.body}');
      return _safeDecode(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>?> getSessionAttendees(
      String sessionId) async {
    final uri = Uri.parse('$baseUrl/api/session/$sessionId/attendees');
    try {
      final res = await http.get(uri).timeout(requestTimeout);
      return _safeDecode(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>?> markAttendance(
      String studentId, String sessionId) async {
    final uri = Uri.parse('$baseUrl/api/attendance/mark');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'studentId': studentId, 'sessionId': sessionId}))
          .timeout(requestTimeout);
      return _safeDecode(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // ------------------- ATTENDANCE -------------------
  static Future<List<dynamic>> getAttendanceByStudent(
      String studentId) async {
    final uri = Uri.parse('$baseUrl/api/attendance/student/$studentId');
    try {
      final res = await http.get(uri).timeout(requestTimeout);
      final decoded = _safeDecode(res);
      if (decoded != null && decoded['data'] is List) {
        return decoded['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ------------------- PLANNER -------------------
  static Future<Map<String, dynamic>> getPlanner(
      String studentId, String date) async {
    final uri = Uri.parse('$baseUrl/api/planner/$studentId/$date');
    try {
      final res = await http.get(uri).timeout(requestTimeout);
      final decoded = _safeDecode(res);
      return decoded ?? {};
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>?> upsertPlanner(
      Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/api/planner/upsert');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(requestTimeout);
      debugPrint('UPSERT PLANNER ${res.statusCode} ${res.body}');
      return _safeDecode(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // ------------------- RECOMMENDATIONS -------------------
  static Future<Map<String, dynamic>?> getRecommendations(
      Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/api/recommendations');
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(requestTimeout);
      debugPrint('GET RECS ${res.statusCode} ${res.body}');
      return _safeDecode(res);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // ------------------- HELPER -------------------
  static Map<String, dynamic>? _safeDecode(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (e) {
      return {'error': 'Invalid JSON response (status ${res.statusCode})'};
    }
  }
}
