import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../../auth/models/user_role.dart';
import '../data/dashboard_sample_data.dart';
import '../models/dashboard_models.dart';
import '../models/project_application.dart';
import '../models/portfolio_item.dart';
import '../models/project_workflow_store.dart';
import '../models/profile_data.dart';
import '../models/workspace_task.dart';
import '../widgets/achievement_card.dart';
import '../widgets/approval_request_card.dart';
import '../widgets/applicant_management_dialog.dart';
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
    required this.projectStore,
    this.studentName,
    this.teacherName,
    super.key,
  });

  final UserRole role;
  final VoidCallback onLogout;
  final ProjectWorkflowStore projectStore;
  final String? studentName;
  final String? teacherName;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _ink = ProjectNexusColors.ink;

  int _navigationIndex = 0;
  int _dashboardTab = 0;
  String? _selectedWorkspaceProjectId;
  String _selectedSkill = 'Semua';
  String _searchQuery = '';
  final Map<String, List<WorkspaceTask>> _workspaceTasks = {
    'sample-water-iot': [
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
    ],
  };
  final List<PortfolioItem> _portfolioItems = [
    const PortfolioItem(
      owner: 'Ryan Anggara Deki',
      title: 'Aplikasi Jadwal Kelas',
      category: 'Mobile Development',
      description: 'Aplikasi Flutter untuk membantu siswa melihat jadwal dan pengingat kelas.',
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
      description: 'Merancang sistem pemantauan lingkungan untuk kompetisi sains pelajar.',
      year: '2025',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFF536B45),
    ),
    const PortfolioItem(
      owner: 'Rizky Ramadhan',
      title: 'Peta Cerita Sejarah Lokal',
      category: 'Riset & Data',
      description: 'Mengumpulkan cerita sejarah lokal dan menyajikannya dalam peta interaktif.',
      year: '2025',
      icon: Icons.map_outlined,
      color: Color(0xFF6657A5),
    ),
  ];
  late ProfileData _profile = _isTeacherView
      ? ProfileData(
          name: _currentTeacherName,
          roleLabel: 'Guru Pendamping · Teknologi Informasi',
          institution: 'ProjectNexus · SMA Nusantara',
          email: _teacherEmail,
          bio: 'Mendampingi siswa mengembangkan ide teknologi menjadi proyek yang berdampak dan siap berkompetisi.',
          skills: ['Mentoring', 'IoT', 'Riset', 'Pengembangan Proyek'],
        )
      : ProfileData(
          name: widget.studentName ?? 'Ryan Anggara Deki',
          roleLabel: 'Siswa · Kelas XI',
          institution: 'SMA Nusantara · Bandar Lampung',
          email: 'ryan@school.id',
          bio: 'Siswa yang tertarik pada pengembangan aplikasi mobile, desain produk digital, dan kolaborasi lintas keahlian.',
          skills: ['Flutter', 'UI/UX', 'Prototyping', 'Kolaborasi'],
        );

  bool get _isTeacherView => widget.role == UserRole.teacher;
  String get _currentTeacherName => widget.teacherName ?? 'Budi Santoso';
  String get _teacherEmail => _currentTeacherName == 'Siti Rahmawati'
      ? 'siti.rahmawati@school.id'
      : 'budi.santoso@school.id';
  List<ProjectListing> get _projects => widget.projectStore.projects;

  List<ProjectListing> get _visibleProjects => _projects.where((project) {
    final matchesSkill =
        _selectedSkill == 'Semua' || project.skills.contains(_selectedSkill);
    final searchText =
        '${project.title} ${project.leader} ${project.event} ${project.skills.join(' ')}'
            .toLowerCase();
    return project.statusAcc == 'approved' &&
        project.recruitmentOpen &&
        matchesSkill &&
        searchText.contains(_searchQuery.toLowerCase());
  }).toList();

  @override
  void initState() {
    super.initState();
    widget.projectStore.addListener(_onProjectStoreChanged);
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectStore != widget.projectStore) {
      oldWidget.projectStore.removeListener(_onProjectStoreChanged);
      widget.projectStore.addListener(_onProjectStoreChanged);
    }
  }

  @override
  void dispose() {
    widget.projectStore.removeListener(_onProjectStoreChanged);
    super.dispose();
  }

  void _onProjectStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 1000;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (isWideLayout) ...[
                  _buildSideNavigation(),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: ProjectNexusColors.border,
                  ),
                ],
                Expanded(child: _buildCurrentPage()),
              ],
            ),
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
          bottomNavigationBar: isWideLayout ? null : _buildBottomNavigation(),
        );
      },
    );
  }

  Widget _buildCurrentPage() {
    if (_navigationIndex == 0) {
      return _isTeacherView ? _buildTeacherQueue() : _buildDashboard();
    }
    if (_navigationIndex == 1) return _buildWorkspace();
    if (_navigationIndex == 2) return _buildPortfolio();
    return _buildProfile();
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 248,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 30),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ProjectNexusColors.teal,
                        ProjectNexusColors.tealDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ProjectNexus',
                        style: TextStyle(
                          color: ProjectNexusColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'RUANG KOLABORASI',
                        style: TextStyle(
                          color: ProjectNexusColors.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Text(
              _isTeacherView ? 'PANEL GURU' : 'RUANG SISWA',
              style: const TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: NavigationRail(
              extended: true,
              minExtendedWidth: 212,
              backgroundColor: Colors.transparent,
              selectedIndex: _navigationIndex,
              onDestinationSelected: (index) {
                setState(() => _navigationIndex = index);
              },
              useIndicator: true,
              indicatorColor: ProjectNexusColors.mint,
              selectedIconTheme: const IconThemeData(
                color: ProjectNexusColors.tealDark,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: ProjectNexusColors.tealDark,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              unselectedIconTheme: const IconThemeData(
                color: ProjectNexusColors.muted,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: ProjectNexusColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Beranda'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.view_kanban_outlined),
                  selectedIcon: Icon(Icons.view_kanban_rounded),
                  label: Text('Workspace'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.collections_bookmark_outlined),
                  selectedIcon: Icon(Icons.collections_bookmark_rounded),
                  label: Text('Portofolio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profil'),
                ),
              ],
            ),
          ),
          const Divider(color: ProjectNexusColors.border),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: ProjectNexusColors.mint,
              child: Text(
                _profile.name.isEmpty ? '?' : _profile.name[0].toUpperCase(),
                style: const TextStyle(
                  color: ProjectNexusColors.tealDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              _profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ProjectNexusColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              _isTeacherView ? 'Guru pendamping' : 'Siswa',
              style: const TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 10,
              ),
            ),
            trailing: IconButton(
              tooltip: 'Keluar',
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, size: 19),
              color: ProjectNexusColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      height: 72,
      elevation: 12,
      shadowColor: ProjectNexusColors.ink.withValues(alpha: 0.08),
      selectedIndex: _navigationIndex,
      onDestinationSelected: (index) {
        setState(() => _navigationIndex = index);
      },
      destinations: _navigationDestinations,
    );
  }

  static const _navigationDestinations = [
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
  ];

  Widget _buildWorkspace() {
    final project = _workspaceProject;
    if (project == null) {
      return const _WorkspaceAccessState();
    }
    final tasks = _workspaceTasks.putIfAbsent(project.id, () => []);
    return WorkspaceScreen(
      availableProjects: _workspaceProjects,
      selectedProjectId: project.id,
      onProjectChanged: (projectId) =>
          setState(() => _selectedWorkspaceProjectId = projectId),
      projectTitle: project.title,
      members: _workspaceMembers(project),
      tasks: tasks,
      isTeacherView: _isTeacherView,
      onAddTask: (task) => setState(() => tasks.add(task)),
      onTaskStatusChanged: (task, status) =>
          _updateWorkspaceTaskStatus(project.id, task, status),
    );
  }

  List<ProjectListing> get _workspaceProjects => _projects.where((project) {
    final name = _isTeacherView ? _currentTeacherName : _profile.name;
    return widget.projectStore.canAccessWorkspace(
      project.id,
      name,
      widget.role,
    );
  }).toList();

  ProjectListing? get _workspaceProject {
    final accessibleProjects = _workspaceProjects;
    if (accessibleProjects.isEmpty) return null;
    final selectedProject = accessibleProjects.where(
      (project) => project.id == _selectedWorkspaceProjectId,
    );
    if (selectedProject.isNotEmpty) return selectedProject.first;
    return accessibleProjects.firstWhere(
      (project) => _workspaceTasks.containsKey(project.id),
      orElse: () => accessibleProjects.first,
    );
  }

  List<(String, String)> _workspaceMembers(ProjectListing project) {
    final members = <(String, String)>[(project.leader, 'Ketua proyek')];
    for (final name
        in widget.projectStore.acceptedMembers(project.id).skip(1)) {
      if (name != project.leader) members.add((name, 'Anggota tim'));
    }
    if (!members.any((member) => member.$1 == project.teacherName)) {
      members.add((project.teacherName, 'Guru pendamping'));
    }
    return members;
  }

  Widget _buildPortfolio() {
    return PortfolioScreen(
      role: widget.role,
      studentName: _profile.name,
      items: _portfolioItems,
      onAddItem: (item) => setState(
        () => _portfolioItems.insert(0, item.copyWith(owner: _profile.name)),
      ),
    );
  }

  Widget _buildProfile() {
    return ProfileScreen(
      profile: _profile,
      onProfileChanged: (profile) => setState(() => _profile = profile),
    );
  }

  void _updateWorkspaceTaskStatus(
    String projectId,
    WorkspaceTask task,
    WorkspaceTaskStatus status,
  ) {
    setState(() {
      final tasks = _workspaceTasks.putIfAbsent(projectId, () => []);
      final index = tasks.indexOf(task);
      if (index != -1) {
        tasks[index] = task.copyWith(status: status);
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
                  const SizedBox(height: 25),
                  _buildStudentWelcome(),
                  const SizedBox(height: 18),
                  _buildStudentOverview(),
                  const SizedBox(height: 24),
                  DashboardTabBar(
                    selectedIndex: _dashboardTab,
                    onChanged: (index) => setState(() => _dashboardTab = index),
                  ),
                  const SizedBox(height: 18),
                  if (_dashboardTab == 0) ..._buildProjectFeed(),
                  if (_dashboardTab == 1) ..._buildStudentSubmissions(),
                  if (_dashboardTab == 2) ..._buildStudentApplications(),
                  if (_dashboardTab == 3) ..._buildAchievementCatalog(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentOverview() {
    final myProjects = _projects
        .where((project) => project.leader == _profile.name)
        .toList();
    final underReview = myProjects
        .where((project) => project.statusAcc == 'pending')
        .length;
    final approved = myProjects
        .where((project) => project.statusAcc == 'approved')
        .length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 24) / 3;
        return Row(
          children: [
            SizedBox(
              width: cardWidth,
              child: _OverviewMetricCard(
                label: 'Pengajuan',
                value: '${myProjects.length}',
                icon: Icons.folder_open_rounded,
                accent: const Color(0xFF476D73),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: cardWidth,
              child: _OverviewMetricCard(
                label: 'Ditinjau',
                value: '$underReview',
                icon: Icons.hourglass_top_rounded,
                accent: const Color(0xFFAA7135),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: cardWidth,
              child: _OverviewMetricCard(
                label: 'Diterima',
                value: '$approved',
                icon: Icons.verified_outlined,
                accent: const Color(0xFF39825A),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeacherQueue() {
    final pendingProjects = _projects
        .where(
          (project) =>
              project.statusAcc == 'pending' &&
              project.teacherName == _currentTeacherName,
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
                        onApprove: () =>
                            _updateProjectStatus(project, 'approved'),
                        onReject: () => _rejectProject(project),
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

  List<Widget> _buildStudentSubmissions() {
    final submissions = _projects
        .where((project) => project.leader == _profile.name)
        .toList();
    if (submissions.isEmpty) {
      return const [_EmptyStudentSubmissionState()];
    }
    return [
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.track_changes_rounded, color: ProjectNexusColors.teal),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pantau status dan masukan guru untuk setiap pengajuanmu.',
                style: TextStyle(
                  color: ProjectNexusColors.ink,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      ...submissions.map(
        (project) => _StudentSubmissionCard(
          project,
          onRevise: project.statusAcc == 'rejected'
              ? () => _reviseProject(project)
              : null,
          onManageApplicants: project.statusAcc == 'approved'
              ? () => _showApplicantManagement(project)
              : null,
        ),
      ),
    ];
  }

  List<Widget> _buildStudentApplications() {
    final applications = widget.projectStore.applications
        .where(
          (application) =>
              application.applicantName.toLowerCase() ==
              _profile.name.trim().toLowerCase(),
        )
        .toList()
        .reversed
        .toList();
    if (applications.isEmpty) {
      return const [
        _EmptyDashboardState(
          icon: Icons.mark_email_unread_outlined,
          message: 'Kamu belum mengirim lamaran ke proyek mana pun.',
        ),
      ];
    }

    return applications.map((application) {
      final project = _projects.firstWhere(
        (item) => item.id == application.projectId,
        orElse: () => ProjectListing(
          id: application.projectId,
          title: 'Proyek tidak tersedia',
          leader: '',
          event: '',
          description: '',
          skills: const [],
          teacherName: '',
          statusAcc: 'rejected',
          recruitmentOpen: false,
        ),
      );
      return _StudentApplicationCard(
        project: project,
        application: application,
        onOpenWorkspace: application.status == ProjectApplicationStatus.accepted
            ? () => setState(() {
                _selectedWorkspaceProjectId = application.projectId;
                _navigationIndex = 1;
              })
            : null,
      );
    }).toList();
  }

  Widget _buildStudentWelcome() {
    final firstName = _profile.name.trim().split(RegExp(r'\s+')).first;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102F35),
            ProjectNexusColors.tealDark,
            Color(0xFF176B68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ProjectNexusColors.tealDark.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(height: 15),
                Text(
                  'Halo, $firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan tim yang tepat.',
                  style: const TextStyle(
                    color: Color(0xFFE0F0EC),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
          const SizedBox(width: 14),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Icon(
              Icons.groups_2_rounded,
              color: Color(0xFFB9E2D8),
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherWelcome(int pendingCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ProjectNexusColors.tealDark, Color(0xFF1A5556)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ProjectNexusColors.tealDark.withValues(alpha: 0.13),
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
                const Text(
                  'TINJAUAN PROYEK',
                  style: TextStyle(
                    color: Color(0xFFB9E2D8),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Antrean persetujuan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tinjau ide dan bantu siswa menyempurnakan rencananya.',
                  style: TextStyle(
                    color: Color(0xFFD7E9E5),
                    height: 1.4,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$pendingCount draf menunggu tinjauan',
                  style: const TextStyle(
                    color: Color(0xFFD7E9E5),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            constraints: const BoxConstraints(minWidth: 58, minHeight: 58),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$pendingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'MENUNGGU',
                  style: TextStyle(
                    color: Color(0xFFD7E9E5),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
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
          Expanded(
            child: Text(
              'Rekrutmen terbuka',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: _ink, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
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
    final application = widget.projectStore.applicationFor(
      project.id,
      _profile.name,
    );
    final isLeader =
        project.leader.toLowerCase() == _profile.name.trim().toLowerCase();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(project.title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(project.description),
            const SizedBox(height: 14),
            Text('Ketua: ${project.leader}'),
            Text('Target: ${project.event}'),
            Text(
              '${widget.projectStore.acceptedMembers(project.id).length} anggota termasuk ketua',
            ),
            Text(
              project.recruitmentOpen
                  ? 'Rekrutmen sedang terbuka.'
                  : 'Rekrutmen sedang ditutup.',
            ),
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
        actions: [
          if (isLeader)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _showApplicantManagement(project);
              },
              child: const Text('Kelola pelamar'),
            )
          else if (!_isTeacherView)
            FilledButton(
              key: Key('apply_${project.id}'),
              onPressed: application != null || !project.recruitmentOpen
                  ? null
                  : () {
                      final result = widget.projectStore.apply(
                        projectId: project.id,
                        applicantName: _profile.name,
                        role: widget.role,
                        applicantSkills: _profile.skills,
                        applicantPortfolio: _portfolioItems
                            .where((item) => item.owner == _profile.name)
                            .toList(),
                      );
                      Navigator.pop(context);
                      final message = switch (result) {
                        WorkflowActionResult.success =>
                          'Lamaran telah dikirim kepada ketua proyek.',
                        WorkflowActionResult.cannotApplyToOwnProject =>
                          'Kamu tidak dapat melamar ke proyek sendiri.',
                        WorkflowActionResult.duplicateApplication =>
                          'Kamu sudah pernah melamar ke proyek ini.',
                        WorkflowActionResult.recruitmentClosed =>
                          'Rekrutmen proyek sudah ditutup.',
                        _ => 'Lamaran tidak dapat dikirim untuk proyek ini.',
                      };
                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(SnackBar(content: Text(message)));
                    },
              child: Text(
                application?.status.label ??
                    (project.recruitmentOpen
                        ? 'Ajukan bergabung'
                        : 'Rekrutmen ditutup'),
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

  Future<void> _showApplicantManagement(ProjectListing project) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ApplicantManagementDialog(
        project: project,
        leaderName: _profile.name,
        role: widget.role,
        store: widget.projectStore,
      ),
    );
  }

  Future<void> _openDraftForm() async {
    final submittedProject = await showModalBottomSheet<ProjectListing>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraftProjectSheet(studentName: _profile.name),
    );
    if (submittedProject != null && mounted) {
      final result = widget.projectStore.submit(
        submittedProject,
        submitterName: _profile.name,
        role: widget.role,
      );
      if (result != WorkflowActionResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan proyek tidak dapat disimpan.'),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draf terkirim dan menunggu persetujuan guru.'),
        ),
      );
    }
  }

  Future<void> _reviseProject(ProjectListing project) async {
    final revisedProject = await showModalBottomSheet<ProjectListing>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraftProjectSheet(
        studentName: _profile.name,
        projectToRevise: project,
      ),
    );
    if (revisedProject == null || !mounted) return;
    final result = widget.projectStore.resubmit(
      project,
      title: revisedProject.title,
      description: revisedProject.description,
      studentName: _profile.name,
      role: widget.role,
    );
    if (result != WorkflowActionResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisi proyek tidak dapat dikirim.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Revisi terkirim dan menunggu tinjauan guru.'),
      ),
    );
  }

  void _logout() {
    widget.onLogout();
  }

  void _updateProjectStatus(ProjectListing project, String status) {
    final result = widget.projectStore.review(
      project,
      status: status,
      reviewerName: _currentTeacherName,
      role: widget.role,
    );
    if (result != WorkflowActionResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya guru pendamping proyek yang dapat meninjaunya.'),
        ),
      );
      return;
    }
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

  Future<void> _rejectProject(ProjectListing project) async {
    var noteText = '';
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak pengajuan proyek?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berikan masukan agar siswa tahu hal yang perlu diperbaiki.',
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('rejection_note'),
              minLines: 2,
              maxLines: 4,
              onChanged: (value) => noteText = value,
              decoration: const InputDecoration(
                labelText: 'Masukan untuk siswa (opsional)',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('confirm_project_rejection'),
            onPressed: () => Navigator.pop(context, noteText.trim()),
            child: const Text('Tolak pengajuan'),
          ),
        ],
      ),
    );
    if (note == null || !mounted) return;
    final reviewResult = widget.projectStore.review(
      project,
      status: 'rejected',
      reviewerName: _currentTeacherName,
      role: widget.role,
      note: note.isEmpty ? null : note,
    );
    if (reviewResult != WorkflowActionResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya guru pendamping proyek yang dapat meninjaunya.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan ditolak dan siswa diberi tahu.')),
    );
  }
}

class _StudentSubmissionCard extends StatelessWidget {
  const _StudentSubmissionCard(
    this.project, {
    this.onRevise,
    this.onManageApplicants,
  });

  final ProjectListing project;
  final VoidCallback? onRevise;
  final VoidCallback? onManageApplicants;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (project.statusAcc) {
      'approved' => (
        'Disetujui',
        const Color(0xFF26734D),
        Icons.check_circle_outline_rounded,
      ),
      'rejected' => (
        'Perlu diperbaiki',
        const Color(0xFFAD463D),
        Icons.edit_note_rounded,
      ),
      _ => (
        'Menunggu tinjauan',
        const Color(0xFF9A572C),
        Icons.hourglass_top_rounded,
      ),
    };
    return Card(
      key: Key('student_submission_${project.title}'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: ProjectNexusColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ProjectNexusColors.ink,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF526568), height: 1.45),
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: ProjectNexusColors.border),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 17,
                    color: ProjectNexusColors.muted,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Guru pendamping: ${project.teacherName}',
                      style: const TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (project.reviewNote != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF0DCD2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF9C5A44),
                          size: 16,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'MASUKAN GURU',
                          style: TextStyle(
                            color: Color(0xFF9C5A44),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Masukan guru: ${project.reviewNote}',
                      style: const TextStyle(
                        color: Color(0xFF70483D),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onRevise != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: Key('revise_submission_${project.title}'),
                  onPressed: onRevise,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Perbaiki dan kirim ulang'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ProjectNexusColors.tealDark,
                    side: const BorderSide(color: ProjectNexusColors.teal),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
            if (onManageApplicants != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: Key('manage_applicants_${project.id}'),
                  onPressed: onManageApplicants,
                  icon: const Icon(Icons.groups_2_outlined),
                  label: Text(
                    'Kelola pelamar (${project.recruitmentOpen ? 'rekrutmen terbuka' : 'rekrutmen ditutup'})',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyStudentSubmissionState extends StatelessWidget {
  const _EmptyStudentSubmissionState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: ProjectNexusColors.muted),
          SizedBox(height: 12),
          Text(
            'Belum ada pengajuan proyek.',
            style: TextStyle(color: ProjectNexusColors.muted),
          ),
          SizedBox(height: 4),
          Text(
            'Ajukan ide proyek untuk mulai mendapatkan tinjauan guru.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ProjectNexusColors.muted),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProjectNexusColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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

class _WorkspaceAccessState extends StatelessWidget {
  const _WorkspaceAccessState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 42,
              color: ProjectNexusColors.teal,
            ),
            const SizedBox(height: 12),
            Text(
              'Workspace belum tersedia',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ProjectNexusColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Akses diberikan kepada ketua, anggota yang diterima, dan guru pendamping setelah proyek disetujui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ProjectNexusColors.muted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDashboardState extends StatelessWidget {
  const _EmptyDashboardState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          Icon(icon, size: 38, color: ProjectNexusColors.teal),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ProjectNexusColors.muted),
          ),
        ],
      ),
    );
  }
}

class _StudentApplicationCard extends StatelessWidget {
  const _StudentApplicationCard({
    required this.project,
    required this.application,
    this.onOpenWorkspace,
  });

  final ProjectListing project;
  final ProjectApplication application;
  final VoidCallback? onOpenWorkspace;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (application.status) {
      ProjectApplicationStatus.pending => (
        const Color(0xFF9A572C),
        Icons.hourglass_top_rounded,
      ),
      ProjectApplicationStatus.accepted => (
        const Color(0xFF26734D),
        Icons.check_circle_outline_rounded,
      ),
      ProjectApplicationStatus.rejected => (
        const Color(0xFFAD463D),
        Icons.cancel_outlined,
      ),
    };
    return Card(
      key: Key('student_application_${application.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ProjectNexusColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 7),
                Text(
                  application.status.label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Ketua proyek: ${project.leader}',
              style: const TextStyle(color: ProjectNexusColors.muted),
            ),
            if (onOpenWorkspace != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  key: const Key('open_application_workspace'),
                  onPressed: onOpenWorkspace,
                  icon: const Icon(Icons.view_kanban_outlined),
                  label: const Text('Buka workspace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
