import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';
import 'package:project_nexus/features/dashboard/models/project_application.dart';
import 'package:project_nexus/features/dashboard/models/project_workflow_store.dart';
import 'package:project_nexus/features/dashboard/models/portfolio_item.dart';

void main() {
  late ProjectWorkflowStore store;

  setUp(() {
    store = ProjectWorkflowStore();
  });

  tearDown(() {
    store.dispose();
  });

  test('only an approved open project accepts student applications', () {
    expect(
      store.apply(
        projectId: 'sample-garden',
        applicantName: 'Dewi Anggraini',
        role: UserRole.student,
      ),
      WorkflowActionResult.projectNotApproved,
    );
    expect(
      store.apply(
        projectId: 'missing-project',
        applicantName: 'Dewi Anggraini',
        role: UserRole.student,
      ),
      WorkflowActionResult.projectNotFound,
    );
    expect(
      store.apply(
        projectId: 'sample-water-iot',
        applicantName: 'Nadia Putri',
        role: UserRole.student,
      ),
      WorkflowActionResult.cannotApplyToOwnProject,
    );
    expect(
      store.apply(
        projectId: 'sample-library',
        applicantName: 'Budi Santoso',
        role: UserRole.teacher,
      ),
      WorkflowActionResult.notAuthorized,
    );
  });

  test('application is unique per project and applicant', () {
    const portfolio = PortfolioItem(
      owner: 'Dewi Anggraini',
      title: 'Prototipe aplikasi sekolah',
      category: 'Mobile Development',
      description: 'Prototipe Flutter untuk kegiatan belajar.',
      year: '2026',
      icon: Icons.phone_android,
      color: Colors.teal,
    );
    expect(
      store.apply(
        projectId: 'sample-library',
        applicantName: 'Dewi Anggraini',
        role: UserRole.student,
        applicantSkills: ['Flutter'],
        applicantPortfolio: [portfolio],
      ),
      WorkflowActionResult.success,
    );
    final application = store.applicationFor(
      'sample-library',
      'Dewi Anggraini',
    );
    expect(application?.skills, ['Flutter']);
    expect(
      application?.portfolioItems.single.title,
      'Prototipe aplikasi sekolah',
    );
    expect(
      store.apply(
        projectId: 'sample-library',
        applicantName: ' dewi anggraini ',
        role: UserRole.student,
      ),
      WorkflowActionResult.duplicateApplication,
    );
  });

  test('only project leader can accept an applicant into the team', () {
    store.apply(
      projectId: 'sample-library',
      applicantName: 'Dewi Anggraini',
      role: UserRole.student,
    );

    expect(
      store.reviewApplication(
        projectId: 'sample-library',
        applicantName: 'Dewi Anggraini',
        reviewerName: 'Budi Santoso',
        role: UserRole.student,
        accept: true,
      ),
      WorkflowActionResult.notProjectLeader,
    );
    expect(store.isMember('sample-library', 'Dewi Anggraini'), isFalse);
    expect(
      store.reviewApplication(
        projectId: 'sample-library',
        applicantName: 'Dewi Anggraini',
        reviewerName: 'Siti Aminah',
        role: UserRole.teacher,
        accept: true,
      ),
      WorkflowActionResult.notAuthorized,
    );
    expect(
      store.reviewApplication(
        projectId: 'sample-library',
        applicantName: 'Dewi Anggraini',
        reviewerName: 'Siti Aminah',
        role: UserRole.student,
        accept: true,
      ),
      WorkflowActionResult.success,
    );
    expect(store.isMember('sample-library', 'Dewi Anggraini'), isTrue);
    expect(
      store.reviewApplication(
        projectId: 'sample-library',
        applicantName: 'Dewi Anggraini',
        reviewerName: 'Siti Aminah',
        role: UserRole.student,
        accept: false,
      ),
      WorkflowActionResult.applicationAlreadyReviewed,
    );
  });

  test('team size is not capped and leader can close recruitment', () {
    for (var index = 0; index < 12; index++) {
      final name = 'Siswa $index';
      expect(
        store.apply(
          projectId: 'sample-library',
          applicantName: name,
          role: UserRole.student,
        ),
        WorkflowActionResult.success,
      );
      expect(
        store.reviewApplication(
          projectId: 'sample-library',
          applicantName: name,
          reviewerName: 'Siti Aminah',
          role: UserRole.student,
          accept: true,
        ),
        WorkflowActionResult.success,
      );
    }
    expect(store.acceptedMembers('sample-library'), hasLength(13));

    expect(
      store.setRecruitmentOpen(
        projectId: 'sample-library',
        leaderName: 'Siti Aminah',
        role: UserRole.student,
        isOpen: false,
      ),
      WorkflowActionResult.success,
    );
    expect(
      store.apply(
        projectId: 'sample-library',
        applicantName: 'Pelamar Baru',
        role: UserRole.student,
      ),
      WorkflowActionResult.recruitmentClosed,
    );
    expect(
      store.setRecruitmentOpen(
        projectId: 'sample-library',
        leaderName: 'Dewi Anggraini',
        role: UserRole.student,
        isOpen: true,
      ),
      WorkflowActionResult.notProjectLeader,
    );
  });

  test('rejected applicants do not get workspace membership', () {
    store.apply(
      projectId: 'sample-library',
      applicantName: 'Dewi Anggraini',
      role: UserRole.student,
    );

    expect(
      store.reviewApplication(
        projectId: 'sample-library',
        applicantName: 'Dewi Anggraini',
        reviewerName: 'Siti Aminah',
        role: UserRole.student,
        accept: false,
      ),
      WorkflowActionResult.success,
    );
    expect(
      store.applicationFor('sample-library', 'Dewi Anggraini')?.status,
      ProjectApplicationStatus.rejected,
    );
    expect(store.isMember('sample-library', 'Dewi Anggraini'), isFalse);
    expect(
      store.canAccessWorkspace(
        'sample-library',
        'Dewi Anggraini',
        UserRole.student,
      ),
      isFalse,
    );
  });

  test('workspace access requires project membership or assigned teacher', () {
    expect(
      store.canAccessWorkspace(
        'sample-water-iot',
        'Ryan Anggara Deki',
        UserRole.student,
      ),
      isTrue,
    );
    expect(
      store.canAccessWorkspace(
        'sample-water-iot',
        'Dewi Anggraini',
        UserRole.student,
      ),
      isFalse,
    );
    expect(
      store.canAccessWorkspace(
        'sample-water-iot',
        'Budi Santoso',
        UserRole.teacher,
      ),
      isTrue,
    );
    expect(
      store.canAccessWorkspace(
        'sample-water-iot',
        'Siti Rahmawati',
        UserRole.teacher,
      ),
      isFalse,
    );
    expect(
      store.canAccessWorkspace(
        'sample-garden',
        'Budi Santoso',
        UserRole.teacher,
      ),
      isFalse,
    );
  });

  test('only assigned teachers can review pending projects', () {
    final pendingProject = store.projects.firstWhere(
      (project) => project.id == 'sample-garden',
    );
    expect(
      store.review(
        pendingProject,
        status: 'approved',
        reviewerName: 'Siti Rahmawati',
        role: UserRole.teacher,
      ),
      WorkflowActionResult.notAssignedTeacher,
    );
    expect(
      store.review(
        pendingProject,
        status: 'approved',
        reviewerName: 'Budi Santoso',
        role: UserRole.student,
      ),
      WorkflowActionResult.notAuthorized,
    );
    expect(
      store.review(
        pendingProject,
        status: 'approved',
        reviewerName: 'Budi Santoso',
        role: UserRole.teacher,
      ),
      WorkflowActionResult.success,
    );
    final approvedProject = store.projects.firstWhere(
      (project) => project.id == 'sample-garden',
    );
    expect(
      store.review(
        approvedProject,
        status: 'rejected',
        reviewerName: 'Budi Santoso',
        role: UserRole.teacher,
      ),
      WorkflowActionResult.invalidTransition,
    );
  });
}
