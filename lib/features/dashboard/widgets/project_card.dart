import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/dashboard_models.dart';
import '../models/profile_photo_store.dart';

/// Warna dan ikon kategori proyek, dari keahlian pertama yang dibutuhkan.
({Color color, IconData icon}) projectCategory(ProjectListing project) {
  final skill = project.skills.isEmpty ? '' : project.skills.first;
  return switch (skill) {
    'Flutter' => (
      color: const Color(0xFF087E8B),
      icon: Icons.phone_android_rounded,
    ),
    'UI/UX' ||
    'Desain' => (color: const Color(0xFFC46A3A), icon: Icons.palette_outlined),
    'Riset' => (color: const Color(0xFF536B45), icon: Icons.science_outlined),
    'IoT' => (color: const Color(0xFF3E5C9A), icon: Icons.sensors_rounded),
    'Penulis' => (
      color: const Color(0xFF6657A5),
      icon: Icons.edit_note_rounded,
    ),
    'Basis Data' => (
      color: const Color(0xFF2F6F8F),
      icon: Icons.storage_rounded,
    ),
    _ => (color: ProjectNexusColors.teal, icon: Icons.rocket_launch_outlined),
  };
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    required this.onDetails,
    this.recommendationReason,
    this.members = const [],
    this.featured = false,
    super.key,
  });

  final ProjectListing project;
  final VoidCallback onDetails;
  final String? recommendationReason;

  /// Nama anggota tim (termasuk ketua) untuk tumpukan avatar.
  final List<String> members;

  /// Kartu sorotan "Paling cocok untukmu" dengan latar gelap.
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final category = projectCategory(project);
    final ink = featured ? Colors.white : ProjectNexusColors.ink;
    final muted = featured ? const Color(0xFFC9DEDA) : ProjectNexusColors.muted;
    final card = Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featured) ...[
                  const _FeaturedBadge(),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: featured
                            ? Colors.white.withValues(alpha: 0.12)
                            : category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        size: 21,
                        color: featured
                            ? ProjectNexusColors.goldLight
                            : category.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.leader,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            project.event,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (members.isNotEmpty) AvatarStack(members),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  project.title,
                  style: TextStyle(
                    color: ink,
                    fontSize: featured ? 19 : 16,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  project.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 13, height: 1.45),
                ),
                if (recommendationReason != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: featured
                            ? ProjectNexusColors.goldLight
                            : ProjectNexusColors.gold,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          recommendationReason!,
                          style: TextStyle(
                            color: featured
                                ? ProjectNexusColors.goldLight
                                : ProjectNexusColors.teal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (project.difficulty == ProjectDifficulty.beginner)
                      const _BeginnerBadge(),
                    for (final skill in project.skills)
                      SkillTag(skill, onDark: featured),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule_outlined, size: 15, color: muted),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '± ${project.weeklyHours} jam/minggu',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: onDetails,
                style: TextButton.styleFrom(
                  foregroundColor: featured
                      ? ProjectNexusColors.goldLight
                      : ProjectNexusColors.teal,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Detail'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!featured) {
      return Card(
        margin: const EdgeInsets.only(bottom: 14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onDetails, child: card),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 10,
      shadowColor: ProjectNexusColors.tealDeep.withValues(alpha: 0.4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: ProjectNexusColors.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ProjectNexusColors.tealDeep, Color(0xFF155E5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(onTap: onDetails, child: card),
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ProjectNexusColors.goldLight, ProjectNexusColors.gold],
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: ProjectNexusColors.tealDeep,
          ),
          SizedBox(width: 4),
          Text(
            'PALING COCOK UNTUKMU',
            style: TextStyle(
              color: ProjectNexusColors.tealDeep,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto anggota tim yang saling menumpuk, maksimal tiga ditambah sisa.
class AvatarStack extends StatelessWidget {
  const AvatarStack(this.names, {this.radius = 13, super.key});

  final List<String> names;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shown = names.take(3).toList();
    final extra = names.length - shown.length;
    final step = radius * 1.35;
    final count = shown.length + (extra > 0 ? 1 : 0);
    return SizedBox(
      width: radius * 2 + step * (count - 1) + 4,
      height: radius * 2 + 4,
      child: Stack(
        children: [
          for (final (i, name) in shown.indexed)
            Positioned(
              left: i * step,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: PersonAvatar(name, radius: radius),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * step,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: ProjectNexusColors.goldSoft,
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      color: ProjectNexusColors.gold,
                      fontSize: radius * 0.75,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar(this.name, {this.radius = 18, super.key});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    // Foto profil dipakai bila pengguna sudah mengunggahnya.
    final photo = ProfilePhotoScope.maybeOf(context)?.photoFor(trimmed);
    if (photo != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: ProjectNexusColors.mint,
        backgroundImage: MemoryImage(photo),
      );
    }
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
  const SkillTag(this.label, {this.onDark = false, super.key});

  final String label;

  /// Warna untuk kartu berlatar gelap.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.12)
            : ProjectNexusColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onDark ? Colors.white : ProjectNexusColors.ink,
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
