import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.isTeacherView,
    required this.onLogout,
    super.key,
  });

  final bool isTeacherView;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ProjectNexusColors.teal, ProjectNexusColors.tealDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ProjectNexus',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF172A2D),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                isTeacherView
                    ? 'PANEL GURU PENDAMPING'
                    : 'RUANG KOLABORASI SISWA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ProjectNexusColors.muted,
                  fontWeight: FontWeight.w700,
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
          icon: const Icon(Icons.logout_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: ProjectNexusColors.ink,
            side: const BorderSide(color: ProjectNexusColors.border),
          ),
        ),
      ],
    );
  }
}
