import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../../dashboard/models/dashboard_models.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../../dashboard/widgets/project_card.dart';
import '../../dashboard/widgets/skill_picker.dart';
import '../certificate.dart';
import '../models/competition.dart';
import '../models/competition_store.dart';

/// Menu Lomba: Papan Info Lomba yang dipasang guru dan Hall of Fame berisi
/// hasil lomba tim siswa.
class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({
    required this.header,
    required this.store,
    required this.projects,
    required this.membersOf,
    required this.userName,
    required this.isTeacher,
    required this.onCreateTeam,
    super.key,
  });

  final Widget header;
  final CompetitionStore store;
  final List<ProjectListing> projects;
  final List<String> Function(String projectId) membersOf;
  final String userName;
  final bool isTeacher;
  final ValueChanged<Competition> onCreateTeam;

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  static const _all = 'Semua';
  bool _showFame = false;
  String _field = _all;

  DateTime get _today => DateTime.now();

  List<ProjectListing> get _results =>
      widget.projects.where((project) => project.result != null).toList()
        ..sort((a, b) {
          final byRank = a.result!.index.compareTo(b.result!.index);
          if (byRank != 0) return byRank;
          return (b.resultAt ?? DateTime(0)).compareTo(
            a.resultAt ?? DateTime(0),
          );
        });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final open = widget.store.competitions
            .where((item) => item.daysLeft(_today) >= 0)
            .toList();
        final results = _results;
        return MenuPage(
          header: widget.header,
          children: [
            HeroBanner(
              eyebrow: 'ARENA LOMBA SISWA',
              title: _showFame ? 'Hall of Fame' : 'Info Lomba',
              subtitle: _showFame
                  ? '${results.length} capaian tim tercatat.'
                  : '${open.length} lomba masih membuka pendaftaran.',
              description: _showFame
                  ? 'Rayakan setiap langkah, dari peserta sampai juara.'
                  : 'Temukan lomba, bentuk tim, dan mulai berkarya.',
              icon: _showFame
                  ? Icons.emoji_events_rounded
                  : Icons.campaign_rounded,
            ),
            const SizedBox(height: 16),
            _Segmented(
              showFame: _showFame,
              onChanged: (value) => setState(() => _showFame = value),
            ),
            const SizedBox(height: 18),
            if (_showFame) ..._buildFame(results) else ..._buildBoard(),
          ],
        );
      },
    );
  }

  List<Widget> _buildBoard() {
    final all = widget.store.competitions;
    final fields = {for (final item in all) item.field}.toList();
    if (!fields.contains(_field)) _field = _all;
    final shown = all
        .where((item) => _field == _all || item.field == _field)
        .toList();
    return [
      if (widget.isTeacher) ...[
        FilledButton.icon(
          key: const Key('competition_add'),
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Pasang info lomba'),
        ),
        const SizedBox(height: 16),
      ],
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final field in [_all, ...fields])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(field),
                  selected: _field == field,
                  showCheckmark: false,
                  selectedColor: ProjectNexusColors.tealDark,
                  labelStyle: TextStyle(
                    color: _field == field
                        ? Colors.white
                        : ProjectNexusColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  onSelected: (_) => setState(() => _field = field),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      if (shown.isEmpty)
        const _EmptyState(
          icon: Icons.campaign_outlined,
          text: 'Belum ada info lomba di bidang ini.',
        )
      else
        for (final competition in shown)
          _CompetitionCard(
            competition: competition,
            today: _today,
            teams: _teamsFor(competition).length,
            onTap: () => _openDetail(competition),
          ),
    ];
  }

  List<ProjectListing> _teamsFor(Competition competition) => widget.projects
      .where((project) => project.competitionId == competition.id)
      .toList();

  List<Widget> _buildFame(List<ProjectListing> results) {
    return [
      if (results.isEmpty)
        const _EmptyState(
          icon: Icons.emoji_events_outlined,
          text:
              'Belum ada hasil lomba yang dicatat. Ketua tim dapat mencatatnya '
              'dari Beranda › Pengajuan saya.',
        )
      else
        for (final project in results)
          _FameCard(
            project: project,
            eventName: _eventName(project),
            members: widget.membersOf(project.id),
            canDownload: widget
                .membersOf(project.id)
                .any(
                  (name) =>
                      name.toLowerCase() ==
                      widget.userName.trim().toLowerCase(),
                ),
            onDownload: () => _download(project),
          ),
    ];
  }

  String _eventName(ProjectListing project) =>
      widget.store.byId(project.competitionId)?.title ?? project.event;

  Future<void> _download(ProjectListing project) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await shareCertificate(
        memberName: widget.userName,
        project: project,
        eventName: _eventName(project),
      );
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(content: Text('Sertifikat gagal dibuat. Coba lagi.')),
      );
    }
  }

  Future<void> _openDetail(Competition competition) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ListenableBuilder(
          listenable: widget.store,
          builder: (context, _) {
            final current = widget.store.byId(competition.id);
            if (current == null) return const SizedBox.shrink();
            return _CompetitionDetailPage(
              competition: current,
              today: _today,
              teams: _teamsFor(current),
              isTeacher: widget.isTeacher,
              onCreateTeam: () {
                Navigator.pop(context);
                widget.onCreateTeam(current);
              },
              onEdit: () => _openForm(current),
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus info lomba?'),
                    content: Text('“${current.title}” akan dihapus.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        key: const Key('confirm_delete'),
                        style: FilledButton.styleFrom(
                          backgroundColor: ProjectNexusColors.error,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
                if ((confirmed ?? false) && context.mounted) {
                  Navigator.pop(context);
                  widget.store.remove(current);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openForm([Competition? initial]) async {
    final saved = await showDialog<Competition>(
      context: context,
      builder: (context) =>
          _CompetitionForm(initial: initial, teacherName: widget.userName),
    );
    if (saved == null) return;
    widget.store.save(saved);
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              initial == null
                  ? 'Info lomba “${saved.title}” dipasang.'
                  : 'Info lomba diperbarui.',
            ),
          ),
        );
    }
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.showFame, required this.onChanged});

  final bool showFame;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(String label, IconData icon, bool value, String key) {
      final selected = showFame == value;
      return Expanded(
        child: Material(
          color: selected ? ProjectNexusColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          elevation: selected ? 1 : 0,
          shadowColor: ProjectNexusColors.tealDeep.withValues(alpha: 0.2),
          child: InkWell(
            key: Key(key),
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: selected
                        ? ProjectNexusColors.teal
                        : ProjectNexusColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? ProjectNexusColors.ink
                          : ProjectNexusColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          option(
            'Info Lomba',
            Icons.campaign_outlined,
            false,
            'competition_tab_board',
          ),
          const SizedBox(width: 4),
          option(
            'Hall of Fame',
            Icons.emoji_events_outlined,
            true,
            'competition_tab_fame',
          ),
        ],
      ),
    );
  }
}

/// Sisa waktu pendaftaran dengan warna: merah ≤ 3 hari, oranye ≤ 7 hari.
({String label, Color color}) deadlineBadge(int daysLeft) {
  if (daysLeft < 0) {
    return (label: 'Pendaftaran ditutup', color: ProjectNexusColors.muted);
  }
  if (daysLeft == 0) {
    return (label: 'Tutup hari ini', color: ProjectNexusColors.error);
  }
  final color = daysLeft <= 3
      ? ProjectNexusColors.error
      : daysLeft <= 7
      ? ProjectNexusColors.warning
      : ProjectNexusColors.success;
  return (label: 'Tutup $daysLeft hari lagi', color: color);
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', //
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _shortDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({
    required this.competition,
    required this.today,
    required this.teams,
    required this.onTap,
  });

  final Competition competition;
  final DateTime today;
  final int teams;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = categoryFor([competition.field, competition.title]);
    final badge = deadlineBadge(competition.daysLeft(today));
    return Card(
      key: Key('competition_${competition.id}'),
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: category.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(category.icon, color: category.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${competition.field} · ${competition.level.label}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: category.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  competition.organizer,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 12),
                      Text(
                        competition.title,
                        style: const TextStyle(
                          color: ProjectNexusColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      if (competition.prize.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              size: 16,
                              color: ProjectNexusColors.gold,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                competition.prize,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: ProjectNexusColors.ink,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Pill(
                            icon: Icons.timer_outlined,
                            label: badge.label,
                            color: badge.color,
                          ),
                          _Pill(
                            icon: Icons.groups_2_outlined,
                            label: teams == 0
                                ? 'Belum ada tim'
                                : '$teams tim terbentuk',
                            color: ProjectNexusColors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionDetailPage extends StatelessWidget {
  const _CompetitionDetailPage({
    required this.competition,
    required this.today,
    required this.teams,
    required this.isTeacher,
    required this.onCreateTeam,
    required this.onEdit,
    required this.onDelete,
  });

  final Competition competition;
  final DateTime today;
  final List<ProjectListing> teams;
  final bool isTeacher;
  final VoidCallback onCreateTeam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = categoryFor([competition.field, competition.title]);
    final daysLeft = competition.daysLeft(today);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail lomba'),
        actions: [
          if (isTeacher) ...[
            IconButton(
              key: const Key('competition_edit'),
              tooltip: 'Edit info lomba',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              key: const Key('competition_delete'),
              tooltip: 'Hapus info lomba',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: ProjectNexusColors.error,
              ),
            ),
          ],
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      category.color,
                      Color.lerp(
                        category.color,
                        ProjectNexusColors.tealDeep,
                        0.6,
                      )!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadows.raised,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(category.icon, color: Colors.white, size: 34),
                    const SizedBox(height: 14),
                    Text(
                      competition.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${competition.organizer} · ${competition.level.label}',
                      style: const TextStyle(color: Color(0xFFE0F0EC)),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          daysLeft < 0 ? '—' : '$daysLeft',
                          style: const TextStyle(
                            color: ProjectNexusColors.goldLight,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            daysLeft < 0
                                ? 'Pendaftaran sudah ditutup'
                                : 'hari lagi sampai pendaftaran ditutup\n'
                                      '(${_shortDate(competition.deadline)})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _Section(
                title: 'Tentang lomba',
                child: Text(
                  competition.description,
                  style: const TextStyle(
                    color: ProjectNexusColors.muted,
                    height: 1.55,
                  ),
                ),
              ),
              if (competition.prize.isNotEmpty)
                _Section(
                  title: 'Hadiah',
                  child: Text(
                    competition.prize,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              if (competition.link.isNotEmpty)
                _Section(
                  title: 'Tautan pendaftaran',
                  child: SelectableText(
                    competition.link,
                    style: const TextStyle(color: ProjectNexusColors.teal),
                  ),
                ),
              _Section(
                title: 'Tim dari sekolah ini (${teams.length})',
                child: teams.isEmpty
                    ? const Text(
                        'Belum ada tim. Jadilah yang pertama membentuk tim!',
                        style: TextStyle(color: ProjectNexusColors.muted),
                      )
                    : Column(
                        children: [
                          for (final team in teams)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: PersonAvatar(team.leader),
                              title: Text(
                                team.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                'Ketua: ${team.leader} · '
                                '${team.statusAcc == 'approved' ? (team.recruitmentOpen ? 'Mencari anggota' : 'Tim lengkap') : 'Menunggu persetujuan guru'}',
                              ),
                            ),
                        ],
                      ),
              ),
              Text(
                'Dipasang oleh ${competition.postedBy}',
                style: const TextStyle(
                  color: ProjectNexusColors.muted,
                  fontSize: 12,
                ),
              ),
              if (!isTeacher && daysLeft >= 0) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const Key('competition_create_team'),
                  onPressed: onCreateTeam,
                  icon: const Icon(Icons.group_add_rounded),
                  label: const Text('Buat tim untuk lomba ini'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ProjectNexusColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Warna medali sesuai hasil lomba.
Color medalColor(CompetitionResult result) => switch (result) {
  CompetitionResult.champion1 => ProjectNexusColors.gold,
  CompetitionResult.champion2 => const Color(0xFF9AA5AD),
  CompetitionResult.champion3 => const Color(0xFFB0704A),
  CompetitionResult.honorable => ProjectNexusColors.teal,
  _ => const Color(0xFF6B7C93),
};

class _FameCard extends StatelessWidget {
  const _FameCard({
    required this.project,
    required this.eventName,
    required this.members,
    required this.canDownload,
    required this.onDownload,
  });

  final ProjectListing project;
  final String eventName;
  final List<String> members;
  final bool canDownload;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final result = project.result!;
    final color = medalColor(result);
    return Card(
      key: Key('fame_${project.id}'),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: result.isWinner
              ? color.withValues(alpha: 0.55)
              : const Color(0xFFEDF1F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color.lerp(color, Colors.white, 0.35)!, color],
                    ),
                  ),
                  child: Icon(
                    result.isWinner
                        ? Icons.emoji_events_rounded
                        : Icons.military_tech_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.label.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        project.title,
                        style: const TextStyle(
                          color: ProjectNexusColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        eventName,
                        style: const TextStyle(
                          color: ProjectNexusColors.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((project.resultNote ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                project.resultNote!,
                style: const TextStyle(
                  color: ProjectNexusColors.ink,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                AvatarStack(members),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    members.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (canDownload) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: Key('certificate_${project.id}'),
                onPressed: onDownload,
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('Unduh sertifikat'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 40, color: ProjectNexusColors.muted),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ProjectNexusColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Form guru untuk memasang atau mengubah info lomba.
class _CompetitionForm extends StatefulWidget {
  const _CompetitionForm({required this.teacherName, this.initial});

  final String teacherName;
  final Competition? initial;

  @override
  State<_CompetitionForm> createState() => _CompetitionFormState();
}

class _CompetitionFormState extends State<_CompetitionForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _organizer = TextEditingController(
    text: widget.initial?.organizer,
  );
  late final _prize = TextEditingController(text: widget.initial?.prize);
  late final _link = TextEditingController(text: widget.initial?.link);
  late final _description = TextEditingController(
    text: widget.initial?.description,
  );
  late String _field =
      widget.initial?.field ?? skillSuggestions.keys.elementAt(1);
  late CompetitionLevel _level = widget.initial?.level ?? CompetitionLevel.city;
  late DateTime _deadline =
      widget.initial?.deadline ?? DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    for (final controller in [
      _title,
      _organizer,
      _prize,
      _link,
      _description,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi.' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(
        widget.initial == null ? 'Pasang info lomba' : 'Edit info lomba',
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('competition_title'),
                controller: _title,
                decoration: const InputDecoration(labelText: 'Nama lomba'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('competition_organizer'),
                controller: _organizer,
                decoration: const InputDecoration(labelText: 'Penyelenggara'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('competition_field'),
                initialValue: _field,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Bidang'),
                items: [
                  for (final field in {
                    ...skillSuggestions.keys.where((key) => key != 'Umum'),
                    'Umum',
                    _field,
                  })
                    DropdownMenuItem(value: field, child: Text(field)),
                ],
                onChanged: (value) => setState(() => _field = value ?? _field),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompetitionLevel>(
                key: const Key('competition_level'),
                initialValue: _level,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tingkat'),
                items: [
                  for (final level in CompetitionLevel.values)
                    DropdownMenuItem(value: level, child: Text(level.label)),
                ],
                onChanged: (value) => setState(() => _level = value ?? _level),
              ),
              const SizedBox(height: 12),
              InkWell(
                key: const Key('competition_deadline'),
                borderRadius: BorderRadius.circular(AppRadius.control),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (picked != null) setState(() => _deadline = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Batas pendaftaran',
                    prefixIcon: Icon(Icons.event_rounded),
                  ),
                  child: Text(_shortDate(_deadline)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('competition_prize'),
                controller: _prize,
                decoration: const InputDecoration(
                  labelText: 'Hadiah (opsional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('competition_link'),
                controller: _link,
                decoration: const InputDecoration(
                  labelText: 'Tautan pendaftaran (opsional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('competition_description'),
                controller: _description,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi dan ketentuan tim',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('competition_save'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              Competition(
                id:
                    widget.initial?.id ??
                    'lomba-${DateTime.now().microsecondsSinceEpoch}',
                title: _title.text.trim(),
                organizer: _organizer.text.trim(),
                field: _field,
                level: _level,
                deadline: _deadline,
                description: _description.text.trim(),
                prize: _prize.text.trim(),
                link: _link.text.trim(),
                postedBy: widget.initial?.postedBy ?? widget.teacherName,
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
