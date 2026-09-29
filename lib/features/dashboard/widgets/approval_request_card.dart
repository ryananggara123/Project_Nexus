import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';

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
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4EAE9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFC46A3A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.leader,
                    style: const TextStyle(
                      color: Color(0xFF526568),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Text(
                  'MENUNGGU ACC',
                  style: TextStyle(
                    color: Color(0xFF9A572C),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF172A2D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFF627174), height: 1.4),
            ),
            const SizedBox(height: 10),
            Text(
              'Pendamping: ${project.teacherName}',
              style: const TextStyle(color: Color(0xFF526568), fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton(onPressed: onReject, child: const Text('Tolak')),
                FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Setujui (ACC)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF173D3D),
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
