import 'package:flutter/material.dart';

import '../../core/theme/project_nexus_colors.dart';
import 'missions.dart';

/// Kartu ringkas di Beranda: tingkat, XP, dan misi berikutnya.
class MissionCard extends StatelessWidget {
  const MissionCard({required this.progress, required this.onStart, super.key});

  final MissionProgress progress;
  final ValueChanged<MissionTarget> onStart;

  @override
  Widget build(BuildContext context) {
    final next = progress.nextMission;
    final nextLevel = progress.nextLevel;
    return Material(
      key: const Key('mission_card'),
      color: ProjectNexusColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => showMissionSheet(context, progress, onStart),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: ProjectNexusColors.goldLight),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  LevelBadge(level: progress.level.number),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${progress.level.number} · ${progress.level.title}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextLevel == null
                              ? '${progress.xp} XP · level tertinggi tercapai!'
                              : '${progress.xp} XP · ${nextLevel.minXp - progress.xp} XP lagi ke ${nextLevel.title}',
                          style: const TextStyle(
                            color: ProjectNexusColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${progress.completed}/${progress.missions.length}',
                    style: const TextStyle(
                      color: ProjectNexusColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Kemajuan sudah dibacakan lewat teks XP di atas.
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: progress.levelProgress,
                    minHeight: 8,
                    backgroundColor: ProjectNexusColors.goldSoft,
                    color: ProjectNexusColors.gold,
                  ),
                ),
              ),
              if (next != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(next.icon, size: 20, color: ProjectNexusColors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Misi berikutnya: ',
                              style: TextStyle(color: ProjectNexusColors.muted),
                            ),
                            TextSpan(
                              text: next.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    XpPill(xp: next.xp),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lencana bulat bertuliskan nomor level.
class LevelBadge extends StatelessWidget {
  const LevelBadge({required this.level, this.size = 44, super.key});

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [ProjectNexusColors.goldLight, ProjectNexusColors.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        '$level',
        style: TextStyle(
          color: ProjectNexusColors.tealDeep,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class XpPill extends StatelessWidget {
  const XpPill({required this.xp, super.key});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ProjectNexusColors.goldSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '+$xp XP',
        style: const TextStyle(
          color: ProjectNexusColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Daftar semua misi. Misi yang belum selesai punya tombol "Mulai".
Future<void> showMissionSheet(
  BuildContext context,
  MissionProgress progress,
  ValueChanged<MissionTarget> onStart,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.75,
    maxChildSize: 0.95,
    builder: (context, controller) => ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const Text(
          'Misi Pemula',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Selesaikan misi untuk naik level. ${progress.xp} dari '
          '${progress.maxXp} XP terkumpul.',
          style: const TextStyle(color: ProjectNexusColors.muted),
        ),
        const SizedBox(height: 16),
        for (final mission in progress.missions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MissionTile(
              mission: mission,
              onStart: () {
                Navigator.pop(context);
                onStart(mission.target);
              },
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Tingkatan',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final level in missionLevels)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: LevelBadge(level: level.number, size: 32),
            title: Text(
              level.title,
              style: TextStyle(
                fontWeight: level.number == progress.level.number
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
            trailing: Text('${level.minXp} XP'),
          ),
      ],
    ),
  ),
);

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.mission, required this.onStart});

  final Mission mission;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('mission_${mission.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mission.done
            ? ProjectNexusColors.mint
            : ProjectNexusColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(
          color: mission.done
              ? ProjectNexusColors.mint
              : ProjectNexusColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            mission.done ? Icons.check_circle_rounded : mission.icon,
            color: mission.done
                ? ProjectNexusColors.success
                : ProjectNexusColors.teal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: mission.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mission.hint,
                  style: const TextStyle(
                    color: ProjectNexusColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (mission.done)
            XpPill(xp: mission.xp)
          else
            TextButton(
              key: Key('mission_start_${mission.id}'),
              onPressed: onStart,
              child: Text('Mulai · +${mission.xp}'),
            ),
        ],
      ),
    );
  }
}
