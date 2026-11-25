import 'package:flutter/material.dart';

abstract final class ProjectNexusColors {
  static const ink = Color(0xFF172A2D);
  static const teal = Color(0xFF087E8B);
  static const tealDark = Color(0xFF123C40);
  static const tealDeep = Color(0xFF0B2A2E);
  static const mint = Color(0xFFE5F3F1);
  static const muted = Color(0xFF627174);
  static const background = Color(0xFFF4F6F5);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE3E8E8);
  static const field = Color(0xFFF3F6F6);
  static const error = Color(0xFFBA3B35);
  static const success = Color(0xFF26734D);
  static const warning = Color(0xFF9A572C);

  /// Aksen emas untuk lencana, prestasi, dan sorotan, pendamping teal.
  static const gold = Color(0xFFC9972B);
  static const goldLight = Color(0xFFF2D58A);
  static const goldSoft = Color(0xFFFBF3DE);
}

/// Jarak, sudut, dan bayangan yang dipakai bersama agar setiap menu rapi
/// dan konsisten.
abstract final class AppSpacing {
  static const page = 20.0;
  static const section = 24.0;
  static const card = 16.0;
  static const gap = 12.0;
}

abstract final class AppRadius {
  static const card = 20.0;
  static const control = 14.0;
  static const pill = 999.0;
}

abstract final class AppShadows {
  /// Bayangan lembut untuk kartu di atas latar abu-abu.
  static final card = [
    BoxShadow(
      color: ProjectNexusColors.tealDeep.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  /// Bayangan lebih tegas untuk hero dan tombol utama.
  static final raised = [
    BoxShadow(
      color: ProjectNexusColors.tealDeep.withValues(alpha: 0.22),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];
}
