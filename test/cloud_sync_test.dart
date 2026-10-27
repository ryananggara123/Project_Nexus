import 'package:flutter_test/flutter_test.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';
import 'package:project_nexus/features/dashboard/data/dashboard_sample_data.dart';
import 'package:project_nexus/features/dashboard/models/dashboard_models.dart';
import 'package:project_nexus/features/dashboard/models/project_application.dart';
import 'package:project_nexus/features/dashboard/models/project_workflow_store.dart';
import 'package:project_nexus/features/dashboard/models/team_work_store.dart';
import 'package:project_nexus/features/dashboard/models/workspace_task.dart';

const _draft = ProjectListing(
  id: 'project-kebun',
  title: 'Kebun Sekolah Pintar',
  leader: 'Ryan Anggara Deki',
  event: 'Proyek Inovasi Sekolah',
  description: 'Penyiraman otomatis berbasis sensor kelembapan.',
  skills: ['Flutter', 'IoT'],
  teacherName: 'Budi Santoso',
  statusAcc: 'pending',
  recruitmentOpen: false,
);

/// Menunggu semua event stream (pengiriman data "jaringan") selesai.
Future<void> _sync() => pumpEventQueue();

void main() {
  group('mergeById', () {
    String id((String, int) item) => item.$1;

    test('keeps local order, replaces, adds, and drops items', () {
      final merged = mergeById(
        [('a', 1), ('b', 1), ('c', 1)],
        [('c', 2), ('a', 2), ('d', 1)],
        id,
      );
      expect(merged, [('d', 1), ('a', 2), ('c', 2)]);
      expect(mergeById([('a', 1)], [('b', 1), ('a', 1)], id, newFirst: false), [
        ('a', 1),
        ('b', 1),
      ]);
    });
  });

  group('ProjectWorkflowStore sync', () {
    late MemoryCloudStore cloud;

    setUp(() => cloud = MemoryCloudStore());

    // Aturan keamanan Workspace mencari lamaran anggota lewat format ID ini.
    test('sample application IDs follow the shared ID format', () {
      for (final application in sampleApplications) {
        expect(
          application.id,
          ProjectWorkflowStore.applicationIdFor(
            application.projectId,
            application.applicantName,
          ),
        );
      }
    });

    test('first device uploads its data to an empty server', () async {
      final device = ProjectWorkflowStore()..startSync(cloud);
      await _sync();

      expect(
        cloud.documents(ProjectWorkflowStore.projectsCollection),
        hasLength(dashboardProjects.length),
      );
      expect(
        cloud.documents(ProjectWorkflowStore.applicationsCollection),
        hasLength(sampleApplications.length),
      );
      device.dispose();
    });

    test('a draft and its review travel between devices', () async {
      final studentDevice = ProjectWorkflowStore()..startSync(cloud);
      await _sync();
      final teacherDatabase = LocalDatabase(MemoryKeyValueStore());
      final teacherDevice = ProjectWorkflowStore(database: teacherDatabase)
        ..startSync(cloud);
      await _sync();

      studentDevice.submit(
        _draft,
        submitterName: 'Ryan Anggara Deki',
        role: UserRole.student,
      );
      await _sync();

      final received = teacherDevice.projects.first;
      expect(received.title, 'Kebun Sekolah Pintar');
      expect(received.statusAcc, 'pending');
      // Data dari server juga tersimpan di database lokal sebagai cache.
      await teacherDevice.saved;
      expect(
        teacherDatabase
            .readList(LocalDatabase.projectsKey)!
            .map((json) => json['id']),
        contains('project-kebun'),
      );

      expect(
        teacherDevice.review(
          received,
          status: 'approved',
          reviewerName: 'Budi Santoso',
          role: UserRole.teacher,
        ),
        WorkflowActionResult.success,
      );
      await _sync();

      final onStudentDevice = studentDevice.projects.firstWhere(
        (project) => project.id == 'project-kebun',
      );
      expect(onStudentDevice.statusAcc, 'approved');
      expect(onStudentDevice.recruitmentOpen, isTrue);

      studentDevice.dispose();
      teacherDevice.dispose();
    });

    test('an application from two devices stays one document', () async {
      final first = ProjectWorkflowStore()..startSync(cloud);
      await _sync();
      final second = ProjectWorkflowStore()..startSync(cloud);
      await _sync();

      for (final device in [first, second]) {
        device.apply(
          projectId: 'sample-library',
          applicantName: 'Dewi Anggraini',
          role: UserRole.student,
        );
      }
      await _sync();

      final applications = cloud
          .documents(ProjectWorkflowStore.applicationsCollection)
          .where((json) => json['applicantName'] == 'Dewi Anggraini');
      expect(applications, hasLength(1));
      expect(
        applications.single['id'],
        ProjectWorkflowStore.applicationIdFor(
          'sample-library',
          'Dewi Anggraini',
        ),
      );

      // Ketua proyek menerima lamaran dari perangkatnya sendiri.
      first.reviewApplication(
        projectId: 'sample-library',
        applicantName: 'Dewi Anggraini',
        reviewerName: 'Siti Aminah',
        role: UserRole.student,
        accept: true,
      );
      await _sync();
      expect(
        second.applicationFor('sample-library', 'Dewi Anggraini')?.status,
        ProjectApplicationStatus.accepted,
      );
      expect(
        second.canAccessWorkspace(
          'sample-library',
          'Dewi Anggraini',
          UserRole.student,
        ),
        isTrue,
      );

      first.dispose();
      second.dispose();
    });

    test('updates stop after the device stops syncing', () async {
      final first = ProjectWorkflowStore()..startSync(cloud);
      await _sync();
      final second = ProjectWorkflowStore()..startSync(cloud);
      await _sync();

      second.stopSync();
      first.submit(
        _draft,
        submitterName: 'Ryan Anggara Deki',
        role: UserRole.student,
      );
      await _sync();
      expect(
        second.projects.map((project) => project.id),
        isNot(contains('project-kebun')),
      );

      second.startSync(cloud);
      await _sync();
      expect(second.projects.first.id, 'project-kebun');

      first.dispose();
      second.dispose();
    });
  });

  group('TeamWorkStore sync', () {
    test('workspace tasks are shared by team members', () async {
      final cloud = MemoryCloudStore();
      final leader = TeamWorkStore()..startSync(cloud);
      await _sync();
      final member = TeamWorkStore()..startSync(cloud);
      await _sync();

      const task = WorkspaceTask(
        title: 'Kalibrasi sensor pH',
        assignee: 'Ryan Anggara Deki',
        dueLabel: 'Jumat',
        status: WorkspaceTaskStatus.todo,
      );
      leader.addTask('sample-water-iot', task);
      await _sync();
      final received = member
          .tasksFor('sample-water-iot')
          .firstWhere((item) => item.title == 'Kalibrasi sensor pH');
      expect(received.assignee, 'Ryan Anggara Deki');

      member.updateTaskStatus(
        'sample-water-iot',
        received,
        WorkspaceTaskStatus.done,
      );
      await _sync();
      expect(
        leader
            .tasksFor('sample-water-iot')
            .firstWhere((item) => item.title == 'Kalibrasi sensor pH')
            .status,
        WorkspaceTaskStatus.done,
      );

      member.removeTask(
        'sample-water-iot',
        member
            .tasksFor('sample-water-iot')
            .firstWhere((item) => item.title == 'Kalibrasi sensor pH'),
      );
      await _sync();
      expect(
        leader.tasksFor('sample-water-iot').map((item) => item.title),
        isNot(contains('Kalibrasi sensor pH')),
      );

      leader.dispose();
      member.dispose();
    });
  });
}
