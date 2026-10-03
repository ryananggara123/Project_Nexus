import 'package:flutter/foundation.dart';

import '../data/dashboard_sample_data.dart';
import 'dashboard_models.dart';

class ProjectWorkflowStore extends ChangeNotifier {
  final List<ProjectListing> _projects = [...dashboardProjects];

  List<ProjectListing> get projects => List.unmodifiable(_projects);

  void submit(ProjectListing project) {
    _projects.insert(0, project);
    notifyListeners();
  }

  void review(
    ProjectListing project, {
    required String status,
    String? note,
  }) {
    final index = _projects.indexOf(project);
    if (index == -1) {
      throw StateError('Pengajuan proyek tidak ditemukan.');
    }
    _projects[index] = project.copyWith(statusAcc: status, reviewNote: note);
    notifyListeners();
  }

  void resubmit(
    ProjectListing project, {
    required String title,
    required String description,
  }) {
    final index = _projects.indexOf(project);
    if (index == -1 || project.statusAcc != 'rejected') {
      throw StateError('Pengajuan yang ditolak tidak dapat dikirim ulang.');
    }
    _projects[index] = project.copyWith(
      title: title,
      description: description,
      statusAcc: 'pending',
      clearReviewNote: true,
    );
    notifyListeners();
  }
}
