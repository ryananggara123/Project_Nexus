import 'package:flutter/material.dart';

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
            color: const Color(0xFF087E8B),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ProjectNexus',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF172A2D),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'RUANG KOLABORASI SISWA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF718083),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Keluar',
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF172A2D),
          ),
        ),
      ],
    );
  }
}
