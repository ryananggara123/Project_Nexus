import 'package:flutter/material.dart';

import 'core/theme/project_nexus_colors.dart';
import 'features/auth/screens/auth_gate.dart';

void main() {
  runApp(const ProjectNexusApp());
}

class ProjectNexusApp extends StatelessWidget {
  const ProjectNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectNexus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ProjectNexusColors.teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: ProjectNexusColors.background,
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
