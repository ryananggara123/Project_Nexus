import 'dart:async';

import 'package:flutter/material.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../../dashboard/models/project_workflow_store.dart';
import '../models/student_demo_account.dart';
import '../models/user_role.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  static const splashDuration = Duration(milliseconds: 1800);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  UserRole? _currentRole;
  String? _currentStudentName;
  bool _showSplash = true;
  Timer? _splashTimer;
  final List<StudentDemoAccount> _studentAccounts = [];
  final ProjectWorkflowStore _projectStore = ProjectWorkflowStore();
  String? _currentTeacherName;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(AuthGate.splashDuration, () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _projectStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();

    final role = _currentRole;
    if (role == null) {
      return LoginScreen(
        studentAccounts: _studentAccounts,
        onRegister: (account) {
          setState(() => _studentAccounts.add(account));
        },
        onLogin: (role, {studentName, teacherName}) {
          setState(() {
            _currentRole = role;
            _currentStudentName = studentName;
            _currentTeacherName = teacherName;
          });
        },
      );
    }

    return DashboardScreen(
      role: role,
      studentName: _currentStudentName,
      teacherName: _currentTeacherName,
      projectStore: _projectStore,
      onLogout: () {
        setState(() {
          _currentRole = null;
          _currentStudentName = null;
          _currentTeacherName = null;
        });
      },
    );
  }
}
