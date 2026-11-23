import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/app_notification.dart';

/// Menampilkan notifikasi di bilah notifikasi perangkat, dipakai ketika
/// aplikasi sedang tidak dibuka di layar. [instance] dapat diganti versi
/// palsu pada pengujian.
abstract class SystemNotifier {
  /// Bawaan tidak melakukan apa pun (web dan pengujian); `main` memasang
  /// [AndroidSystemNotifier] saat berjalan di Android.
  static SystemNotifier instance = const NoSystemNotifier();

  Future<void> show(AppNotification notification);
}

class NoSystemNotifier implements SystemNotifier {
  const NoSystemNotifier();

  @override
  Future<void> show(AppNotification notification) async {}
}

/// Notifikasi sistem Android melalui flutter_local_notifications.
class AndroidSystemNotifier implements SystemNotifier {
  AndroidSystemNotifier._(this._plugin);

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'project_nexus_updates',
      'Kabar proyek',
      channelDescription:
          'Keputusan guru, pelamar baru, keputusan lamaran, dan tugas baru.',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin;
  int _nextId = 0;

  /// Menyiapkan plugin dan meminta izin notifikasi (wajib sejak Android 13).
  static Future<AndroidSystemNotifier> create() async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return AndroidSystemNotifier._(plugin);
  }

  @override
  Future<void> show(AppNotification notification) => _plugin.show(
    id: _nextId++,
    title: notification.title,
    body: notification.body,
    notificationDetails: _details,
  );
}
