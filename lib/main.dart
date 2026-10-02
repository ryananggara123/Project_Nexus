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
        ).copyWith(
          primary: ProjectNexusColors.teal,
          onPrimary: Colors.white,
          surface: ProjectNexusColors.surface,
        ),
        scaffoldBackgroundColor: ProjectNexusColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: ProjectNexusColors.background,
          foregroundColor: ProjectNexusColors.ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAF9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ProjectNexusColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ProjectNexusColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: ProjectNexusColors.teal,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFBA3B35)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFBA3B35), width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: ProjectNexusColors.surface,
          indicatorColor: ProjectNexusColors.mint,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected
                  ? ProjectNexusColors.teal
                  : ProjectNexusColors.muted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ProjectNexusColors.tealDark,
          foregroundColor: Colors.white,
          elevation: 3,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ProjectNexusColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
