import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    required this.onDetails,
    super.key,
  });

  final ProjectListing project;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0xFF172A2D).withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE4EAE9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: const Color(0xFFD6ECEB),
                  child: Text(
                    project.leader.substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFF087E8B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.leader,
                        style: const TextStyle(
                          color: Color(0xFF172A2D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        project.event,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF718083),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const _OpenBadge(),
              ],
            ),
            const SizedBox(height: 17),
            Text(
              project.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF172A2D),
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFF627174), height: 1.45),
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: project.skills.map(SkillTag.new).toList(),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE8EFEE)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: Color(0xFF087E8B),
                ),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Disetujui guru pendamping',
                    style: TextStyle(
                      color: Color(0xFF526568),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(onPressed: onDetails, child: const Text('Detail')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SkillTag extends StatelessWidget {
  const SkillTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF42585B),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F3EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'OPEN',
        style: TextStyle(
          color: Color(0xFF287A4B),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
