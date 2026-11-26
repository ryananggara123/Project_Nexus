import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/core/theme/project_nexus_colors.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';
import 'package:project_nexus/features/competitions/certificate.dart';
import 'package:project_nexus/features/competitions/models/competition.dart';
import 'package:project_nexus/features/competitions/models/competition_store.dart';
import 'package:project_nexus/features/competitions/screens/competitions_screen.dart';
import 'package:project_nexus/features/dashboard/models/dashboard_models.dart';
import 'package:project_nexus/features/dashboard/models/project_application.dart';
import 'package:project_nexus/features/dashboard/models/project_workflow_store.dart';
import 'package:project_nexus/features/dashboard/screens/dashboard_screen.dart';
import 'package:project_nexus/features/notifications/models/notification_store.dart';

final _lomba = Competition(
  id: 'lomba-baru',
  title: 'Lomba Paduan Suara Pelajar',
  organizer: 'Dinas Pendidikan',
  field: 'Seni & Budaya',
  level: CompetitionLevel.province,
  deadline: DateTime(2027, 4, 1),
  description: 'Paduan suara 20 orang.',
  postedBy: 'Siti Rahmawati',
);

void main() {
  group('CompetitionStore', () {
    test('competitions are sorted by the nearest deadline', () {
      final deadlines = CompetitionStore().competitions.map((c) => c.deadline);
      expect(deadlines.toList(), [...deadlines]..sort());
    });

    test('a competition posted by a teacher reaches students', () async {
      final cloud = MemoryCloudStore();
      final teacher = CompetitionStore()..startSync(cloud);
      final student = CompetitionStore()..startSync(cloud);
      addTearDown(teacher.dispose);
      addTearDown(student.dispose);
      await pumpEventQueue();

      teacher.save(_lomba);
      await pumpEventQueue();
      expect(student.byId('lomba-baru')?.title, 'Lomba Paduan Suara Pelajar');

      teacher.remove(_lomba);
      await pumpEventQueue();
      expect(student.byId('lomba-baru'), isNull);
    });

    test('deadline badge warns as the deadline approaches', () {
      final today = DateTime(2027, 3, 25);
      expect(_lomba.daysLeft(today), 7);
      expect(deadlineBadge(7).color, ProjectNexusColors.warning);
      expect(deadlineBadge(2).color, ProjectNexusColors.error);
      expect(deadlineBadge(20).color, ProjectNexusColors.success);
      expect(deadlineBadge(-1).label, 'Pendaftaran ditutup');
    });
  });

  group('hasil lomba', () {
    late NotificationStore notifications;
    late ProjectWorkflowStore store;

    setUp(() {
      notifications = NotificationStore();
      store = ProjectWorkflowStore(notifications: notifications);
    });

    test('only the leader of an approved project can record a result', () {
      WorkflowActionResult record(String leader, String projectId) =>
          store.recordResult(
            projectId: projectId,
            leaderName: leader,
            role: UserRole.student,
            result: CompetitionResult.champion1,
          );

      expect(
        record('Ryan Anggara Deki', 'sample-water-iot'),
        WorkflowActionResult.notProjectLeader,
      );
      expect(
        record('Nadia Putri', 'sample-garden'),
        WorkflowActionResult.projectNotApproved,
      );
      expect(
        record('Nadia Putri', 'sample-water-iot'),
        WorkflowActionResult.success,
      );
      final project = store.projects.firstWhere(
        (p) => p.id == 'sample-water-iot',
      );
      expect(project.result, CompetitionResult.champion1);
      expect(project.resultAt, isNotNull);
    });

    test('the whole team and the teacher are congratulated', () {
      store.recordResult(
        projectId: 'sample-water-iot',
        leaderName: 'Nadia Putri',
        role: UserRole.student,
        result: CompetitionResult.champion2,
        note: 'Inovasi terbaik.',
      );
      for (final name in [
        'Ryan Anggara Deki',
        'Rizky Ramadhan',
        'Budi Santoso',
      ]) {
        expect(
          notifications.notificationsFor(name).single.body,
          contains('meraih Juara 2'),
        );
      }
      // Ketua tidak diberi tahu atas tindakannya sendiri.
      expect(notifications.notificationsFor('Nadia Putri'), isEmpty);
    });

    test('results survive conversion to JSON', () {
      final project = dashboardProjectsWithResult();
      final restored = ProjectListing.tryFromJson(project.toJson())!;
      expect(restored.result, CompetitionResult.finalist);
      expect(restored.competitionId, 'sample-fls2n-tari');
    });
  });

  test('certificate is a PDF document', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final bytes = await buildCertificate(
      memberName: 'Ryan Anggara Deki',
      project: dashboardProjectsWithResult(),
      eventName: 'FLS2N Tari Kreasi',
    );
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.length, greaterThan(1000));
  });

  group('menu Lomba', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<ProjectWorkflowStore> openAsRyan(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      final store = ProjectWorkflowStore();
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(
            role: UserRole.student,
            studentName: 'Ryan Anggara Deki',
            onLogout: () {},
            projectStore: store,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lomba'));
      await tester.pumpAndSettle();
      return store;
    }

    testWidgets('student starts a team from a competition', (tester) async {
      await openAsRyan(tester);
      expect(find.text('Info Lomba'), findsWidgets);

      await tester.tap(find.byKey(const Key('competition_sample-fls2n-tari')));
      await tester.pumpAndSettle();
      expect(find.text('Detail lomba'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const Key('competition_create_team')),
      );
      await tester.tap(find.byKey(const Key('competition_create_team')));
      await tester.pumpAndSettle();

      // Form pengajuan terbuka dengan nama lomba sudah terisi.
      final event = tester.widget<TextFormField>(
        find.byKey(const Key('draft_project_event')),
      );
      expect(event.controller!.text, 'FLS2N Tari Kreasi');
    });

    testWidgets('hall of fame shows results and certificates', (tester) async {
      final store = await openAsRyan(tester);
      store.recordResult(
        projectId: 'sample-water-iot',
        leaderName: 'Nadia Putri',
        role: UserRole.student,
        result: CompetitionResult.champion1,
      );
      await tester.tap(find.byKey(const Key('competition_tab_fame')));
      await tester.pumpAndSettle();

      expect(find.text('Hall of Fame'), findsWidgets);
      expect(find.text('JUARA 1'), findsOneWidget);
      expect(find.text('Aplikasi Pemantau Kualitas Air IoT'), findsOneWidget);
      // Ryan anggota tim, jadi dapat mengunduh sertifikat.
      expect(
        find.byKey(const Key('certificate_sample-water-iot')),
        findsOneWidget,
      );
      expect(
        store.applicationFor('sample-water-iot', 'Ryan Anggara Deki')?.status,
        ProjectApplicationStatus.accepted,
      );
    });
  });
}

ProjectListing dashboardProjectsWithResult() => const ProjectListing(
  id: 'project-tari',
  title: 'Tari Kreasi Nusantara',
  leader: 'Ryan Anggara Deki',
  event: 'FLS2N Tari Kreasi',
  description: 'Tari kreasi berkelompok.',
  skills: ['Tari'],
  teacherName: 'Siti Rahmawati',
  statusAcc: 'approved',
  recruitmentOpen: false,
  competitionId: 'sample-fls2n-tari',
  result: CompetitionResult.finalist,
  resultNote: 'Lima besar kota.',
);
