import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/auth/data/cloud_account_service.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';
import 'package:project_nexus/features/auth/screens/auth_gate.dart';
import 'package:project_nexus/features/dashboard/models/project_workflow_store.dart';
import 'package:project_nexus/features/notifications/models/app_notification.dart';
import 'package:project_nexus/features/notifications/models/notification_store.dart';
import 'package:project_nexus/main.dart';

import 'support/memory_auth_backend.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('bell shows unread count and opens the notification center', (
    tester,
  ) async {
    _useTallPhone(tester);
    final database = LocalDatabase(MemoryKeyValueStore());
    final seed = NotificationStore(database: database);
    for (final (recipient, title) in [
      ('Ryan Anggara Deki', 'Proyek disetujui'),
      ('Ryan Anggara Deki', 'Pelamar baru'),
      ('Budi Santoso', 'Draf proyek baru'),
    ]) {
      seed.send(
        recipient: recipient,
        sender: 'Pengirim',
        type: NotificationType.projectApproved,
        title: title,
        body: 'Isi notifikasi $title.',
      );
    }

    await tester.pumpWidget(ProjectNexusApp(database: database));
    await tester.pump(AuthGate.splashDuration);
    await tester.pumpAndSettle();
    await _signIn(tester, 'test@school.id');

    final bell = find.byKey(const Key('notification_bell'));
    expect(find.descendant(of: bell, matching: find.text('2')), findsOneWidget);

    await tester.tap(bell);
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('2 belum dibaca'), findsOneWidget);
    expect(find.text('Proyek disetujui'), findsOneWidget);
    expect(find.text('Pelamar baru'), findsOneWidget);
    // Notifikasi milik pengguna lain tidak ikut tampil.
    expect(find.text('Draf proyek baru'), findsNothing);

    await tester.tap(find.text('Proyek disetujui'));
    await tester.pumpAndSettle();
    expect(find.text('1 belum dibaca'), findsOneWidget);

    await tester.tap(find.byKey(const Key('notification_mark_all')));
    await tester.pumpAndSettle();
    expect(find.text('Semua notifikasi sudah dibaca'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    final badge = tester.widget<Badge>(
      find.byKey(const Key('notification_badge')),
    );
    expect(badge.isLabelVisible, isFalse);
  });

  testWidgets('cloud mode: register, sign in, and receive a realtime update', (
    tester,
  ) async {
    _useTallPhone(tester);
    final cloud = MemoryCloudStore();
    final auth = MemoryAuthBackend();
    await tester.pumpWidget(
      ProjectNexusApp(
        cloud: cloud,
        accounts: CloudAccountService(auth: auth, cloud: cloud),
      ),
    );
    await tester.pump(AuthGate.splashDuration);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_registration')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Akun tersimpan di Firebase dan dapat dipakai di perangkat lain.',
      ),
      findsOneWidget,
    );
    for (final (key, value) in [
      ('registration_name', 'Nadia Putri'),
      ('registration_nim', '2413025001'),
      ('registration_username', 'nadiaputri'),
      ('registration_email', 'nadia@school.id'),
      ('registration_password', 'password123'),
      ('registration_confirm_password', 'password123'),
    ]) {
      await tester.ensureVisible(find.byKey(Key(key)));
      await tester.enterText(find.byKey(Key(key)), value);
    }
    await tester.ensureVisible(find.byKey(const Key('registration_submit')));
    await tester.tap(find.byKey(const Key('registration_submit')));
    await tester.pumpAndSettle();
    expect(
      find.text('Akun berhasil dibuat. Masuk menggunakan NIM atau username.'),
      findsOneWidget,
    );
    expect(cloud.documents(CloudAccountService.usersCollection), hasLength(1));

    await _signIn(tester, 'nadiaputri');
    expect(find.text('Halo, Nadia'), findsOneWidget);
    // Perangkat pertama mengisi server yang masih kosong.
    expect(
      cloud.documents(ProjectWorkflowStore.projectsCollection),
      isNotEmpty,
    );

    // Guru meninjau draf Nadia dari perangkat lain.
    final teacherNotifications = NotificationStore()
      ..startSync(cloud, 'Budi Santoso');
    final teacherDevice = ProjectWorkflowStore(
      notifications: teacherNotifications,
    )..startSync(cloud);
    await tester.pump();
    teacherDevice.review(
      teacherDevice.projects.firstWhere(
        (project) => project.id == 'sample-garden',
      ),
      status: 'approved',
      reviewerName: 'Budi Santoso',
      role: UserRole.teacher,
    );
    // Pesan registrasi sebelumnya ditutup dulu sebelum notifikasi tampil.
    await tester.pumpAndSettle();

    expect(find.textContaining('Proyek disetujui ·'), findsOneWidget);
    final bell = find.byKey(const Key('notification_bell'));
    expect(find.descendant(of: bell, matching: find.text('1')), findsOneWidget);

    await tester.tap(find.text('Pengajuan saya'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(
          const Key('student_submission_Draf Sistem Kebun Sekolah'),
        ),
        matching: find.text('Disetujui'),
      ),
      findsOneWidget,
    );

    teacherDevice.dispose();
    teacherNotifications.dispose();
  });
}

void _useTallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

Future<void> _signIn(WidgetTester tester, String identifier) async {
  await tester.enterText(find.byKey(const Key('login_email')), identifier);
  await tester.enterText(
    find.byKey(const Key('login_password')),
    'password123',
  );
  await tester.ensureVisible(find.byKey(const Key('login_submit')));
  await tester.tap(find.byKey(const Key('login_submit')));
  await tester.pumpAndSettle();
}
