import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/auth/models/student_demo_account.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';
import 'package:project_nexus/features/dashboard/data/dashboard_sample_data.dart';
import 'package:project_nexus/features/dashboard/models/dashboard_models.dart';
import 'package:project_nexus/features/dashboard/models/portfolio_item.dart';
import 'package:project_nexus/features/dashboard/models/project_application.dart';
import 'package:project_nexus/features/dashboard/models/project_workflow_store.dart';
import 'package:project_nexus/features/dashboard/models/team_work_store.dart';
import 'package:project_nexus/features/dashboard/models/workspace_task.dart';

const _project = ProjectListing(
  id: 'test-kebun-pintar',
  title: 'Kebun Sekolah Pintar',
  leader: 'Ryan Anggara Deki',
  event: 'Lomba Inovasi Daerah',
  description: 'Memantau kelembapan tanah kebun sekolah.',
  skills: ['Flutter', 'IoT'],
  teacherName: 'Budi Santoso',
  statusAcc: 'pending',
  recruitmentOpen: false,
  firstStep: 'Catat tanaman yang sering layu.',
);

void main() {
  group('database lokal Hive', () {
    late Directory directory;

    setUp(() {
      directory = Directory.systemTemp.createTempSync('project_nexus_db');
      Hive.init(directory.path);
    });

    tearDown(() async {
      await Hive.close();
      directory.deleteSync(recursive: true);
    });

    test('first launch saves the sample data into the database', () async {
      final database = await LocalDatabase.openHive();
      final store = ProjectWorkflowStore(database: database);
      await store.saved;

      expect(
        database.readList(LocalDatabase.projectsKey),
        hasLength(dashboardProjects.length),
      );
      expect(
        database.readList(LocalDatabase.applicationsKey),
        hasLength(sampleApplications.length),
      );
    });

    test('projects and applications survive reopening the database', () async {
      var store = ProjectWorkflowStore(
        database: await LocalDatabase.openHive(),
      );
      store.submit(
        _project,
        submitterName: 'Ryan Anggara Deki',
        role: UserRole.student,
      );
      store.review(
        _project,
        status: 'approved',
        reviewerName: 'Budi Santoso',
        role: UserRole.teacher,
      );
      store.apply(
        projectId: _project.id,
        applicantName: 'Nadia Putri',
        role: UserRole.student,
        applicantSkills: const ['Riset'],
      );
      await store.saved;
      await Hive.close();

      store = ProjectWorkflowStore(database: await LocalDatabase.openHive());
      final restored = store.projects.firstWhere(
        (project) => project.id == _project.id,
      );
      expect(restored.statusAcc, 'approved');
      expect(restored.recruitmentOpen, isTrue);
      expect(
        store.applicationFor(_project.id, 'Nadia Putri')?.status,
        ProjectApplicationStatus.pending,
      );

      store.apply(
        projectId: _project.id,
        applicantName: 'Rizky Ramadhan',
        role: UserRole.student,
      );
      final ids = store.applications.map((application) => application.id);
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('workspace tasks and portfolio survive reopening the database', () async {
      var store = TeamWorkStore(database: await LocalDatabase.openHive());
      final firstTask = store.tasksFor('sample-water-iot').first;
      store.updateTaskStatus(
        'sample-water-iot',
        firstTask,
        WorkspaceTaskStatus.inProgress,
      );
      store.addTask(
        'sample-water-iot',
        const WorkspaceTask(
          title: 'Kalibrasi sensor pH',
          assignee: 'Ryan Anggara Deki',
          dueLabel: '30 Okt 2026',
          status: WorkspaceTaskStatus.todo,
        ),
      );
      store.addPortfolioItem(
        const PortfolioItem(
          owner: 'Ryan Anggara Deki',
          title: 'Juara 2 Lomba Aplikasi',
          category: 'Prestasi',
          description: 'Aplikasi pemantau air.',
          year: '2026',
          icon: Icons.emoji_events_outlined,
          color: Color(0xFF087E8B),
        ),
      );
      await store.saved;
      await Hive.close();

      store = TeamWorkStore(database: await LocalDatabase.openHive());
      final tasks = store.tasksFor('sample-water-iot');
      expect(tasks.first.status, WorkspaceTaskStatus.inProgress);
      expect(tasks.map((task) => task.title), contains('Kalibrasi sensor pH'));
      final item = store.portfolioItems.first;
      expect(item.title, 'Juara 2 Lomba Aplikasi');
      expect(item.icon, Icons.emoji_events_outlined);
      expect(item.color, const Color(0xFF087E8B));
    });
  });

  test('student accounts are stored with a hashed password', () {
    final account = StudentDemoAccount.register(
      fullName: 'Ryan Anggara Deki',
      nim: '2413025074',
      username: 'ryananggara',
      email: 'ryan@school.id',
      password: 'rahasia123',
    );
    final json = account.toJson();

    expect(json.values, isNot(contains('rahasia123')));
    final restored = StudentDemoAccount.tryFromJson(json)!;
    expect(restored.verifyPassword('rahasia123'), isTrue);
    expect(restored.verifyPassword('salah123'), isFalse);
  });

  test('corrupt stored data falls back to the sample data', () async {
    final memory = MemoryKeyValueStore();
    await memory.write(LocalDatabase.projectsKey, '{bukan json');
    await memory.write(LocalDatabase.applicationsKey, '[{"id": 5}]');
    final database = LocalDatabase(memory);

    final store = ProjectWorkflowStore(database: database);
    await store.saved;

    expect(store.projects, hasLength(dashboardProjects.length));
    expect(store.applications, isEmpty);
    expect(
      database.readList(LocalDatabase.projectsKey),
      hasLength(dashboardProjects.length),
    );
  });
}
