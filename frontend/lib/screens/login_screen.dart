// frontend/lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> doLogin() async {
    setState(() => loading = true);
    final res = await ApiService.login(_email.text.trim(), _password.text.trim());
    setState(() => loading = false);

    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No response from server')));
      return;
    }
    if (res['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'].toString())));
      return;
    }

    // Expect backend to return 'user' and optional 'role'
    final Map<String, dynamic>? user = res['user'] is Map ? Map<String, dynamic>.from(res['user']) : null;
    final String role = (res['role'] ?? user?['role'] ?? 'student').toString();

    if (role == 'teacher') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherDashboard()));
    } else {
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid user data')));
        return;
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudentDashboard(user: user)));
    }
  }

  void goToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Curriculum - Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Smart Curriculum', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : doLogin,
                  child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login'),
                ),
                TextButton(onPressed: goToRegister, child: const Text('Register (Demo)')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> doRegister() async {
    setState(() => loading = true);
    final payload = {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'password': _pass.text.trim(),
      'role': 'student',
      'studentId': 'S' + DateTime.now().millisecondsSinceEpoch.toString().substring(7)
    };
    final res = await ApiService.register(payload);
    setState(() => loading = false);

    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No response from server')));
      return;
    }
    if (res['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'].toString())));
      return;
    }
    final Map<String, dynamic>? user = res['user'] is Map ? Map<String, dynamic>.from(res['user']) : null;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration succeeded but user missing')));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudentDashboard(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register (Demo)')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: loading ? null : doRegister, child: const Text('Register & Continue')),
            ]),
          ),
        ),
      ),
    );
  }
}
