import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Penyimpanan dokumen di server (Cloud Firestore). Dibuat sebagai antarmuka
/// agar penyimpanan aplikasi tidak bergantung langsung pada Firebase dan dapat
/// diuji dengan [MemoryCloudStore].
abstract interface class CloudStore {
  /// Mengalirkan seluruh dokumen [collection] setiap kali ada perubahan dari
  /// perangkat mana pun. Bila [field] diisi, hanya dokumen dengan
  /// `field == isEqualTo` yang dikirim.
  Stream<List<Map<String, dynamic>>> watch(
    String collection, {
    String? field,
    Object? isEqualTo,
  });

  Future<Map<String, dynamic>?> get(String collection, String id);

  Future<void> set(String collection, String id, Map<String, dynamic> data);

  Future<void> delete(String collection, String id);
}

/// Server tiruan di memori untuk pengujian. Beberapa penyimpanan yang memakai
/// objek yang sama berperilaku seperti beberapa perangkat yang terhubung ke
/// satu server.
class MemoryCloudStore implements CloudStore {
  final Map<String, Map<String, Map<String, dynamic>>> _collections = {};
  final StreamController<String> _changes = StreamController.broadcast();

  Map<String, Map<String, dynamic>> _documents(String collection) =>
      _collections.putIfAbsent(collection, () => {});

  /// Isi koleksi saat ini, untuk pemeriksaan pada pengujian.
  List<Map<String, dynamic>> documents(String collection) => [
    for (final document in _documents(collection).values) _copy(document),
  ];

  @override
  Stream<List<Map<String, dynamic>>> watch(
    String collection, {
    String? field,
    Object? isEqualTo,
  }) {
    List<Map<String, dynamic>> matching() => [
      for (final document in _documents(collection).values)
        if (field == null || document[field] == isEqualTo) _copy(document),
    ];

    late final StreamController<List<Map<String, dynamic>>> controller;
    StreamSubscription<String>? subscription;
    controller = StreamController(
      onListen: () {
        controller.add(matching());
        subscription = _changes.stream
            .where((changed) => changed == collection)
            .listen((_) => controller.add(matching()));
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final document = _documents(collection)[id];
    return document == null ? null : _copy(document);
  }

  @override
  Future<void> set(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    _documents(collection)[id] = _copy(data);
    _changes.add(collection);
  }

  @override
  Future<void> delete(String collection, String id) async {
    if (_documents(collection).remove(id) != null) _changes.add(collection);
  }

  /// Salinan lewat JSON, meniru data yang dikirim lewat jaringan.
  static Map<String, dynamic> _copy(Map<String, dynamic> data) =>
      Map<String, dynamic>.from(jsonDecode(jsonEncode(data)) as Map);
}

/// Sinkronisasi realtime untuk penyimpanan data aplikasi. Data tetap disimpan
/// di database lokal sebagai cache, sedangkan server menjadi sumber kebenaran
/// yang dibagikan ke semua perangkat.
mixin CloudSync on ChangeNotifier {
  CloudStore? _cloud;
  final List<StreamSubscription<void>> _subscriptions = [];

  /// Server yang sedang tersinkron; `null` bila aplikasi berjalan lokal saja.
  CloudStore? get cloud => _cloud;

  /// Menghentikan sinkronisasi sebelumnya lalu mulai memakai [cloud].
  @protected
  void beginSync(CloudStore cloud) {
    stopSync();
    _cloud = cloud;
  }

  @protected
  void listenRemote(
    String collection,
    void Function(List<Map<String, dynamic>> documents) onData, {
    String? field,
    Object? isEqualTo,
  }) {
    final cloud = _cloud;
    if (cloud == null) return;
    _subscriptions.add(
      cloud
          .watch(collection, field: field, isEqualTo: isEqualTo)
          .listen(onData, onError: _reportError),
    );
  }

  /// Mengirim satu dokumen ke server tanpa menunggu. Saat offline, Firestore
  /// mengantrekan penulisan dan mengirimnya ketika koneksi kembali.
  @protected
  void upload(String collection, String id, Map<String, dynamic> data) =>
      unawaited(_cloud?.set(collection, id, data).catchError(_reportError));

  /// Menghapus satu dokumen di server tanpa menunggu.
  @protected
  void removeRemote(String collection, String id) =>
      unawaited(_cloud?.delete(collection, id).catchError(_reportError));

  void stopSync() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _cloud = null;
  }

  @override
  void dispose() {
    stopSync();
    super.dispose();
  }

  static void _reportError(Object error) =>
      debugPrint('Sinkronisasi cloud gagal: $error');
}

/// Menggabungkan data server ke daftar lokal tanpa mengacak urutan: item yang
/// sudah ada diganti versi server, item baru dari perangkat lain ditaruh di
/// awal ([newFirst]) atau di akhir, dan item yang tidak ada di server dibuang.
List<T> mergeById<T>(
  List<T> current,
  List<T> remote,
  String Function(T item) idOf, {
  bool newFirst = true,
}) {
  final remoteById = {for (final item in remote) idOf(item): item};
  final knownIds = {for (final item in current) idOf(item)};
  final added = [
    for (final item in remote)
      if (!knownIds.contains(idOf(item))) item,
  ];
  final kept = [
    for (final item in current)
      if (remoteById[idOf(item)] case final T updated) updated,
  ];
  return newFirst ? [...added, ...kept] : [...kept, ...added];
}
