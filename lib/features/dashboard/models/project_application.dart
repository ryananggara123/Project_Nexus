import 'portfolio_item.dart';

enum ProjectApplicationStatus {
  pending('Menunggu'),
  accepted('Diterima'),
  rejected('Ditolak');

  const ProjectApplicationStatus(this.label);

  final String label;
}

class ProjectApplication {
  const ProjectApplication({
    required this.id,
    required this.projectId,
    required this.applicantName,
    required this.status,
    this.skills = const [],
    this.portfolioItems = const [],
  });

  final String id;
  final String projectId;
  final String applicantName;
  final ProjectApplicationStatus status;
  final List<String> skills;
  final List<PortfolioItem> portfolioItems;

  ProjectApplication copyWith({ProjectApplicationStatus? status}) {
    return ProjectApplication(
      id: id,
      projectId: projectId,
      applicantName: applicantName,
      status: status ?? this.status,
      skills: skills,
      portfolioItems: portfolioItems,
    );
  }
}

enum WorkflowActionResult {
  success,
  projectNotFound,
  duplicateProject,
  projectNotApproved,
  invalidTransition,
  recruitmentClosed,
  cannotApplyToOwnProject,
  duplicateApplication,
  applicationNotFound,
  applicationAlreadyReviewed,
  notProjectLeader,
  notAssignedTeacher,
  notAuthorized,
}
