import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/dashboard_models.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    required this.onDetails,
    this.recommendationReason,
    super.key,
  });

  final ProjectListing project;
  final VoidCallback onDetails;
  final String? recommendationReason;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PersonAvatar(project.leader, radius: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${project.leader} · ${project.event}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ProjectNexusColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    if (recommendationReason != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        recommendationReason!,
                        style: const TextStyle(
                          color: ProjectNexusColors.teal,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (project.difficulty == ProjectDifficulty.beginner)
                          const _BeginnerBadge(),
                        ...project.skills.map(SkillTag.new),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 15,
                    color: ProjectNexusColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '± ${project.weeklyHours} jam/minggu',
                      style: const TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(onPressed: onDetails, child: const Text('Detail')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar lingkaran berisi huruf pertama nama.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar(this.name, {this.radius = 18, super.key});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: ProjectNexusColors.mint,
      child: Text(
        trimmed.isEmpty ? '?' : trimmed[0].toUpperCase(),
        style: TextStyle(
          color: ProjectNexusColors.tealDark,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BeginnerBadge extends StatelessWidget {
  const _BeginnerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ProjectNexusColors.mint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Ramah pemula',
        style: TextStyle(
          color: ProjectNexusColors.tealDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ProjectNexusColors.field,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ProjectNexusColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Label status kecil berwarna (Disetujui, Menunggu, dsb).
class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
