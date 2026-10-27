import 'package:flutter_test/flutter_test.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/auth/models/user_role.dart';
import 'package:project_nexus/features/dashboard/models/dashboard_models.dart';
import 'package:project_nexus/features/dashboard/models/project_workflow_store.dart';
import 'package:project_nexus/features/notifications/models/app_notification.dart';
import 'package:project_nexus/features/notifications/models/notification_store.dart';

const _ryan = 'Ryan Anggara Deki';
const _budi = 'Budi Santoso';

const _draft = ProjectListing(
  id: 'project-kebun',
  title: 'Kebun Sekolah Pintar',
  leader: _ryan,
  event: 'Proyek Inovasi Sekolah',
  description: 'Penyiraman otomatis berbasis sensor kelembapan.',
  skills: ['Flutter', 'IoT'],
  teacherName: _budi,
  statusAcc: 'pending',
  recruitmentOpen: false,
);

void main() {
  group('notifikasi alur proyek', () {
    late NotificationStore notifications;
    late ProjectWorkflowStore store;

    setUp(() {
      notifications = NotificationStore();
      store = ProjectWorkflowStore(notifications: notifications);
    });

    List<String> titlesFor(String name) => [
      for (final item in notifications.notificationsFor(name)) item.title,
    ];

    test('each workflow step notifies the right person', () {
      store.submit(_draft, submitterName: _ryan, role: UserRole.student);
      expect(titlesFor(_budi), ['Draf proyek baru']);
      expect(
        notifications.notificationsFor(_budi).single.body,
        '$_ryan mengajukan “Kebun Sekolah Pintar” dan menunggu tinjauanmu.',
      );

      store.review(
        store.projects.first,
        status: 'rejected',
        reviewerName: _budi,
        role: UserRole.teacher,
        note: 'Tambahkan jadwal kerja.',
      );
      expect(titlesFor(_ryan), ['Proyek perlu diperbaiki']);
      expect(
        notifications.notificationsFor(_ryan).first.body,
        endsWith('Tambahkan jadwal kerja.'),
      );

      store.resubmit(
        store.projects.first,
        title: 'Kebun Sekolah Pintar v2',
        description: 'Dengan jadwal kerja mingguan.',
        studentName: _ryan,
        role: UserRole.student,
      );
      expect(titlesFor(_budi).first, 'Revisi proyek masuk');

      store.review(
        store.projects.first,
        status: 'approved',
        reviewerName: _budi,
        role: UserRole.teacher,
      );
      expect(titlesFor(_ryan).first, 'Proyek disetujui');

      store.apply(
        projectId: 'project-kebun',
        applicantName: 'Dewi Anggraini',
        role: UserRole.student,
      );
      expect(titlesFor(_ryan).first, 'Pelamar baru');

      store.reviewApplication(
        projectId: 'project-kebun',
        applicantName: 'Dewi Anggraini',
        reviewerName: _ryan,
        role: UserRole.student,
        accept: true,
      );
      expect(titlesFor('Dewi Anggraini'), ['Lamaran diterima']);
      expect(notifications.unreadCountFor(_ryan), 3);
    });

    test('failed actions send no notification', () {
      store.submit(_draft, submitterName: 'Orang Lain', role: UserRole.student);
      store.apply(
        projectId: 'sample-garden',
        applicantName: 'Dewi Anggraini',
        role: UserRole.student,
      );
      expect(notifications.notificationsFor(_budi), isEmpty);
      expect(notifications.notificationsFor('Nadia Putri'), isEmpty);
    });

    test('users are not notified about their own actions', () {
      notifications.send(
        recipient: _ryan,
        sender: ' ryan anggara deki ',
        type: NotificationType.taskAssigned,
        title: 'Tugas baru untukmu',
        body: '-',
      );
      expect(notifications.notificationsFor(_ryan), isEmpty);
    });

    test('notifications can be marked as read', () {
      for (final title in ['Satu', 'Dua', 'Tiga']) {
        notifications.send(
          recipient: _ryan,
          sender: _budi,
          type: NotificationType.projectApproved,
          title: title,
          body: '-',
        );
      }
      expect(notifications.unreadCountFor(_ryan), 3);

      notifications.markRead(notifications.notificationsFor(_ryan).first);
      expect(notifications.unreadCountFor(_ryan), 2);

      notifications.markAllRead(_ryan);
      expect(notifications.unreadCountFor(_ryan), 0);
      expect(notifications.notificationsFor(_ryan), hasLength(3));
    });
  });

  test('notifications remain after the app is reopened', () async {
    final database = LocalDatabase(MemoryKeyValueStore());
    NotificationStore(database: database).send(
      recipient: _ryan,
      sender: _budi,
      type: NotificationType.projectApproved,
      title: 'Proyek disetujui',
      body: '“Kebun Sekolah Pintar” disetujui.',
    );
    await pumpEventQueue();

    final reopened = NotificationStore(database: database);
    expect(reopened.notificationsFor(_ryan).single.title, 'Proyek disetujui');
    expect(reopened.unreadCountFor(_ryan), 1);
  });

  test('notification from another device arrives in realtime', () async {
    final cloud = MemoryCloudStore();
    final studentNotifications = NotificationStore()..startSync(cloud, _ryan);
    final studentDevice = ProjectWorkflowStore(
      notifications: studentNotifications,
    )..startSync(cloud);
    final teacherNotifications = NotificationStore()..startSync(cloud, _budi);
    await pumpEventQueue();

    final arrived = <AppNotification>[];
    teacherNotifications.incoming.listen(arrived.add);

    studentDevice.submit(_draft, submitterName: _ryan, role: UserRole.student);
    await pumpEventQueue();

    expect(arrived.single.title, 'Draf proyek baru');
    expect(teacherNotifications.unreadCountFor(_budi), 1);

    // Status dibaca juga tersimpan di server.
    teacherNotifications.markAllRead(_budi);
    await pumpEventQueue();
    expect(
      cloud.documents(NotificationStore.collection).single['read'],
      isTrue,
    );
    expect(teacherNotifications.unreadCountFor(_budi), 0);

    studentDevice.dispose();
    studentNotifications.dispose();
    teacherNotifications.dispose();
  });

  test('relative time labels are written in Indonesian', () {
    final now = DateTime(2026, 10, 27, 12);
    String label(Duration ago) => relativeTimeLabel(now.subtract(ago), now);

    expect(label(const Duration(seconds: 20)), 'Baru saja');
    expect(label(const Duration(minutes: 5)), '5 menit lalu');
    expect(label(const Duration(hours: 3)), '3 jam lalu');
    expect(label(const Duration(days: 1, hours: 2)), 'Kemarin');
    expect(label(const Duration(days: 4)), '4 hari lalu');
    expect(label(const Duration(days: 30)), '27 Sep 2026');
  });
}
