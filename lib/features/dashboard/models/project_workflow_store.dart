import 'package:flutter/foundation.dart';

import '../../auth/models/user_role.dart';
import '../data/dashboard_sample_data.dart';
import 'dashboard_models.dart';
import 'portfolio_item.dart';
import 'project_application.dart';

class ProjectWorkflowStore extends ChangeNotifier {
  final List<ProjectListing> _projects = [...dashboardProjects];
  final List<ProjectApplication> _applications = [
    const ProjectApplication(
      id: 'sample-water-ryan',
      projectId: 'sample-water-iot',
      applicantName: 'Ryan Anggara Deki',
      status: ProjectApplicationStatus.accepted,
      skills: ['Flutter', 'UI/UX', 'Prototyping', 'Kolaborasi'],
    ),
    const ProjectApplication(
      id: 'sample-water-rizky',
      projectId: 'sample-water-iot',
      applicantName: 'Rizky Ramadhan',
      status: ProjectApplicationStatus.accepted,
      skills: ['Riset', 'Penulis', 'Desain'],
    ),
  ];
  int _nextApplicationId = 0;

  List<ProjectListing> get projects => List.unmodifiable(_projects);
  List<ProjectApplication> get applications => List.unmodifiable(_applications);

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
    notifyListeners();
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

    _nextApplicationId++;
    _applications.add(
      ProjectApplication(
        id: 'application-$_nextApplicationId',
        projectId: projectId,
        applicantName: applicantName.trim(),
        status: ProjectApplicationStatus.pending,
        skills: List.unmodifiable(applicantSkills),
        portfolioItems: List.unmodifiable(applicantPortfolio),
      ),
    );
    notifyListeners();
    return WorkflowActionResult.success;
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

    _applications[index] = _applications[index].copyWith(
      status: accept
          ? ProjectApplicationStatus.accepted
          : ProjectApplicationStatus.rejected,
    );
    notifyListeners();
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

    _projects[index] = project.copyWith(recruitmentOpen: isOpen);
    notifyListeners();
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
    final index = _projects.indexOf(project);
    if (index == -1) return WorkflowActionResult.projectNotFound;
    if (project.teacherName.toLowerCase() !=
        reviewerName.trim().toLowerCase()) {
      return WorkflowActionResult.notAssignedTeacher;
    }
    if (project.statusAcc != 'pending' ||
        (status != 'approved' && status != 'rejected')) {
      return WorkflowActionResult.invalidTransition;
    }
    _projects[index] = project.copyWith(
      statusAcc: status,
      recruitmentOpen: status == 'approved',
      reviewNote: note,
    );
    notifyListeners();
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
    final index = _projects.indexOf(project);
    if (index == -1) return WorkflowActionResult.projectNotFound;
    if (project.leader.toLowerCase() != studentName.trim().toLowerCase()) {
      return WorkflowActionResult.notProjectLeader;
    }
    if (project.statusAcc != 'rejected') {
      return WorkflowActionResult.invalidTransition;
    }
    _projects[index] = project.copyWith(
      title: title,
      description: description,
      statusAcc: 'pending',
      recruitmentOpen: false,
      clearReviewNote: true,
    );
    notifyListeners();
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
