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

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'applicantName': applicantName,
    'status': status.name,
    'skills': skills,
    'portfolioItems': [for (final item in portfolioItems) item.toJson()],
  };

  /// Membaca lamaran dari database; `null` bila datanya tidak lengkap atau rusak.
  static ProjectApplication? tryFromJson(Map<String, dynamic> json) {
    try {
      return ProjectApplication(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        applicantName: json['applicantName'] as String,
        status: ProjectApplicationStatus.values.byName(
          json['status'] as String,
        ),
        skills: List<String>.unmodifiable(json['skills'] as List),
        portfolioItems: List.unmodifiable([
          for (final item in json['portfolioItems'] as List)
            if (item is Map)
              if (PortfolioItem.tryFromJson(Map<String, dynamic>.from(item))
                  case final PortfolioItem parsed)
                parsed,
        ]),
      );
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
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
