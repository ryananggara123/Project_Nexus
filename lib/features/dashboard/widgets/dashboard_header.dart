import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';

/// Lebar layar saat navigasi samping (yang sudah memuat logo) dipakai.
const wideLayoutBreakpoint = 1000.0;

/// Baris atas setiap menu: logo ProjectNexus, keterangan ruang, tombol keluar.
/// Disembunyikan pada layar lebar karena navigasi samping sudah memuat logo.
class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.isTeacherView,
    required this.onLogout,
    super.key,
  });

  final bool isTeacherView;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const AppLogo(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ProjectNexus',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ProjectNexusColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isTeacherView
                      ? 'PANEL GURU PENDAMPING'
                      : 'RUANG KOLABORASI SISWA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProjectNexusColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Keluar',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: ProjectNexusColors.surface,
              foregroundColor: ProjectNexusColors.ink,
              side: const BorderSide(color: ProjectNexusColors.border),
              fixedSize: const Size(44, 44),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo aplikasi: ikon hub di kotak gradient teal.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 44, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ProjectNexusColors.teal, ProjectNexusColors.tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(Icons.hub_rounded, color: Colors.white, size: size * 0.52),
    );
  }
}

/// Kartu sambutan bergradient teal gelap di bagian atas setiap menu.
class HeroBanner extends StatelessWidget {
  const HeroBanner({
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.description,
    this.icon,
    this.leading,
    this.trailing,
    this.bottom,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final String? description;

  /// Ikon dekoratif di kanan; diabaikan bila [trailing] diisi.
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;

  /// Konten tambahan di bawah teks, misalnya progress bar.
  final Widget? bottom;

  static const onHeroMuted = Color(0xFFD7E9E5);
  static const onHeroAccent = Color(0xFFC9E9E2);

  @override
  Widget build(BuildContext context) {
    final side =
        trailing ??
        (icon == null
            ? null
            : Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(icon, color: const Color(0xFFB9E2D8), size: 32),
              ));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102F35),
            ProjectNexusColors.tealDark,
            Color(0xFF176B68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ProjectNexusColors.tealDark.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 16)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        eyebrow,
                        style: const TextStyle(
                          color: onHeroAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Color(0xFFE0F0EC),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        description!,
                        style: const TextStyle(
                          color: onHeroMuted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (side != null) ...[const SizedBox(width: 14), side],
            ],
          ),
          if (bottom != null) ...[const SizedBox(height: 18), bottom!],
        ],
      ),
    );
  }
}

/// Judul bagian dengan keterangan opsional di kanan dan di bawahnya.
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    this.trailing,
    this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final String? trailing;
  final String? subtitle;

  /// Tombol di kanan judul; menggantikan [trailing] bila diisi.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ProjectNexusColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (action != null)
              action!
            else if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(
                  color: ProjectNexusColors.muted,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              color: ProjectNexusColors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Halaman menu standar: lebar maksimum, padding, header aplikasi, hero,
/// lalu konten. Memakai CustomScrollView agar perilaku gulir seragam.
class MenuPage extends StatelessWidget {
  const MenuPage({
    required this.header,
    required this.children,
    this.maxWidth = 760,
    this.bottomPadding = 32,
    this.lazy = true,
    super.key,
  });

  final Widget header;
  final List<Widget> children;
  final double maxWidth;
  final double bottomPadding;

  /// false = semua konten dibangun sekaligus, misalnya papan tugas yang
  /// isinya perlu tetap ada walau berada di luar layar.
  final bool lazy;

  @override
  Widget build(BuildContext context) {
    if (!lazy) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [header, ...children],
            ),
          ),
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
              sliver: SliverList.list(children: [header, ...children]),
            ),
          ],
        ),
      ),
    );
  }
}
