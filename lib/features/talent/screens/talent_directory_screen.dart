import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../../dashboard/models/dashboard_models.dart';
import '../../dashboard/models/profile_data.dart';
import '../../dashboard/widgets/project_card.dart';
import '../models/talent_profile.dart';
import '../models/talent_store.dart';

/// Direktori Bakat: siswa mencari rekan dengan keahlian yang dibutuhkan,
/// lalu mengajaknya bergabung ke proyek yang sedang membuka rekrutmen.
class TalentDirectoryScreen extends StatefulWidget {
  const TalentDirectoryScreen({
    required this.store,
    required this.me,
    required this.myProjects,
    required this.isOnTeam,
    required this.onInvite,
    this.initialProjectId,
    super.key,
  });

  final TalentStore store;
  final String me;

  /// Proyek milik pengguna yang disetujui dan sedang membuka rekrutmen.
  final List<ProjectListing> myProjects;

  /// Apakah siswa sudah menjadi anggota atau pelamar proyek tersebut.
  final bool Function(String projectId, String name) isOnTeam;
  final void Function(ProjectListing project, TalentProfile talent) onInvite;
  final String? initialProjectId;

  @override
  State<TalentDirectoryScreen> createState() => _TalentDirectoryScreenState();
}

class _TalentDirectoryScreenState extends State<TalentDirectoryScreen> {
  late String? _projectId =
      widget.initialProjectId ??
      (widget.myProjects.length == 1 ? widget.myProjects.single.id : null);
  String _query = '';
  String _interest = 'Semua';

  ProjectListing? get _project {
    for (final project in widget.myProjects) {
      if (project.id == _projectId) return project;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Direktori Bakat')),
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final project = _project;
          final all = widget.store.directoryFor(
            widget.me,
            neededSkills: project?.skills ?? const [],
          );
          final interests = [
            for (final interest in availableStudentInterests)
              if (all.any((t) => t.interests.contains(interest))) interest,
          ];
          final visible = [
            for (final talent in all)
              if (talent.matchesQuery(_query) &&
                  (_interest == 'Semua' ||
                      talent.interests.contains(_interest)))
                talent,
          ];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _Intro(count: all.length),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('talent_search'),
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama, keahlian, atau minat',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  if (widget.myProjects.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      key: const Key('talent_project'),
                      initialValue: _projectId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Cari anggota untuk',
                        prefixIcon: Icon(Icons.groups_2_outlined, size: 20),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Semua siswa'),
                        ),
                        for (final project in widget.myProjects)
                          DropdownMenuItem(
                            value: project.id,
                            child: Text(
                              project.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (id) => setState(() => _projectId = id),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    const _Hint(
                      'Ajukan proyek dan buka rekrutmen agar kamu bisa '
                      'mengajak siswa bergabung ke timmu.',
                    ),
                  ],
                  if (interests.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final interest in ['Semua', ...interests])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                key: Key('talent_interest_$interest'),
                                label: Text(interest),
                                selected: _interest == interest,
                                onSelected: (_) =>
                                    setState(() => _interest = interest),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (visible.isEmpty)
                    _Hint(
                      all.isEmpty
                          ? 'Belum ada siswa lain di direktori. Profil siswa '
                                'muncul di sini setelah mereka membuka aplikasi.'
                          : 'Tidak ada siswa yang cocok dengan pencarianmu.',
                    ),
                  for (final talent in visible)
                    _TalentCard(
                      talent: talent,
                      project: project,
                      canInvite: widget.myProjects.isNotEmpty,
                      status: _statusFor(talent, project),
                      onInvite: () => _invite(talent),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _InviteStatus _statusFor(TalentProfile talent, ProjectListing? project) {
    if (!talent.openToInvite) return _InviteStatus.closed;
    if (project == null) return _InviteStatus.available;
    if (widget.isOnTeam(project.id, talent.name)) return _InviteStatus.onTeam;
    if (widget.store.wasInvited(project.id, talent.name)) {
      return _InviteStatus.invited;
    }
    return _InviteStatus.available;
  }

  Future<void> _invite(TalentProfile talent) async {
    final project = _project ?? await _pickProject();
    if (project == null || !mounted) return;
    final status = _statusFor(talent, project);
    if (status != _InviteStatus.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(switch (status) {
            _InviteStatus.onTeam =>
              '${talent.name} sudah bergabung atau melamar ke ${project.title}.',
            _InviteStatus.invited =>
              '${talent.name} sudah kamu ajak ke ${project.title}.',
            _ => '${talent.name} sedang tidak menerima ajakan.',
          }),
        ),
      );
      return;
    }
    widget.onInvite(project, talent);
    setState(() => _projectId = project.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ajakan terkirim. ${talent.name} akan menerima notifikasi.',
        ),
      ),
    );
  }

  Future<ProjectListing?> _pickProject() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Ajak ke proyek mana?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          for (final project in widget.myProjects)
            ListTile(
              key: Key('invite_project_${project.id}'),
              leading: const Icon(Icons.folder_open_rounded),
              title: Text(project.title),
              subtitle: Text(project.event),
              onTap: () => Navigator.pop(context, project),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

enum _InviteStatus { available, invited, onTeam, closed }

class _Intro extends StatelessWidget {
  const _Intro({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: const LinearGradient(
          colors: [ProjectNexusColors.tealDark, ProjectNexusColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.diversity_3_rounded,
            color: ProjectNexusColors.goldLight,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count siswa siap berkolaborasi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tim hebat butuh keahlian yang beragam: penari, atlet, '
                  'penulis, peneliti, sampai desainer.',
                  style: TextStyle(color: Color(0xFFD7E9E5), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProjectNexusColors.mint,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: ProjectNexusColors.tealDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ProjectNexusColors.tealDark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  const _TalentCard({
    required this.talent,
    required this.project,
    required this.canInvite,
    required this.status,
    required this.onInvite,
  });

  final TalentProfile talent;
  final ProjectListing? project;
  final bool canInvite;
  final _InviteStatus status;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final matches = talent.matchingSkills(project?.skills ?? const []);
    final matchSet = {for (final skill in matches) skill};
    return Container(
      key: Key('talent_${talent.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: ProjectNexusColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: matches.isEmpty
              ? ProjectNexusColors.border
              : ProjectNexusColors.goldLight,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PersonAvatar(talent.name, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      talent.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${talent.weeklyHours} jam/minggu'
                      '${talent.interests.isEmpty ? '' : ' · ${talent.interests.join(', ')}'}',
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
              StatusPill(
                label: talent.openToInvite ? 'Terbuka' : 'Sedang sibuk',
                color: talent.openToInvite
                    ? ProjectNexusColors.success
                    : ProjectNexusColors.muted,
              ),
            ],
          ),
          if (talent.bio.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              talent.bio,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final skill in talent.skills)
                matchSet.contains(skill)
                    ? StatusPill(
                        label: '★ $skill',
                        color: ProjectNexusColors.gold,
                      )
                    : SkillTag(skill),
            ],
          ),
          if (canInvite) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (matches.isNotEmpty)
                  Expanded(
                    child: Text(
                      'Cocok: ${matches.length} keahlian dibutuhkan',
                      style: const TextStyle(
                        color: ProjectNexusColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                FilledButton.tonal(
                  key: Key('invite_${talent.id}'),
                  onPressed: status == _InviteStatus.available
                      ? onInvite
                      : null,
                  child: Text(switch (status) {
                    _InviteStatus.available => 'Ajak ke tim',
                    _InviteStatus.invited => 'Sudah diajak',
                    _InviteStatus.onTeam => 'Sudah di tim',
                    _InviteStatus.closed => 'Tidak menerima ajakan',
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
