import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';
import 'package:project_nexus/features/dashboard/models/dashboard_models.dart';
import 'package:project_nexus/features/dashboard/models/project_workflow_store.dart';
import 'package:project_nexus/features/dashboard/screens/dashboard_screen.dart';
import 'package:project_nexus/features/discussion/models/team_chat_store.dart';
import 'package:project_nexus/features/missions/missions.dart';
import 'package:project_nexus/features/notifications/models/app_notification.dart';
import 'package:project_nexus/features/notifications/models/notification_store.dart';
import 'package:project_nexus/features/talent/models/talent_profile.dart';
import 'package:project_nexus/features/talent/models/talent_store.dart';

const _tari = ProjectListing(
  id: 'project-tari',
  title: 'Tari Kreasi Nusantara',
  leader: 'Ryan Anggara Deki',
  event: 'FLS2N Tari Kreasi',
  description: 'Tari kreasi berkelompok.',
  skills: ['Tari', 'Koreografi'],
  teacherName: 'Siti Rahmawati',
  statusAcc: 'pending',
  recruitmentOpen: false,
);

void main() {
  group('Direktori Bakat', () {
    test('lists other students, best skill match first', () {
      final store = TalentStore();
      final directory = store.directoryFor(
        'Siti Aminah',
        neededSkills: const ['tari', 'Riset'],
      );
      expect(directory.map((t) => t.name), isNot(contains('Siti Aminah')));
      expect(directory.first.name, 'Nadia Putri');
      expect(directory.first.matchingSkills(const ['tari', 'Riset']), [
        'Riset',
        'Tari',
      ]);
    });

    test('a published profile reaches other devices', () async {
      final cloud = MemoryCloudStore();
      final ryan = TalentStore()..startSync(cloud);
      final budi = TalentStore()..startSync(cloud);
      addTearDown(ryan.dispose);
      addTearDown(budi.dispose);
      await pumpEventQueue();
      // Pada mode cloud hanya siswa sungguhan yang tampil.
      expect(budi.profiles, isEmpty);

      ryan.publish(
        const TalentProfile(
          name: 'Ryan Anggara Deki',
          bio: 'Suka fotografi.',
          skills: ['Fotografi'],
        ),
      );
      await pumpEventQueue();
      expect(budi.byName('ryan anggara deki')?.skills, ['Fotografi']);
      expect(
        cloud.documents(TalentStore.collection).single['id'],
        'ryan-anggara-deki',
      );
    });

    test('invites are remembered per project and student', () {
      final store = TalentStore()..markInvited('p1', 'Nadia Putri');
      expect(store.wasInvited('p1', 'nadia putri'), isTrue);
      expect(store.wasInvited('p2', 'Nadia Putri'), isFalse);
      expect(store.invitesSent, 1);
    });
  });

  group('Diskusi tim', () {
    test('messages are shared between team members', () async {
      final cloud = MemoryCloudStore();
      final ryan = TeamChatStore()..startSync(cloud);
      final nadia = TeamChatStore()..startSync(cloud);
      addTearDown(ryan.dispose);
      addTearDown(nadia.dispose);
      ryan.watch('project-tari');
      nadia.watch('project-tari');
      await pumpEventQueue();

      expect(
        ryan.send(projectId: 'project-tari', sender: 'Ryan', text: '  '),
        isFalse,
      );
      ryan.send(
        projectId: 'project-tari',
        sender: 'Ryan Anggara Deki',
        text: ' Latihan Sabtu jam 8 ya. ',
      );
      await pumpEventQueue();
      final received = nadia.messagesFor('project-tari');
      expect(received.single.text, 'Latihan Sabtu jam 8 ya.');
      expect(received.single.sender, 'Ryan Anggara Deki');
      // Pesan proyek lain tidak ikut.
      expect(nadia.messagesFor('sample-water-iot'), isEmpty);
    });
  });

  group('Misi Pemula', () {
    test('XP and level grow with each finished mission', () {
      final fresh = missionsFor(const MissionFacts());
      expect(fresh.xp, 0);
      expect(fresh.level.title, 'Pendatang Baru');
      expect(fresh.nextMission?.id, 'profile');
      expect(fresh.maxXp, 320);

      final active = missionsFor(
        const MissionFacts(
          profileComplete: true,
          hasPhoto: true,
          applied: true,
          submitted: true,
          joinedTeam: true,
        ),
      );
      expect(active.xp, 110);
      expect(active.level.title, 'Penjelajah');
      expect(active.nextLevel?.title, 'Kolaborator');
      expect(active.levelProgress, closeTo(60 / 70, 0.001));
      expect(active.nextMission?.id, 'invite');

      final all = missionsFor(
        const MissionFacts(
          profileComplete: true,
          hasPhoto: true,
          applied: true,
          submitted: true,
          joinedTeam: true,
          invitedSomeone: true,
          finishedTask: true,
          addedWork: true,
          recordedResult: true,
          won: true,
        ),
      );
      expect(all.level.title, 'Legenda Sekolah');
      expect(all.nextLevel, isNull);
      expect(all.levelProgress, 1);
    });
  });

  group('layar', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<(ProjectWorkflowStore, NotificationStore, TalentStore)> openAsRyan(
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      final notifications = NotificationStore();
      final talents = TalentStore();
      final store = ProjectWorkflowStore(notifications: notifications);
      store.submit(
        _tari,
        submitterName: 'Ryan Anggara Deki',
        role: UserRole.student,
      );
      store.review(
        _tari,
        status: 'approved',
        reviewerName: 'Siti Rahmawati',
        role: UserRole.teacher,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(
            role: UserRole.student,
            studentName: 'Ryan Anggara Deki',
            onLogout: () {},
            projectStore: store,
            notificationStore: notifications,
            talentStore: talents,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (store, notifications, talents);
    }

    testWidgets('leader invites a dancer from the talent directory', (
      tester,
    ) async {
      final (_, notifications, talents) = await openAsRyan(tester);
      expect(find.byKey(const Key('mission_card')), findsOneWidget);
      // Profil Ryan ikut tampil di direktori untuk siswa lain.
      expect(talents.byName('Ryan Anggara Deki'), isNotNull);

      await tester.ensureVisible(
        find.byKey(const Key('open_talent_directory')),
      );
      await tester.tap(find.byKey(const Key('open_talent_directory')));
      await tester.pumpAndSettle();
      expect(find.text('Direktori Bakat'), findsOneWidget);

      // Proyek tari terpilih otomatis, penari paling cocok di atas.
      final invite = find.byKey(const Key('invite_nadia-putri'));
      await tester.ensureVisible(invite);
      await tester.tap(invite);
      await tester.pumpAndSettle();

      final received = notifications.notificationsFor('Nadia Putri').single;
      expect(received.type, NotificationType.teamInvite);
      expect(received.body, contains('Tari Kreasi Nusantara'));
      expect(find.text('Sudah diajak'), findsOneWidget);
      // Siswa yang menutup ajakan tidak dapat diajak.
      await tester.ensureVisible(find.byKey(const Key('invite_aulia-rahma')));
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('invite_aulia-rahma')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('team members chat in the workspace', (tester) async {
      await openAsRyan(tester);
      await tester.tap(find.text('Workspace'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('workspace_discussion')));
      await tester.pumpAndSettle();
      expect(find.text('Diskusi tim'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('discussion_input')),
        'Halo tim!',
      );
      await tester.tap(find.byKey(const Key('discussion_send')));
      await tester.pumpAndSettle();
      expect(find.text('Halo tim!'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Ryan: Halo tim!'), findsOneWidget);
    });

    testWidgets('mission sheet sends the student to the right place', (
      tester,
    ) async {
      await openAsRyan(tester);
      await tester.tap(find.byKey(const Key('mission_card')));
      await tester.pumpAndSettle();
      expect(find.text('Misi Pemula'), findsOneWidget);
      // Ryan sudah mengajukan proyek dan memimpin tim.
      expect(find.byKey(const Key('mission_start_submit')), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('mission_start_invite')),
        120,
        scrollable: find.descendant(
          of: find.byType(DraggableScrollableSheet),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.byKey(const Key('mission_start_invite')));
      await tester.pumpAndSettle();
      expect(find.text('Direktori Bakat'), findsOneWidget);
    });
  });
}
