import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';
import 'team_message.dart';

/// Pesan contoh agar ruang diskusi proyek contoh tidak kosong.
final sampleTeamMessages = [
  TeamMessage(
    id: 'sample-msg-1',
    projectId: 'sample-water-iot',
    sender: 'Nadia Putri',
    text: 'Halo tim! Minggu ini kita fokus menentukan titik pengukuran air ya.',
    sentAt: DateTime(2026, 11, 20, 15, 30),
  ),
  TeamMessage(
    id: 'sample-msg-2',
    projectId: 'sample-water-iot',
    sender: 'Rizky Ramadhan',
    text: 'Siap. Aku cek sumur dekat kantin dan kolam belakang sekolah.',
    sentAt: DateTime(2026, 11, 20, 15, 42),
  ),
];

/// Ruang diskusi tim. Pesan setiap proyek diambil dari server hanya ketika
/// ruangnya dibuka, lalu disimpan juga di database lokal.
class TeamChatStore extends ChangeNotifier with CloudSync {
  TeamChatStore({this.database, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    final stored = database?.readList(LocalDatabase.teamMessagesKey);
    _messages.addAll(
      stored == null
          ? sampleTeamMessages
          : decodeAll(stored, TeamMessage.tryFromJson),
    );
  }

  static const collection = 'team_messages';

  /// Jumlah pesan terbaru per proyek yang disimpan di perangkat.
  static const cachedPerProject = 200;

  final LocalDatabase? database;
  final DateTime Function() _clock;
  final List<TeamMessage> _messages = [];
  final Set<String> _watched = {};
  final _random = Random();

  /// Pesan [projectId] dari yang paling lama.
  List<TeamMessage> messagesFor(String projectId) => [
    for (final message in _messages)
      if (message.projectId == projectId) message,
  ]..sort((a, b) => a.sentAt.compareTo(b.sentAt));

  TeamMessage? lastMessage(String projectId) {
    final messages = messagesFor(projectId);
    return messages.isEmpty ? null : messages.last;
  }

  /// Mengirim pesan. Mengembalikan `false` bila pesannya kosong.
  bool send({
    required String projectId,
    required String sender,
    required String text,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final time = _clock();
    final message = TeamMessage(
      id: 'msg-${time.microsecondsSinceEpoch}-${_random.nextInt(1 << 30)}',
      projectId: projectId,
      sender: sender.trim(),
      text: trimmed.length > TeamMessage.maxLength
          ? trimmed.substring(0, TeamMessage.maxLength)
          : trimmed,
      sentAt: time,
    );
    _messages.add(message);
    _changed();
    upload(collection, message.id, message.toJson());
    return true;
  }

  void startSync(CloudStore cloud) {
    beginSync(cloud);
    _watched.clear();
    // Pesan contoh hanya untuk mode lokal; pesan asli datang dari server.
    final before = _messages.length;
    _messages.removeWhere((message) => message.id.startsWith('sample-msg'));
    if (_messages.length != before) _changed();
  }

  /// Mulai mendengarkan pesan [projectId] dari server bila belum.
  void watch(String projectId) {
    if (cloud == null || !_watched.add(projectId)) return;
    listenRemote(collection, field: 'projectId', isEqualTo: projectId, (
      documents,
    ) {
      _messages
        ..removeWhere((message) => message.projectId == projectId)
        ..addAll(decodeAll(documents, TeamMessage.tryFromJson));
      _changed();
    });
  }

  @override
  void stopSync() {
    _watched.clear();
    super.stopSync();
  }

  void _changed() {
    notifyListeners();
    final byProject = <String, List<TeamMessage>>{};
    for (final message in _messages) {
      byProject.putIfAbsent(message.projectId, () => []).add(message);
    }
    unawaited(
      database?.writeList(LocalDatabase.teamMessagesKey, [
        for (final messages in byProject.values)
          for (final message
              in (messages..sort((a, b) => a.sentAt.compareTo(b.sentAt)))
                  .reversed
                  .take(cachedPerProject))
            message.toJson(),
      ]),
    );
  }
}
