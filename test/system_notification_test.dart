import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';
import 'package:project_nexus/features/dashboard/models/project_workflow_store.dart';
import 'package:project_nexus/features/dashboard/screens/dashboard_screen.dart';
import 'package:project_nexus/features/notifications/data/system_notifier.dart';
import 'package:project_nexus/features/notifications/models/app_notification.dart';
import 'package:project_nexus/features/notifications/models/notification_store.dart';

class _FakeSystemNotifier implements SystemNotifier {
  final shown = <AppNotification>[];

  @override
  Future<void> show(AppNotification notification) async =>
      shown.add(notification);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => SystemNotifier.instance = const NoSystemNotifier());

  testWidgets('background notifications go to the device notification bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final notifier = _FakeSystemNotifier();
    SystemNotifier.instance = notifier;

    final cloud = MemoryCloudStore();
    final mine = NotificationStore()..startSync(cloud, 'Ryan Anggara Deki');
    final teacher = NotificationStore()..startSync(cloud, 'Budi Santoso');
    addTearDown(mine.dispose);
    addTearDown(teacher.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          role: UserRole.student,
          studentName: 'Ryan Anggara Deki',
          onLogout: () {},
          projectStore: ProjectWorkflowStore(),
          notificationStore: mine,
        ),
      ),
    );
    await tester.pumpAndSettle();

    void approve(String title) => teacher.send(
      recipient: 'Ryan Anggara Deki',
      sender: 'Budi Santoso',
      type: NotificationType.projectApproved,
      title: 'Proyek disetujui',
      body: '“$title” disetujui Budi Santoso.',
    );

    // Aplikasi ditutup ke latar belakang: notifikasi masuk ke bilah notifikasi.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    approve('Kebun Sekolah Pintar');
    await tester.pump();
    expect(notifier.shown.single.body, contains('Kebun Sekolah Pintar'));
    expect(find.byType(SnackBar), findsNothing);

    // Aplikasi dibuka lagi: notifikasi berikutnya tampil sebagai pesan singkat.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    approve('Bank Sampah Digital');
    await tester.pumpAndSettle();
    expect(notifier.shown, hasLength(1));
    expect(find.textContaining('Bank Sampah Digital'), findsOneWidget);

    // Keduanya tetap tercatat di lonceng.
    expect(mine.unreadCountFor('Ryan Anggara Deki'), 2);
  });
}
