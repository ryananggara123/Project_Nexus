import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';
import 'app_notification.dart';

/// Pusat notifikasi. Notifikasi disimpan di database lokal; bila tersambung ke
/// server, notifikasi untuk pengguna yang masuk diterima secara realtime dari
/// perangkat lain.
class NotificationStore extends ChangeNotifier with CloudSync {
  NotificationStore({this.database, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _items.addAll(
      decodeAll(
        database?.readList(LocalDatabase.notificationsKey) ?? const [],
        AppNotification.tryFromJson,
      ),
    );
  }

  static const collection = 'notifications';

  /// Batas notifikasi yang disimpan di perangkat agar cache tetap ringan.
  static const maxStored = 200;

  final LocalDatabase? database;
  final DateTime Function() _clock;
  final List<AppNotification> _items = [];
  final StreamController<AppNotification> _incoming =
      StreamController.broadcast();
  final Random _random = Random();

  /// Notifikasi baru dari perangkat lain yang tiba saat aplikasi terbuka.
  Stream<AppNotification> get incoming => _incoming.stream;

  DateTime get now => _clock();

  /// Notifikasi untuk [recipient], terbaru di atas. Notifikasi dengan waktu
  /// yang sama diurutkan dari yang terakhir dicatat.
  List<AppNotification> notificationsFor(String recipient) {
    final matching = [
      for (final item in _items)
        if (_sameName(item.recipient, recipient)) item,
    ];
    final position = {for (final (i, item) in matching.indexed) item.id: i};
    return matching..sort((a, b) {
      final byTime = b.createdAt.compareTo(a.createdAt);
      return byTime != 0 ? byTime : position[b.id]!.compareTo(position[a.id]!);
    });
  }

  int unreadCountFor(String recipient) => _items
      .where((item) => !item.read && _sameName(item.recipient, recipient))
      .length;

  /// Mendengarkan notifikasi untuk [recipient] di server.
  void startSync(CloudStore cloud, String recipient) {
    beginSync(cloud);
    var firstSnapshot = true;
    listenRemote(
      collection,
      (documents) {
        _receive(
          recipient,
          decodeAll(documents, AppNotification.tryFromJson),
          announce: !firstSnapshot,
        );
        firstSnapshot = false;
      },
      field: 'recipient',
      isEqualTo: recipient,
    );
  }

  void _receive(
    String recipient,
    List<AppNotification> remote, {
    required bool announce,
  }) {
    final knownIds = {for (final item in _items) item.id};
    _items
      ..removeWhere((item) => _sameName(item.recipient, recipient))
      ..addAll(remote);
    _changed();
    // Notifikasi yang sudah ada saat aplikasi dibuka cukup tampil di lencana;
    // yang tiba setelahnya juga diumumkan.
    if (!announce) return;
    for (final item in remote) {
      if (!item.read && !knownIds.contains(item.id)) _incoming.add(item);
    }
  }

  /// Mengirim notifikasi. Pengguna tidak diberi tahu atas tindakannya sendiri.
  void send({
    required String recipient,
    required String sender,
    required NotificationType type,
    required String title,
    required String body,
    String? projectId,
  }) {
    if (_sameName(recipient, sender)) return;
    final time = now;
    final notification = AppNotification(
      id: 'notif-${time.microsecondsSinceEpoch}-${_random.nextInt(1 << 30)}',
      recipient: recipient.trim(),
      sender: sender.trim(),
      type: type,
      title: title,
      body: body,
      createdAt: time,
      projectId: projectId,
    );
    _items.add(notification);
    _changed();
    upload(collection, notification.id, notification.toJson());
  }

  void markRead(AppNotification notification) {
    final index = _items.indexWhere((item) => item.id == notification.id);
    if (index == -1 || _items[index].read) return;
    _items[index] = _items[index].markedRead();
    _changed();
    upload(collection, notification.id, _items[index].toJson());
  }

  void markAllRead(String recipient) {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.read || !_sameName(item.recipient, recipient)) continue;
      _items[i] = item.markedRead();
      upload(collection, item.id, _items[i].toJson());
      changed = true;
    }
    if (changed) _changed();
  }

  void _changed() {
    notifyListeners();
    final database = this.database;
    if (database == null) return;
    final newest = [..._items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    unawaited(
      database.writeList(LocalDatabase.notificationsKey, [
        for (final item in newest.take(maxStored)) item.toJson(),
      ]),
    );
  }

  @override
  void dispose() {
    unawaited(_incoming.close());
    super.dispose();
  }

  static bool _sameName(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}
