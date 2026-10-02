import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../../auth/models/user_role.dart';
import '../data/dashboard_sample_data.dart';
import '../models/dashboard_models.dart';
import '../models/portfolio_item.dart';
import '../models/profile_data.dart';
import '../models/workspace_task.dart';
import '../widgets/achievement_card.dart';
import '../widgets/approval_request_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_tab_bar.dart';
import '../widgets/draft_project_sheet.dart';
import '../widgets/project_card.dart';
import '../widgets/skill_filter_list.dart';
import 'portfolio_screen.dart';
import 'profile_screen.dart';
import 'workspace_screen.dart';

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
  static const _ink = ProjectNexusColors.ink;

  late final List<ProjectListing> _projects = [...dashboardProjects];
  int _navigationIndex = 0;
  int _dashboardTab = 0;
  String _selectedSkill = 'Semua';
  String _searchQuery = '';
  final Set<String> _appliedProjectTitles = {};
  final List<WorkspaceTask> _workspaceTasks = [
    const WorkspaceTask(
      title: 'Riset parameter kualitas air',
      assignee: 'Rizky Ramadhan',
      dueLabel: 'Hari ini',
      status: WorkspaceTaskStatus.done,
    ),
    const WorkspaceTask(
      title: 'Menyusun rancangan sensor IoT',
      assignee: 'Nadia Putri',
      dueLabel: 'Besok',
      status: WorkspaceTaskStatus.inProgress,
    ),
    const WorkspaceTask(
      title: 'Membuat tampilan dashboard aplikasi',
      assignee: 'Ryan Anggara Deki',
      dueLabel: '12 Okt 2026',
      status: WorkspaceTaskStatus.inProgress,
    ),
    const WorkspaceTask(
      title: 'Menghubungkan data sensor ke aplikasi',
      assignee: 'Ryan Anggara Deki',
      dueLabel: '15 Okt 2026',
      status: WorkspaceTaskStatus.todo,
    ),
    const WorkspaceTask(
      title: 'Menyiapkan bahan presentasi proyek',
      assignee: 'Nadia Putri',
      dueLabel: '18 Okt 2026',
      status: WorkspaceTaskStatus.todo,
    ),
  ];
  final List<PortfolioItem> _portfolioItems = [
    const PortfolioItem(
      owner: 'Ryan Anggara Deki',
      title: 'Aplikasi Jadwal Kelas',
      category: 'Mobile Development',
      description:
          'Aplikasi Flutter untuk membantu siswa melihat jadwal dan pengingat kelas.',
      year: '2026',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF087E8B),
    ),
    const PortfolioItem(
      owner: 'Ryan Anggara Deki',
      title: 'Desain Ulang Perpustakaan Digital',
      category: 'UI/UX',
      description:
          'Membuat prototipe antarmuka peminjaman buku yang mudah digunakan.',
      year: '2025',
      icon: Icons.design_services_outlined,
      color: Color(0xFFC46A3A),
    ),
    const PortfolioItem(
      owner: 'Nadia Putri',
      title: 'Inovasi Teknologi Lingkungan',
      category: 'Prestasi · Tingkat Provinsi',
      description:
          'Merancang sistem pemantauan lingkungan untuk kompetisi sains pelajar.',
      year: '2025',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFF536B45),
    ),
    const PortfolioItem(
      owner: 'Rizky Ramadhan',
      title: 'Peta Cerita Sejarah Lokal',
      category: 'Riset & Data',
      description:
          'Mengumpulkan cerita sejarah lokal dan menyajikannya dalam peta interaktif.',
      year: '2025',
      icon: Icons.map_outlined,
      color: Color(0xFF6657A5),
    ),
  ];
  late ProfileData _profile = _isTeacherView
      ? const ProfileData(
          name: 'Budi Santoso',
          roleLabel: 'Guru Pendamping · Teknologi Informasi',
          institution: 'ProjectNexus · SMA Nusantara',
          email: 'budi.santoso@school.id',
          bio:
              'Mendampingi siswa mengembangkan ide teknologi menjadi proyek yang berdampak dan siap berkompetisi.',
          skills: ['Mentoring', 'IoT', 'Riset', 'Pengembangan Proyek'],
        )
      : const ProfileData(
          name: 'Ryan Anggara Deki',
          roleLabel: 'Siswa · Kelas XI',
          institution: 'SMA Nusantara · Bandar Lampung',
          email: 'ryan@school.id',
          bio:
              'Siswa yang tertarik pada pengembangan aplikasi mobile, desain produk digital, dan kolaborasi lintas keahlian.',
          skills: ['Flutter', 'UI/UX', 'Prototyping', 'Kolaborasi'],
        );

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
            : _navigationIndex == 1
            ? _buildWorkspace()
            : _navigationIndex == 2
            ? _buildPortfolio()
            : _buildProfile(),
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

  Widget _buildWorkspace() {
    return WorkspaceScreen(
      tasks: _workspaceTasks,
      isTeacherView: _isTeacherView,
      onAddTask: (task) => setState(() => _workspaceTasks.add(task)),
      onTaskStatusChanged: _updateWorkspaceTaskStatus,
    );
  }

  Widget _buildPortfolio() {
    return PortfolioScreen(
      role: widget.role,
      items: _portfolioItems,
      onAddItem: (item) => setState(() => _portfolioItems.insert(0, item)),
    );
  }

  Widget _buildProfile() {
    return ProfileScreen(
      profile: _profile,
      onProfileChanged: (profile) => setState(() => _profile = profile),
    );
  }

  void _updateWorkspaceTaskStatus(
    WorkspaceTask task,
    WorkspaceTaskStatus status,
  ) {
    setState(() {
      final index = _workspaceTasks.indexOf(task);
      if (index != -1) {
        _workspaceTasks[index] = task.copyWith(status: status);
      }
    });
  }

  Widget _buildDashboard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              sliver: SliverList.list(
                children: [
                  DashboardHeader(isTeacherView: false, onLogout: _logout),
                  const SizedBox(height: 22),
                  _buildStudentWelcome(),
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
        ),
      ),
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              sliver: SliverList.list(
                children: [
              DashboardHeader(isTeacherView: true, onLogout: _logout),
              const SizedBox(height: 22),
              _buildTeacherWelcome(pendingProjects.length),
              const SizedBox(height: 20),
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
        ),
      ),
    );
  }

  Widget _buildStudentWelcome() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ProjectNexusColors.tealDark, Color(0xFF176B68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ProjectNexusColors.tealDark.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'RUANG KOLABORASI SISWA',
                    style: TextStyle(
                      color: Color(0xFFC9E9E2),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Temukan tim yang tepat.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Ide hebat tumbuh bersama keahlian yang beragam.',
                  style: TextStyle(
                    color: Color(0xFFD7E9E5),
                    height: 1.45,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.groups_2_rounded,
            color: Color(0xFFB9E2D8),
            size: 55,
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherWelcome(int pendingCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: ProjectNexusColors.tealDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.fact_check_outlined,
            color: Color(0xFFB9E2D8),
            size: 28,
          ),
          const SizedBox(height: 13),
          Text(
            'Antrean persetujuan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$pendingCount draf menunggu tinjauan',
            style: const TextStyle(color: Color(0xFFD7E9E5), height: 1.4),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProjectFeed() {
    return [
      TextField(
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
        decoration: InputDecoration(
          hintText: 'Cari proyek, lomba, atau keahlian',
          prefixIcon: const Icon(Icons.search_rounded),
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
          color: ProjectNexusColors.tealDark,
          borderRadius: BorderRadius.circular(22),
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
