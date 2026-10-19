import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dashboard/models/project_workflow_store.dart';
import '../../dashboard/screens/dashboard_screen.dart';
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
  static const _roleStorageKey = 'project_nexus_auth_role';
  static const _studentNameStorageKey = 'project_nexus_auth_student_name';
  static const _teacherNameStorageKey = 'project_nexus_auth_teacher_name';

  UserRole? _currentRole;
  String? _currentStudentName;
  String? _currentTeacherName;
  bool _showSplash = true;
  Timer? _splashTimer;
  final List<StudentDemoAccount> _studentAccounts = [];
  final ProjectWorkflowStore _projectStore = ProjectWorkflowStore();

  @override
  void initState() {
    super.initState();
    _restoreSession();
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

  Future<void> _restoreSession() async {
    if (!kReleaseMode) return;

    final prefs = await SharedPreferences.getInstance();
    final storedRoleName = prefs.getString(_roleStorageKey);
    final storedStudentName = prefs.getString(_studentNameStorageKey);
    final storedTeacherName = prefs.getString(_teacherNameStorageKey);

    if (!mounted) return;

    setState(() {
      _currentRole = _parseRole(storedRoleName);
      _currentStudentName = storedStudentName;
      _currentTeacherName = storedTeacherName;
    });
  }

  UserRole? _parseRole(String? storedRoleName) {
    if (storedRoleName == null) return null;
    for (final role in UserRole.values) {
      if (role.name == storedRoleName) return role;
    }
    return null;
  }

  Future<void> _persistSession({
    required UserRole role,
    String? studentName,
    String? teacherName,
  }) async {
    if (!kReleaseMode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleStorageKey, role.name);

    if (studentName == null) {
      await prefs.remove(_studentNameStorageKey);
    } else {
      await prefs.setString(_studentNameStorageKey, studentName);
    }

    if (teacherName == null) {
      await prefs.remove(_teacherNameStorageKey);
    } else {
      await prefs.setString(_teacherNameStorageKey, teacherName);
    }
  }

  Future<void> _clearSession() async {
    if (!kReleaseMode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleStorageKey);
    await prefs.remove(_studentNameStorageKey);
    await prefs.remove(_teacherNameStorageKey);
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
        onLogin: (role, {studentName, teacherName}) async {
          await _persistSession(
            role: role,
            studentName: studentName,
            teacherName: teacherName,
          );
          if (!mounted) return;
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
      onLogout: () async {
        await _clearSession();
        if (!mounted) return;
        setState(() {
          _currentRole = null;
          _currentStudentName = null;
          _currentTeacherName = null;
        });
      },
    );
  }
}
