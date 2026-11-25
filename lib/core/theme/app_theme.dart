import 'package:flutter/material.dart';

import 'project_nexus_colors.dart';

abstract final class AppTheme {
  static const radius = AppRadius.control;
  static const fontFamily = 'PlusJakartaSans';

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: ProjectNexusColors.teal,
            brightness: Brightness.light,
          ).copyWith(
            primary: ProjectNexusColors.teal,
            onPrimary: Colors.white,
            surface: ProjectNexusColors.surface,
            error: ProjectNexusColors.error,
          ),
      scaffoldBackgroundColor: ProjectNexusColors.background,
      // Transisi antarhalaman yang halus di semua platform.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: ProjectNexusColors.ink,
        displayColor: ProjectNexusColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ProjectNexusColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ProjectNexusColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: ProjectNexusColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ProjectNexusColors.field,
        hintStyle: const TextStyle(color: Color(0xFF94A3A5), fontSize: 14),
        prefixIconColor: ProjectNexusColors.muted,
        suffixIconColor: ProjectNexusColors.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(ProjectNexusColors.teal, 1.5),
        errorBorder: border(ProjectNexusColors.error),
        focusedErrorBorder: border(ProjectNexusColors.error, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: buttonShape,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: buttonShape,
          side: const BorderSide(color: ProjectNexusColors.border),
          foregroundColor: ProjectNexusColors.ink,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ProjectNexusColors.teal,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: ProjectNexusColors.surface,
        surfaceTintColor: Colors.transparent,
        // Bayangan lembut menggantikan garis tepi tebal agar kartu terasa
        // terangkat dari latar.
        elevation: 2,
        shadowColor: ProjectNexusColors.tealDeep.withValues(alpha: 0.10),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: Color(0xFFEDF1F0)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ProjectNexusColors.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: ProjectNexusColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ProjectNexusColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: ProjectNexusColors.mint,
        elevation: 0,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? ProjectNexusColors.teal
                : ProjectNexusColors.muted,
          );
        }),
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
      dialogTheme: DialogThemeData(
        backgroundColor: ProjectNexusColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: ProjectNexusColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: ProjectNexusColors.ink,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ProjectNexusColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: ProjectNexusColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? ProjectNexusColors.teal
              : null,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ProjectNexusColors.tealDark,
        foregroundColor: Colors.white,
        elevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        extendedTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ProjectNexusColors.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
