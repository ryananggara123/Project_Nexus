import 'package:flutter/material.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../models/user_role.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  UserRole? _currentRole;

  @override
  Widget build(BuildContext context) {
    final role = _currentRole;
    if (role == null) {
      return LoginScreen(
        onLogin: (role) => setState(() => _currentRole = role),
      );
    }

    return DashboardScreen(
      role: role,
      onLogout: () => setState(() => _currentRole = null),
    );
  }
}
