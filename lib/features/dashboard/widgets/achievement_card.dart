import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/dashboard_models.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard(this.achievement, {super.key});

  final SchoolAchievement achievement;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ProjectNexusColors.field,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                achievement.icon,
                size: 20,
                color: ProjectNexusColors.ink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      color: ProjectNexusColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.category,
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.team} · ${achievement.year}',
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
