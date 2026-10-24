import 'dart:convert';
import 'dart:typed_data';

import 'package:hive_ce/hive_ce.dart';

/// Penyimpanan kunci–nilai yang menjadi dasar [LocalDatabase].
abstract interface class KeyValueStore {
  String? read(String key);

  Future<void> write(String key, String value);
}

/// Penyimpanan permanen berbasis Hive: IndexedDB di browser, berkas di Android.
class HiveKeyValueStore implements KeyValueStore {
  HiveKeyValueStore(this._box);

  final Box<String> _box;

  @override
  String? read(String key) => _box.get(key);

  @override
  Future<void> write(String key, String value) => _box.put(key, value);
}

/// Penyimpanan di memori, dipakai pada pengujian.
class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  String? read(String key) => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;
}

/// Database lokal ProjectNexus. Setiap koleksi disimpan sebagai daftar JSON
/// pada satu kunci sehingga data tetap ada setelah aplikasi ditutup.
class LocalDatabase {
  LocalDatabase(this._store);

  static const boxName = 'project_nexus';
  static const projectsKey = 'projects';
  static const applicationsKey = 'applications';
  static const workspaceTasksKey = 'workspace_tasks';
  static const portfolioItemsKey = 'portfolio_items';
  static const studentAccountsKey = 'student_accounts';

  /// Setiap foto karya disimpan pada kuncinya sendiri agar daftar karya tetap ringan.
  static String portfolioImageKey(String imageId) => 'portfolio_image:$imageId';

  final KeyValueStore _store;

  /// Membuka database Hive. `Hive.initFlutter()` (aplikasi) atau `Hive.init()`
  /// (pengujian) harus dipanggil terlebih dahulu.
  static Future<LocalDatabase> openHive({String? path}) async {
    final box = await Hive.openBox<String>(boxName, path: path);
    return LocalDatabase(HiveKeyValueStore(box));
  }

  /// Membaca satu koleksi. Mengembalikan `null` bila koleksi belum pernah
  /// disimpan atau isinya rusak, sehingga pemanggil dapat memakai data awal.
  List<Map<String, dynamic>>? readList(String key) {
    final raw = _store.read(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return [
        for (final item in decoded)
          if (item is Map) Map<String, dynamic>.from(item),
      ];
    } on FormatException {
      return null;
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> items) =>
      _store.write(key, jsonEncode(items));

  /// Membaca data biner (misalnya foto); `null` bila belum ada atau rusak.
  Uint8List? readBytes(String key) {
    final raw = _store.read(key);
    if (raw == null) return null;
    try {
      return base64Decode(raw);
    } on FormatException {
      return null;
    }
  }

  Future<void> writeBytes(String key, Uint8List bytes) =>
      _store.write(key, base64Encode(bytes));
}

/// Mengubah koleksi JSON menjadi objek; entri yang tidak valid dilewati.
List<T> decodeAll<T>(
  List<Map<String, dynamic>> items,
  T? Function(Map<String, dynamic> json) tryFromJson,
) => [
  for (final item in items)
    if (tryFromJson(item) case final T value) value,
];
