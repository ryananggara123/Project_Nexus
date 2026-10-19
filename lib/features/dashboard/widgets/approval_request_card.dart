import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/dashboard_models.dart';
import 'project_card.dart';

class ApprovalRequestCard extends StatelessWidget {
  const ApprovalRequestCard({
    required this.project,
    required this.onApprove,
    required this.onReject,
    super.key,
  });

  final ProjectListing project;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PersonAvatar(project.leader, radius: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    project.leader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProjectNexusColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const StatusPill(
                  label: 'Menunggu tinjauan',
                  color: ProjectNexusColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              project.title,
              style: const TextStyle(
                color: ProjectNexusColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              project.description,
              style: const TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            _InfoLine(icon: Icons.flag_outlined, text: project.event),
            const SizedBox(height: 6),
            _InfoLine(
              icon: Icons.school_outlined,
              text: 'Pendamping: ${project.teacherName}',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ProjectNexusColors.error,
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    child: const Text('Setujui (ACC)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ProjectNexusColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: ProjectNexusColors.muted,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
