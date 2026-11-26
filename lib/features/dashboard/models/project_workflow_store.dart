import 'package:flutter/foundation.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';
import '../../auth/models/user_role.dart';
import '../../notifications/models/app_notification.dart';
import '../../notifications/models/notification_store.dart';
import '../data/dashboard_sample_data.dart';
import 'dashboard_models.dart';
import 'portfolio_item.dart';
import 'project_application.dart';

class ProjectWorkflowStore extends ChangeNotifier with CloudSync {
  /// Tanpa [database], data hanya hidup di memori (dipakai pengujian).
  /// Dengan [database], data dimuat saat dibuka dan disimpan setiap berubah.
  /// Bila [notifications] diisi, pihak terkait diberi tahu setiap ada
  /// pengajuan, keputusan guru, lamaran, dan keputusan ketua proyek.
  ProjectWorkflowStore({this.database, this.notifications}) {
    _restore();
  }

  static const projectsCollection = 'projects';
  static const applicationsCollection = 'applications';

  final LocalDatabase? database;
  final NotificationStore? notifications;
  final List<ProjectListing> _projects = [];
  final List<ProjectApplication> _applications = [];
  Future<void> _lastSave = Future.value();

  List<ProjectListing> get projects => List.unmodifiable(_projects);
  List<ProjectApplication> get applications => List.unmodifiable(_applications);

  /// Selesai ketika penyimpanan terakhir ke database sudah tertulis.
  Future<void> get saved => _lastSave;

  void _restore() {
    final storedProjects = database?.readList(LocalDatabase.projectsKey);
    final storedApplications = database?.readList(
      LocalDatabase.applicationsKey,
    );
    _projects.addAll(
      storedProjects == null
          ? dashboardProjects
          : decodeAll(storedProjects, ProjectListing.tryFromJson),
    );
    _applications.addAll(
      storedApplications == null
          ? sampleApplications
          : decodeAll(storedApplications, ProjectApplication.tryFromJson),
    );
    // Pembukaan pertama (atau data rusak): simpan data awal ke database.
    if (storedProjects == null || storedApplications == null) _persist();
  }

  void _persist() {
    final database = this.database;
    if (database == null) return;
    _lastSave = Future.wait([
      database.writeList(LocalDatabase.projectsKey, [
        for (final project in _projects) project.toJson(),
      ]),
      database.writeList(LocalDatabase.applicationsKey, [
        for (final application in _applications) application.toJson(),
      ]),
    ]);
  }

  /// Memberi tahu tampilan, menyimpan perubahan ke database lokal, lalu
  /// mengirim dokumen yang berubah ke server bila sedang tersinkron.
  void _commit({ProjectListing? project, ProjectApplication? application}) {
    notifyListeners();
    _persist();
    if (project != null) {
      upload(projectsCollection, project.id, project.toJson());
    }
    if (application != null) {
      upload(applicationsCollection, application.id, application.toJson());
    }
  }

  /// Mulai sinkronisasi realtime: proyek dan lamaran dari perangkat lain
  /// langsung masuk, dan database lokal ikut diperbarui sebagai cache.
  void startSync(CloudStore cloud) {
    beginSync(cloud);
    listenRemote(projectsCollection, (documents) {
      final remote = decodeAll(documents, ProjectListing.tryFromJson);
      if (remote.isEmpty) {
        // Server masih kosong: data di perangkat ini menjadi data awal.
        for (final project in _projects) {
          upload(projectsCollection, project.id, project.toJson());
        }
        return;
      }
      final merged = mergeById(_projects, remote, (project) => project.id);
      _projects
        ..clear()
        ..addAll(merged);
      notifyListeners();
      _persist();
    });
    listenRemote(applicationsCollection, (documents) {
      final remote = decodeAll(documents, ProjectApplication.tryFromJson);
      if (remote.isEmpty) {
        for (final application in _applications) {
          upload(applicationsCollection, application.id, application.toJson());
        }
        return;
      }
      final merged = mergeById(
        _applications,
        remote,
        (application) => application.id,
        newFirst: false,
      );
      _applications
        ..clear()
        ..addAll(merged);
      notifyListeners();
      _persist();
    });
  }

  WorkflowActionResult submit(
    ProjectListing project, {
    required String submitterName,
    required UserRole role,
  }) {
    if (role != UserRole.student) return WorkflowActionResult.notAuthorized;
    if (project.leader.toLowerCase() != submitterName.trim().toLowerCase()) {
      return WorkflowActionResult.notProjectLeader;
    }
    if (project.statusAcc != 'pending') {
      return WorkflowActionResult.invalidTransition;
    }
    if (_projects.any((item) => item.id == project.id)) {
      return WorkflowActionResult.duplicateProject;
    }
    _projects.insert(0, project);
    _commit(project: project);
    notifications?.send(
      recipient: project.teacherName,
      sender: submitterName,
      type: NotificationType.projectSubmitted,
      title: 'Draf proyek baru',
      body:
          '${project.leader} mengajukan “${project.title}” dan menunggu tinjauanmu.',
      projectId: project.id,
    );
    return WorkflowActionResult.success;
  }

  List<ProjectApplication> applicationsFor(String projectId) =>
      List.unmodifiable(
        _applications.where(
          (application) => application.projectId == projectId,
        ),
      );

  ProjectApplication? applicationFor(String projectId, String applicantName) {
    for (final application in _applications) {
      if (application.projectId == projectId &&
          application.applicantName.toLowerCase() ==
              applicantName.trim().toLowerCase()) {
        return application;
      }
    }
    return null;
  }

  bool isMember(String projectId, String name) {
    final project = _projectById(projectId);
    if (project == null) return false;
    if (project.leader.toLowerCase() == name.trim().toLowerCase()) return true;
    return applicationFor(projectId, name)?.status ==
        ProjectApplicationStatus.accepted;
  }

  bool canAccessWorkspace(String projectId, String name, UserRole role) {
    final project = _projectById(projectId);
    if (project == null || project.statusAcc != 'approved') return false;
    return switch (role) {
      UserRole.student => isMember(projectId, name),
      UserRole.teacher =>
        project.teacherName.toLowerCase() == name.trim().toLowerCase(),
    };
  }

  List<String> acceptedMembers(String projectId) {
    final project = _projectById(projectId);
    if (project == null) return const [];
    return [
      project.leader,
      ...applicationsFor(projectId)
          .where(
            (application) =>
                application.status == ProjectApplicationStatus.accepted,
          )
          .map((application) => application.applicantName),
    ];
  }

  WorkflowActionResult apply({
    required String projectId,
    required String applicantName,
    required UserRole role,
    List<String> applicantSkills = const [],
    List<PortfolioItem> applicantPortfolio = const [],
  }) {
    if (role != UserRole.student) return WorkflowActionResult.notAuthorized;
    final project = _projectById(projectId);
    if (project == null) return WorkflowActionResult.projectNotFound;
    if (project.statusAcc != 'approved') {
      return WorkflowActionResult.projectNotApproved;
    }
    if (!project.recruitmentOpen) {
      return WorkflowActionResult.recruitmentClosed;
    }
    if (project.leader.toLowerCase() == applicantName.trim().toLowerCase()) {
      return WorkflowActionResult.cannotApplyToOwnProject;
    }
    if (applicationFor(projectId, applicantName) != null) {
      return WorkflowActionResult.duplicateApplication;
    }

    final application = ProjectApplication(
      id: applicationIdFor(projectId, applicantName),
      projectId: projectId,
      applicantName: applicantName.trim(),
      status: ProjectApplicationStatus.pending,
      skills: List.unmodifiable(applicantSkills),
      portfolioItems: List.unmodifiable(applicantPortfolio),
    );
    _applications.add(application);
    _commit(application: application);
    notifications?.send(
      recipient: project.leader,
      sender: applicantName,
      type: NotificationType.newApplicant,
      title: 'Pelamar baru',
      body:
          '${application.applicantName} ingin bergabung di “${project.title}”.',
      projectId: projectId,
    );
    return WorkflowActionResult.success;
  }

  /// ID lamaran dibentuk dari proyek dan nama pelamar, sehingga lamaran yang
  /// sama dari dua perangkat tetap menjadi satu dokumen di server.
  static String applicationIdFor(String projectId, String applicantName) {
    final applicant = applicantName.trim().toLowerCase().replaceAll(
      RegExp('[^a-z0-9]+'),
      '-',
    );
    return '${projectId}__$applicant';
  }

  WorkflowActionResult reviewApplication({
    required String projectId,
    required String applicantName,
    required String reviewerName,
    required UserRole role,
    required bool accept,
  }) {
    if (role != UserRole.student) return WorkflowActionResult.notAuthorized;
    final project = _projectById(projectId);
    if (project == null) return WorkflowActionResult.projectNotFound;
    if (project.leader.toLowerCase() != reviewerName.trim().toLowerCase()) {
      return WorkflowActionResult.notProjectLeader;
    }
    final index = _applicationIndex(projectId, applicantName);
    if (index == -1) return WorkflowActionResult.applicationNotFound;
    if (_applications[index].status != ProjectApplicationStatus.pending) {
      return WorkflowActionResult.applicationAlreadyReviewed;
    }

    final application = _applications[index] = _applications[index].copyWith(
      status: accept
          ? ProjectApplicationStatus.accepted
          : ProjectApplicationStatus.rejected,
    );
    _commit(application: application);
    notifications?.send(
      recipient: application.applicantName,
      sender: reviewerName,
      type: accept
          ? NotificationType.applicationAccepted
          : NotificationType.applicationRejected,
      title: accept ? 'Lamaran diterima' : 'Lamaran belum diterima',
      body: accept
          ? 'Kamu diterima di tim “${project.title}”. Workspace tim sudah bisa dibuka.'
          : 'Lamaranmu untuk “${project.title}” belum diterima ketua proyek.',
      projectId: projectId,
    );
    return WorkflowActionResult.success;
  }

  WorkflowActionResult setRecruitmentOpen({
    required String projectId,
    required String leaderName,
    required UserRole role,
    required bool isOpen,
  }) {
    if (role != UserRole.student) return WorkflowActionResult.notAuthorized;
    final index = _projectIndex(projectId);
    if (index == -1) return WorkflowActionResult.projectNotFound;
    final project = _projects[index];
    if (project.leader.toLowerCase() != leaderName.trim().toLowerCase()) {
      return WorkflowActionResult.notProjectLeader;
    }
    if (project.statusAcc != 'approved') {
      return WorkflowActionResult.projectNotApproved;
    }

    final updated = _projects[index] = project.copyWith(
      recruitmentOpen: isOpen,
    );
    _commit(project: updated);
    return WorkflowActionResult.success;
  }

  /// Ketua mencatat hasil lomba proyek yang sudah disetujui. Seluruh
  /// anggota dan guru pendamping diberi tahu.
  WorkflowActionResult recordResult({
    required String projectId,
    required String leaderName,
    required UserRole role,
    required CompetitionResult result,
    String? note,
  }) {
    if (role != UserRole.student) return WorkflowActionResult.notAuthorized;
    final index = _projectIndex(projectId);
    if (index == -1) return WorkflowActionResult.projectNotFound;
    final project = _projects[index];
    if (project.leader.toLowerCase() != leaderName.trim().toLowerCase()) {
      return WorkflowActionResult.notProjectLeader;
    }
    if (project.statusAcc != 'approved') {
      return WorkflowActionResult.projectNotApproved;
    }
    final trimmedNote = note?.trim() ?? '';
    final updated = _projects[index] = project.copyWith(
      result: result,
      resultNote: trimmedNote,
      resultAt: DateTime.now(),
    );
    _commit(project: updated);
    final message = result.isWinner || result == CompetitionResult.honorable
        ? 'Selamat! Tim “${updated.title}” meraih ${result.label}.'
        : 'Tim “${updated.title}” tercatat sebagai ${result.label}. Terima kasih sudah berjuang!';
    for (final recipient in {
      ...acceptedMembers(projectId),
      updated.teacherName,
    }) {
      notifications?.send(
        recipient: recipient,
        sender: leaderName,
        type: NotificationType.resultRecorded,
        title: 'Hasil lomba dicatat',
        body: message,
        projectId: projectId,
      );
    }
    return WorkflowActionResult.success;
  }

  WorkflowActionResult review(
    ProjectListing project, {
    required String status,
    required String reviewerName,
    required UserRole role,
    String? note,
  }) {
    if (role != UserRole.teacher) return WorkflowActionResult.notAuthorized;
    // Dicari lewat ID karena data proyek bisa sudah diperbarui perangkat lain.
    final index = _projectIndex(project.id);
    if (index == -1) return WorkflowActionResult.projectNotFound;
    project = _projects[index];
    if (project.teacherName.toLowerCase() !=
        reviewerName.trim().toLowerCase()) {
      return WorkflowActionResult.notAssignedTeacher;
    }
    if (project.statusAcc != 'pending' ||
        (status != 'approved' && status != 'rejected')) {
      return WorkflowActionResult.invalidTransition;
    }
    final reviewed = _projects[index] = project.copyWith(
      statusAcc: status,
      recruitmentOpen: status == 'approved',
      reviewNote: note,
    );
    _commit(project: reviewed);
    final approved = status == 'approved';
    notifications?.send(
      recipient: reviewed.leader,
      sender: reviewerName,
      type: approved
          ? NotificationType.projectApproved
          : NotificationType.projectRejected,
      title: approved ? 'Proyek disetujui' : 'Proyek perlu diperbaiki',
      body: approved
          ? '“${reviewed.title}” disetujui $reviewerName dan sudah tampil di feed.'
          : note == null
          ? '$reviewerName meminta revisi untuk “${reviewed.title}”.'
          : '$reviewerName meminta revisi untuk “${reviewed.title}”: $note',
      projectId: reviewed.id,
    );
    return WorkflowActionResult.success;
  }

  WorkflowActionResult resubmit(
    ProjectListing project, {
    required String title,
    required String description,
    required String studentName,
    required UserRole role,
  }) {
    if (role != UserRole.student) return WorkflowActionResult.notAuthorized;
    final index = _projectIndex(project.id);
    if (index == -1) return WorkflowActionResult.projectNotFound;
    project = _projects[index];
    if (project.leader.toLowerCase() != studentName.trim().toLowerCase()) {
      return WorkflowActionResult.notProjectLeader;
    }
    if (project.statusAcc != 'rejected') {
      return WorkflowActionResult.invalidTransition;
    }
    final revised = _projects[index] = project.copyWith(
      title: title,
      description: description,
      statusAcc: 'pending',
      recruitmentOpen: false,
      clearReviewNote: true,
    );
    _commit(project: revised);
    notifications?.send(
      recipient: revised.teacherName,
      sender: studentName,
      type: NotificationType.projectSubmitted,
      title: 'Revisi proyek masuk',
      body:
          '${revised.leader} mengirim revisi “${revised.title}” untuk ditinjau ulang.',
      projectId: revised.id,
    );
    return WorkflowActionResult.success;
  }

  int _projectIndex(String projectId) =>
      _projects.indexWhere((project) => project.id == projectId);

  ProjectListing? _projectById(String projectId) {
    final index = _projectIndex(projectId);
    return index == -1 ? null : _projects[index];
  }

  int _applicationIndex(String projectId, String applicantName) =>
      _applications.indexWhere(
        (application) =>
            application.projectId == projectId &&
            application.applicantName.toLowerCase() ==
                applicantName.trim().toLowerCase(),
      );
}
