import 'package:flutter/material.dart';

import '../../auth/models/user_role.dart';
import '../data/dashboard_sample_data.dart';
import '../models/dashboard_models.dart';
import '../widgets/achievement_card.dart';
import '../widgets/approval_request_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_tab_bar.dart';
import '../widgets/draft_project_sheet.dart';
import '../widgets/project_card.dart';
import '../widgets/skill_filter_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.role,
    required this.onLogout,
    super.key,
  });

  final UserRole role;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _ink = Color(0xFF172A2D);

  late final List<ProjectListing> _projects = [...dashboardProjects];
  int _navigationIndex = 0;
  int _dashboardTab = 0;
  String _selectedSkill = 'Semua';
  String _searchQuery = '';
  final Set<String> _appliedProjectTitles = {};

  bool get _isTeacherView => widget.role == UserRole.teacher;

  List<ProjectListing> get _visibleProjects => _projects.where((project) {
    final matchesSkill =
        _selectedSkill == 'Semua' || project.skills.contains(_selectedSkill);
    final searchText =
        '${project.title} ${project.leader} ${project.event} ${project.skills.join(' ')}'
            .toLowerCase();
    return project.statusAcc == 'approved' &&
        matchesSkill &&
        searchText.contains(_searchQuery.toLowerCase());
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _navigationIndex == 0
            ? _isTeacherView
                  ? _buildTeacherQueue()
                  : _buildDashboard()
            : _buildPlaceholder(),
      ),
      floatingActionButton: !_isTeacherView && _navigationIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openDraftForm,
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Ajukan proyek'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navigationIndex,
        onDestinationSelected: (index) {
          setState(() => _navigationIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_kanban_outlined),
            selectedIcon: Icon(Icons.view_kanban_rounded),
            label: 'Workspace',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark_rounded),
            label: 'Portofolio',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          sliver: SliverList.list(
            children: [
              DashboardHeader(isTeacherView: false, onLogout: _logout),
              const SizedBox(height: 28),
              Text(
                'Temukan tim yang tepat.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Ide hebat tumbuh bersama keahlian yang beragam.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: const Color(0xFF627174)),
              ),
              const SizedBox(height: 22),
              DashboardTabBar(
                selectedIndex: _dashboardTab,
                onChanged: (index) => setState(() => _dashboardTab = index),
              ),
              const SizedBox(height: 18),
              if (_dashboardTab == 0) ..._buildProjectFeed(),
              if (_dashboardTab == 1) ..._buildAchievementCatalog(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherQueue() {
    final pendingProjects = _projects
        .where(
          (project) =>
              project.statusAcc == 'pending' &&
              project.teacherName == 'Budi Santoso',
        )
        .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          sliver: SliverList.list(
            children: [
              DashboardHeader(isTeacherView: true, onLogout: _logout),
              const SizedBox(height: 28),
              Text(
                'Antrean persetujuan',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: _ink, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                '${pendingProjects.length} draf menunggu tinjauan',
                style: const TextStyle(color: Color(0xFF627174)),
              ),
              const SizedBox(height: 18),
              if (pendingProjects.isEmpty)
                const _EmptyApprovalState()
              else
                ...pendingProjects.map(
                  (project) => ApprovalRequestCard(
                    project: project,
                    onApprove: () => _updateProjectStatus(project, 'approved'),
                    onReject: () => _updateProjectStatus(project, 'rejected'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildProjectFeed() {
    return [
      TextField(
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
        decoration: InputDecoration(
          hintText: 'Cari proyek, lomba, atau keahlian',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 14),
      SkillFilterList(
        selectedSkill: _selectedSkill,
        onSelected: (skill) => setState(() => _selectedSkill = skill),
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          Text(
            'Rekrutmen terbuka',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: _ink, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Text(
            '${_visibleProjects.length} proyek',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: const Color(0xFF627174)),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (_visibleProjects.isEmpty)
        const _EmptySearchState()
      else
        ..._visibleProjects.map(
          (project) => ProjectCard(
            project: project,
            onDetails: () => _showProjectDetails(project),
          ),
        ),
    ];
  }

  List<Widget> _buildAchievementCatalog() {
    return [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF173D3D),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events_outlined, color: Color(0xFFF1C36D)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Karya yang membanggakan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Lihat perjalanan prestasi siswa sekolah.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      ...schoolAchievements.map(AchievementCard.new),
    ];
  }

  Widget _buildPlaceholder() {
    const sections = [
      (
        'Workspace tim',
        'Papan tugas tim yang sudah terbentuk akan tersedia di sini.',
        Icons.view_kanban_outlined,
      ),
      (
        'Portofolio',
        'Karya dan sertifikatmu akan tersusun di sini.',
        Icons.collections_bookmark_outlined,
      ),
      (
        'Profil',
        'Informasi akun dan keahlianmu akan tersedia di sini.',
        Icons.person_outline_rounded,
      ),
    ];
    final section = sections[_navigationIndex - 1];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(section.$3, size: 48, color: const Color(0xFF087E8B)),
            const SizedBox(height: 14),
            Text(
              section.$1,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: _ink, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              section.$2,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF627174), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProjectDetails(ProjectListing project) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(project.description),
              const SizedBox(height: 14),
              Text('Ketua: ${project.leader}'),
              Text('Target: ${project.event}'),
              const SizedBox(height: 12),
              const Text(
                'Keahlian yang dicari',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: project.skills.map(SkillTag.new).toList(),
              ),
            ],
          ),
        ),
        actions: [
          if (!_isTeacherView)
            FilledButton(
              onPressed: _appliedProjectTitles.contains(project.title)
                  ? null
                  : () {
                      Navigator.pop(context);
                      setState(() => _appliedProjectTitles.add(project.title));
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pengajuan bergabung terkirim kepada ketua proyek.',
                          ),
                        ),
                      );
                    },
              child: Text(
                _appliedProjectTitles.contains(project.title)
                    ? 'Pengajuan terkirim'
                    : 'Ajukan bergabung',
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDraftForm() async {
    final submittedProject = await showModalBottomSheet<ProjectListing>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DraftProjectSheet(),
    );
    if (submittedProject != null && mounted) {
      setState(() => _projects.add(submittedProject));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draf terkirim dan menunggu persetujuan guru.'),
        ),
      );
    }
  }

  void _logout() {
    widget.onLogout();
  }

  void _updateProjectStatus(ProjectListing project, String status) {
    setState(() {
      final index = _projects.indexOf(project);
      if (index != -1) {
        _projects[index] = project.copyWith(statusAcc: status);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'approved'
              ? 'Proyek disetujui dan sudah masuk feed.'
              : 'Pengajuan proyek ditolak.',
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF849294)),
          SizedBox(height: 10),
          Text(
            'Belum ada proyek yang cocok.',
            style: TextStyle(color: Color(0xFF627174)),
          ),
        ],
      ),
    );
  }
}

class _EmptyApprovalState extends StatelessWidget {
  const _EmptyApprovalState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.task_alt_rounded, size: 40, color: Color(0xFF087E8B)),
          SizedBox(height: 12),
          Text(
            'Tidak ada draf yang menunggu persetujuan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF627174)),
          ),
        ],
      ),
    );
  }
}
