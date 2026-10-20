import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../../auth/models/user_role.dart';
import '../../auth/widgets/auth_widgets.dart';
import '../data/dashboard_sample_data.dart';
import '../data/recommendation_preferences_store.dart';
import '../models/dashboard_models.dart';
import '../models/project_application.dart';
import '../models/portfolio_item.dart';
import '../models/project_recommender.dart';
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
  static const _preferencesStore = RecommendationPreferencesStore();

  int _navigationIndex = 0;
  int _dashboardTab = 0;
  String? _selectedWorkspaceProjectId;
  String _selectedSkill = 'Semua';
  String _searchQuery = '';
  bool _beginnerOnly = false;
  bool _profileEditedBeforePreferencesLoad = false;
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
          interests: ['Teknologi', 'Desain & UI/UX', 'Lingkungan'],
          weeklyAvailableHours: 3,
        );

  bool get _isTeacherView => widget.role == UserRole.teacher;
  String get _currentTeacherName => widget.teacherName ?? 'Budi Santoso';
  String get _teacherEmail => _currentTeacherName == 'Siti Rahmawati'
      ? 'siti.rahmawati@school.id'
      : 'budi.santoso@school.id';
  List<ProjectListing> get _projects => widget.projectStore.projects;

  List<ProjectRecommendation> get _visibleProjects {
    final filteredProjects = _projects.where((project) {
      final matchesSkill =
          _selectedSkill == 'Semua' || project.skills.contains(_selectedSkill);
      final searchText =
          '${project.title} ${project.leader} ${project.event} ${project.skills.join(' ')}'
              .toLowerCase();
      return project.statusAcc == 'approved' &&
          project.recruitmentOpen &&
          (!_beginnerOnly ||
              project.difficulty == ProjectDifficulty.beginner) &&
          matchesSkill &&
          searchText.contains(_searchQuery.toLowerCase());
    });
    return ProjectRecommender.rank(
      projects: filteredProjects,
      profile: _profile,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.projectStore.addListener(_onProjectStoreChanged);
    if (!_isTeacherView) _restoreRecommendationPreferences();
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 28),
            child: BrandMark(size: 36),
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
                color: ProjectNexusColors.teal,
              ),
              selectedLabelTextStyle: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(
                    color: ProjectNexusColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
              unselectedIconTheme: const IconThemeData(
                color: ProjectNexusColors.muted,
              ),
              unselectedLabelTextStyle: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(
                    color: ProjectNexusColors.muted,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: PersonAvatar(_profile.name),
            title: Text(
              _profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ProjectNexusColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _isTeacherView ? 'Guru pendamping' : 'Siswa',
              style: const TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 12,
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ProjectNexusColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: _navigationIndex,
        onDestinationSelected: (index) {
          setState(() => _navigationIndex = index);
        },
        destinations: _navigationDestinations,
      ),
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
      return MenuPage(
        header: _appHeader,
        children: [
          HeroBanner(
            eyebrow: _isTeacherView ? 'PANEL PEMBIMBING' : 'RUANG KERJA TIM',
            title: 'Workspace',
            description: 'Atur pekerjaan bersama dan wujudkan ide jadi karya.',
            icon: Icons.view_kanban_rounded,
          ),
          const _WorkspaceAccessState(),
        ],
      );
    }
    final tasks = _workspaceTasks.putIfAbsent(project.id, () => []);
    return WorkspaceScreen(
      header: _appHeader,
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
    final completedContributions = [
      for (final entry in _workspaceTasks.entries)
        for (final task in entry.value)
          if (task.status == WorkspaceTaskStatus.done)
            for (final project in _projects)
              if (project.id == entry.key)
                PortfolioItem(
                  owner: task.assignee,
                  title: task.title,
                  category: 'Kontribusi · ${project.title}',
                  description:
                      'Tugas ini diselesaikan sebagai kontribusi pada proyek ${project.title}.',
                  year: DateTime.now().year.toString(),
                  icon: Icons.task_alt_rounded,
                  color: ProjectNexusColors.teal,
                  isContribution: true,
                ),
    ];
    return PortfolioScreen(
      header: _appHeader,
      role: widget.role,
      studentName: _profile.name,
      items: [...completedContributions, ..._portfolioItems],
      onAddItem: (item) => setState(
        () => _portfolioItems.insert(0, item.copyWith(owner: _profile.name)),
      ),
    );
  }

  Widget _buildProfile() {
    return ProfileScreen(
      header: _appHeader,
      profile: _profile,
      onProfileChanged: _onProfileChanged,
    );
  }

  Future<void> _restoreRecommendationPreferences() async {
    final accountId = _preferenceAccountId;
    final preferences = await _preferencesStore.load(accountId);
    if (!mounted ||
        preferences == null ||
        _profileEditedBeforePreferencesLoad) {
      return;
    }
    setState(() {
      _profile = _profile.copyWith(
        skills: preferences.skills,
        interests: preferences.interests,
        weeklyAvailableHours: preferences.weeklyAvailableHours,
      );
    });
  }

  void _onProfileChanged(ProfileData profile) {
    setState(() {
      _profileEditedBeforePreferencesLoad = true;
      _profile = profile;
    });
    if (!_isTeacherView) {
      unawaited(_saveRecommendationPreferences(profile));
    }
  }

  Future<void> _saveRecommendationPreferences(ProfileData profile) async {
    await _preferencesStore.save(_preferenceAccountId, profile);
  }

  String get _preferenceAccountId => widget.studentName ?? 'Ryan Anggara Deki';

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

  Widget get _appHeader =>
      AppHeader(isTeacherView: _isTeacherView, onLogout: _logout);

  Widget _buildDashboard() {
    return MenuPage(
      header: _appHeader,
      bottomPadding: 120,
      children: [
        HeroBanner(
          eyebrow: 'RUANG KOLABORASI SISWA',
          title: 'Halo, $_firstName',
          subtitle: 'Temukan tim yang tepat.',
          description: 'Ide hebat tumbuh bersama keahlian yang beragam.',
          icon: Icons.groups_2_rounded,
        ),
        const SizedBox(height: 16),
        _buildStudentOverview(),
        const SizedBox(height: 20),
        DashboardTabBar(
          selectedIndex: _dashboardTab,
          onChanged: (index) => setState(() => _dashboardTab = index),
        ),
        const SizedBox(height: 20),
        if (_dashboardTab == 0) ..._buildProjectFeed(),
        if (_dashboardTab == 1) ..._buildStudentSubmissions(),
        if (_dashboardTab == 2) ..._buildStudentApplications(),
        if (_dashboardTab == 3) ..._buildAchievementCatalog(),
      ],
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
    return Card(
      child: IntrinsicHeight(
        child: Row(
          children: [
            _OverviewMetric(label: 'Pengajuan', value: myProjects.length),
            const VerticalDivider(indent: 14, endIndent: 14),
            _OverviewMetric(label: 'Ditinjau', value: underReview),
            const VerticalDivider(indent: 14, endIndent: 14),
            _OverviewMetric(label: 'Diterima', value: approved),
          ],
        ),
      ),
    );
  }

  String get _firstName => _profile.name.trim().split(RegExp(r'\s+')).first;

  Widget _buildTeacherQueue() {
    final pendingProjects = _projects
        .where(
          (project) =>
              project.statusAcc == 'pending' &&
              project.teacherName == _currentTeacherName,
        )
        .toList();

    return MenuPage(
      header: _appHeader,
      children: [
        HeroBanner(
          eyebrow: 'TINJAUAN PROYEK',
          title: 'Antrean persetujuan',
          subtitle: '${pendingProjects.length} draf menunggu tinjauan',
          description: 'Tinjau ide dan bantu siswa menyempurnakan rencananya.',
          icon: Icons.fact_check_outlined,
        ),
        const SizedBox(height: 24),
        if (pendingProjects.isEmpty)
          const _EmptyApprovalState()
        else
          ...pendingProjects.map(
            (project) => ApprovalRequestCard(
              project: project,
              onApprove: () => _updateProjectStatus(project, 'approved'),
              onReject: () => _rejectProject(project),
            ),
          ),
      ],
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
      SectionTitle(
        'Pengajuan proyekmu',
        trailing: '${submissions.length} proyek',
        subtitle: 'Pantau status dan masukan guru untuk setiap pengajuan.',
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

  List<Widget> _buildProjectFeed() {
    final recommendations = _visibleProjects;
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
        beginnerOnly: _beginnerOnly,
        onBeginnerOnlyChanged: (value) => setState(() => _beginnerOnly = value),
      ),
      const SizedBox(height: 24),
      SectionTitle(
        'Rekrutmen terbuka',
        trailing: '${recommendations.length} proyek',
        subtitle: 'Diurutkan sesuai keahlian, minat, dan waktu luangmu.',
      ),
      const SizedBox(height: 14),
      if (recommendations.isEmpty)
        const _EmptySearchState()
      else
        ...recommendations.map(
          (recommendation) => ProjectCard(
            project: recommendation.project,
            recommendationReason: recommendation.reason,
            onDetails: () => _showProjectDetails(recommendation.project),
          ),
        ),
    ];
  }

  List<Widget> _buildAchievementCatalog() {
    return [
      const SectionTitle(
        'Karya yang membanggakan',
        subtitle: 'Perjalanan prestasi siswa sekolah.',
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
            Text(
              project.description,
              style: const TextStyle(color: ProjectNexusColors.muted),
            ),
            const SizedBox(height: 16),
            _DetailLine(
              icon: Icons.person_outline_rounded,
              text: 'Ketua: ${project.leader}',
            ),
            _DetailLine(
              icon: Icons.flag_outlined,
              text: 'Target: ${project.event}',
            ),
            _DetailLine(
              icon: Icons.stairs_outlined,
              text: 'Tingkat proyek: ${project.difficulty.label}',
            ),
            _DetailLine(
              icon: Icons.schedule_outlined,
              text:
                  'Komitmen waktu: sekitar ${project.weeklyHours} jam per minggu',
            ),
            _DetailLine(
              icon: Icons.groups_2_outlined,
              text:
                  '${widget.projectStore.acceptedMembers(project.id).length} anggota termasuk ketua',
            ),
            _DetailLine(
              icon: project.recruitmentOpen
                  ? Icons.lock_open_rounded
                  : Icons.lock_outline_rounded,
              text: project.recruitmentOpen
                  ? 'Rekrutmen sedang terbuka.'
                  : 'Rekrutmen sedang ditutup.',
            ),
            if (project.difficulty == ProjectDifficulty.beginner) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ProjectNexusColors.mint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Proyek ini cocok untuk pemula. Kamu tidak harus menguasai semua keahlian sejak awal; tunjukkan minat dan kesiapan untuk belajar.',
                  style: TextStyle(
                    color: ProjectNexusColors.tealDark,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            if (project.firstStep.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Langkah pertama',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                project.firstStep,
                style: const TextStyle(color: ProjectNexusColors.muted),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Keahlian yang dicari',
              style: TextStyle(fontWeight: FontWeight.w700),
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
                      _showMessage(SnackBar(content: Text(message)));
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
        _showMessage(
          const SnackBar(
            content: Text('Pengajuan proyek tidak dapat disimpan.'),
          ),
        );
        return;
      }
      _showMessage(
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
      _showMessage(
        const SnackBar(content: Text('Revisi proyek tidak dapat dikirim.')),
      );
      return;
    }
    _showMessage(
      const SnackBar(
        content: Text('Revisi terkirim dan menunggu tinjauan guru.'),
      ),
    );
  }

  void _logout() {
    // Pesan dari akun ini tidak boleh terbawa ke akun berikutnya.
    ScaffoldMessenger.of(context).clearSnackBars();
    widget.onLogout();
  }

  /// Menampilkan pesan terbaru dan langsung menggantikan pesan sebelumnya,
  /// sehingga hasil aksi tidak tertahan di belakang antrean snackbar.
  void _showMessage(SnackBar message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(message);
  }

  void _updateProjectStatus(ProjectListing project, String status) {
    final result = widget.projectStore.review(
      project,
      status: status,
      reviewerName: _currentTeacherName,
      role: widget.role,
    );
    if (result != WorkflowActionResult.success) {
      _showMessage(
        const SnackBar(
          content: Text('Hanya guru pendamping proyek yang dapat meninjaunya.'),
        ),
      );
      return;
    }
    _showMessage(
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
      _showMessage(
        const SnackBar(
          content: Text('Hanya guru pendamping proyek yang dapat meninjaunya.'),
        ),
      );
      return;
    }
    _showMessage(
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
    final (label, color) = switch (project.statusAcc) {
      'approved' => ('Disetujui', ProjectNexusColors.success),
      'rejected' => ('Perlu diperbaiki', ProjectNexusColors.error),
      _ => ('Menunggu tinjauan', ProjectNexusColors.warning),
    };
    return Card(
      key: Key('student_submission_${project.title}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusPill(label: label, color: color),
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
              style: const TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Guru pendamping: ${project.teacherName}',
              style: const TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 12,
              ),
            ),
            if (project.reviewNote != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ProjectNexusColors.field,
                  borderRadius: BorderRadius.circular(10),
                  border: const Border(
                    left: BorderSide(color: ProjectNexusColors.error, width: 3),
                  ),
                ),
                child: Text(
                  'Masukan guru: ${project.reviewNote}',
                  style: const TextStyle(
                    color: ProjectNexusColors.ink,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            if (onRevise != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: Key('revise_submission_${project.title}'),
                  onPressed: onRevise,
                  child: const Text('Perbaiki dan kirim ulang'),
                ),
              ),
            ],
            if (onManageApplicants != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: Key('manage_applicants_${project.id}'),
                  onPressed: onManageApplicants,
                  child: Text(
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

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: ProjectNexusColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
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
    );
  }
}

class _EmptyStudentSubmissionState extends StatelessWidget {
  const _EmptyStudentSubmissionState();

  @override
  Widget build(BuildContext context) {
    return const _EmptyDashboardState(
      icon: Icons.inbox_outlined,
      message: 'Belum ada pengajuan proyek.\nAjukan ide proyek untuk mendapatkan tinjauan guru.',
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return const _EmptyDashboardState(
      icon: Icons.search_off_rounded,
      message: 'Belum ada proyek yang cocok.',
    );
  }
}

class _EmptyApprovalState extends StatelessWidget {
  const _EmptyApprovalState();

  @override
  Widget build(BuildContext context) {
    return const _EmptyDashboardState(
      icon: Icons.task_alt_rounded,
      message: 'Tidak ada draf yang menunggu persetujuan.',
    );
  }
}

class _WorkspaceAccessState extends StatelessWidget {
  const _WorkspaceAccessState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 32,
              color: ProjectNexusColors.muted,
            ),
            SizedBox(height: 14),
            Text(
              'Workspace belum tersedia',
              style: TextStyle(
                color: ProjectNexusColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Akses diberikan kepada ketua, anggota yang diterima, dan guru pendamping setelah proyek disetujui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 14,
                height: 1.45,
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: ProjectNexusColors.muted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ProjectNexusColors.muted,
              fontSize: 14,
              height: 1.45,
            ),
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
    final color = switch (application.status) {
      ProjectApplicationStatus.pending => ProjectNexusColors.warning,
      ProjectApplicationStatus.accepted => ProjectNexusColors.success,
      ProjectApplicationStatus.rejected => ProjectNexusColors.error,
    };
    return Card(
      key: Key('student_application_${application.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      color: ProjectNexusColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                StatusPill(label: application.status.label, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Ketua proyek: ${project.leader}',
              style: const TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 13,
              ),
            ),
            if (onOpenWorkspace != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('open_application_workspace'),
                  onPressed: onOpenWorkspace,
                  child: const Text('Buka workspace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ProjectNexusColors.muted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
