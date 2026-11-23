import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';
import '../data/dashboard_sample_data.dart';
import 'portfolio_item.dart';
import 'workspace_task.dart';

/// Menyimpan tugas Workspace per proyek dan karya portofolio siswa.
/// Data ini dulu disimpan di layar Beranda sehingga hilang setiap kali
/// pengguna keluar; kini dikelola di sini dan disimpan ke database lokal.
/// Tugas Workspace dan karya portofolio (beserta fotonya) juga disinkronkan
/// ke server agar terlihat sama di semua perangkat.
class TeamWorkStore extends ChangeNotifier with CloudSync {
  TeamWorkStore({this.database}) {
    _restore();
  }

  static const workspacesCollection = 'workspaces';
  static const portfolioItemsCollection = 'portfolio_items';
  static const portfolioPhotosCollection = 'portfolio_photos';

  final LocalDatabase? database;
  final Map<String, List<WorkspaceTask>> _tasks = {};
  final List<PortfolioItem> _portfolioItems = [];
  final Map<String, Uint8List> _images = {};
  final Set<String> _downloading = {};
  Future<void> _lastSave = Future.value();

  /// Selesai ketika penyimpanan terakhir ke database sudah tertulis.
  Future<void> get saved => _lastSave;

  List<PortfolioItem> get portfolioItems => List.unmodifiable(_portfolioItems);

  /// Pasangan (ID proyek, daftar tugas) untuk seluruh proyek yang memiliki tugas.
  Iterable<MapEntry<String, List<WorkspaceTask>>> get taskEntries => _tasks
      .entries
      .map((entry) => MapEntry(entry.key, List.unmodifiable(entry.value)));

  bool hasTasks(String projectId) => _tasks.containsKey(projectId);

  List<WorkspaceTask> tasksFor(String projectId) =>
      List.unmodifiable(_tasks[projectId] ?? const []);

  void addTask(String projectId, WorkspaceTask task) {
    _tasks.putIfAbsent(projectId, () => []).add(task);
    _commit(projectId: projectId);
  }

  void updateTaskStatus(
    String projectId,
    WorkspaceTask task,
    WorkspaceTaskStatus status,
  ) {
    final tasks = _tasks[projectId];
    final index = tasks?.indexOf(task) ?? -1;
    if (tasks == null || index == -1) return;
    tasks[index] = task.copyWith(status: status);
    _commit(projectId: projectId);
  }

  void updateTask(String projectId, WorkspaceTask task, WorkspaceTask updated) {
    final tasks = _tasks[projectId];
    final index = tasks?.indexOf(task) ?? -1;
    if (tasks == null || index == -1) return;
    tasks[index] = updated;
    _commit(projectId: projectId);
  }

  void removeTask(String projectId, WorkspaceTask task) {
    if (_tasks[projectId]?.remove(task) ?? false) {
      _commit(projectId: projectId);
    }
  }

  /// Menambah karya. Bila [image] diisi, foto disimpan di database lokal dan
  /// karya menyimpan ID fotonya.
  void addPortfolioItem(PortfolioItem item, {Uint8List? image}) {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    var saved = item.copyWith(id: item.id ?? 'item-$stamp');
    Future<void>? imageWrite;
    if (image != null) {
      final imageId = 'img-$stamp';
      imageWrite = _storeImage(imageId, image, owner: item.owner);
      saved = saved.copyWith(imageId: imageId);
    }
    _portfolioItems.insert(0, saved);
    _commit(item: saved);
    if (imageWrite != null) _lastSave = Future.wait([_lastSave, imageWrite]);
  }

  /// Mengganti isi karya. [photo] adalah foto setelah diedit: objek yang sama
  /// dengan foto lama berarti tidak berubah, `null` berarti foto dihapus.
  void updatePortfolioItem(
    PortfolioItem item,
    PortfolioItem edited, {
    Uint8List? photo,
  }) {
    final index = _portfolioItems.indexOf(item);
    if (index == -1) return;
    final oldImageId = item.imageId;
    final oldPhoto = oldImageId == null ? null : imageFor(oldImageId);
    String? imageId = oldImageId;
    final writes = <Future<void>>[];
    if (!identical(photo, oldPhoto)) {
      if (oldImageId != null) writes.addAll(_deleteImage(oldImageId));
      imageId = null;
      if (photo != null) {
        imageId = 'img-${DateTime.now().microsecondsSinceEpoch}';
        final write = _storeImage(imageId, photo, owner: item.owner);
        if (write != null) writes.add(write);
      }
    }
    final updated = _portfolioItems[index] = PortfolioItem(
      id: item.id,
      owner: item.owner,
      title: edited.title,
      category: edited.category,
      description: edited.description,
      year: item.year,
      icon: item.icon,
      color: item.color,
      isContribution: item.isContribution,
      imageId: imageId,
    );
    _commit(item: updated);
    if (writes.isNotEmpty) _lastSave = Future.wait([_lastSave, ...writes]);
  }

  /// Menghapus karya beserta fotonya dari database dan server.
  void removePortfolioItem(PortfolioItem item) {
    if (!_portfolioItems.remove(item)) return;
    final imageId = item.imageId;
    final writes = imageId == null ? <Future<void>>[] : _deleteImage(imageId);
    _commit();
    removeRemote(portfolioItemsCollection, item.id!);
    if (writes.isNotEmpty) _lastSave = Future.wait([_lastSave, ...writes]);
  }

  /// Menyimpan foto ke memori dan database lokal, lalu mengirimnya ke server
  /// sebagai base64 pada dokumennya sendiri.
  Future<void>? _storeImage(
    String imageId,
    Uint8List bytes, {
    required String owner,
  }) {
    _images[imageId] = bytes;
    _uploadImage(imageId, bytes, owner);
    return database?.writeBytes(
      LocalDatabase.portfolioImageKey(imageId),
      bytes,
    );
  }

  void _uploadImage(String imageId, Uint8List bytes, String owner) => upload(
    portfolioPhotosCollection,
    imageId,
    {'id': imageId, 'owner': owner, 'data': base64Encode(bytes)},
  );

  List<Future<void>> _deleteImage(String imageId) {
    _images.remove(imageId);
    removeRemote(portfolioPhotosCollection, imageId);
    final delete = database?.delete(LocalDatabase.portfolioImageKey(imageId));
    return [?delete];
  }

  /// Foto karya berdasarkan ID; dibaca dari database sekali lalu disimpan di
  /// memori. Foto karya dari perangkat lain diunduh dari server saat pertama
  /// kali dibutuhkan, lalu tampilan diperbarui.
  Uint8List? imageFor(String imageId) {
    final cached = _images[imageId];
    if (cached != null) return cached;
    final stored = database?.readBytes(
      LocalDatabase.portfolioImageKey(imageId),
    );
    if (stored != null) {
      _images[imageId] = stored;
    } else {
      _downloadImage(imageId);
    }
    return stored;
  }

  void _downloadImage(String imageId) {
    final cloud = this.cloud;
    if (cloud == null || !_downloading.add(imageId)) return;
    cloud
        .get(portfolioPhotosCollection, imageId)
        .then((document) {
          final data = document?['data'];
          if (data is! String) return;
          final bytes = base64Decode(data);
          _images[imageId] = bytes;
          unawaited(
            database?.writeBytes(
              LocalDatabase.portfolioImageKey(imageId),
              bytes,
            ),
          );
          notifyListeners();
        })
        .catchError((Object error) => debugPrint('Foto gagal diunduh: $error'))
        .whenComplete(() => _downloading.remove(imageId));
  }

  /// Karya lama dan data contoh belum memiliki ID; ID dibentuk dari pemilik
  /// dan judulnya agar sama di semua perangkat.
  static PortfolioItem _withId(PortfolioItem item) => item.id == null
      ? item.copyWith(id: PortfolioItem.idFor(item.owner, item.title))
      : item;

  void _restore() {
    final storedTasks = database?.readList(LocalDatabase.workspaceTasksKey);
    final storedItems = database?.readList(LocalDatabase.portfolioItemsKey);
    if (storedTasks == null) {
      sampleWorkspaceTasks.forEach(
        (projectId, tasks) => _tasks[projectId] = [...tasks],
      );
    } else {
      for (final json in storedTasks) {
        final projectId = json['projectId'];
        final task = WorkspaceTask.tryFromJson(json);
        if (projectId is String && task != null) {
          _tasks.putIfAbsent(projectId, () => []).add(task);
        }
      }
    }
    _portfolioItems.addAll(
      (storedItems == null
              ? samplePortfolioItems
              : decodeAll(storedItems, PortfolioItem.tryFromJson))
          .map(_withId),
    );
    if (storedTasks == null || storedItems == null) _persist();
  }

  void _persist() {
    final database = this.database;
    if (database == null) return;
    _lastSave = Future.wait([
      database.writeList(LocalDatabase.workspaceTasksKey, [
        for (final entry in _tasks.entries)
          for (final task in entry.value)
            {'projectId': entry.key, ...task.toJson()},
      ]),
      database.writeList(LocalDatabase.portfolioItemsKey, [
        for (final item in _portfolioItems) item.toJson(),
      ]),
    ]);
  }

  /// [projectId] diisi bila tugas proyek itu berubah agar papan tugasnya
  /// dikirim ke server; [item] diisi bila sebuah karya berubah.
  void _commit({String? projectId, PortfolioItem? item}) {
    notifyListeners();
    _persist();
    if (projectId != null) _uploadWorkspace(projectId);
    if (item != null) {
      upload(portfolioItemsCollection, item.id!, item.toJson());
    }
  }

  /// Satu dokumen per proyek berisi seluruh tugasnya. Bila dua anggota
  /// mengubah papan bersamaan, perubahan terakhir yang dipakai.
  void _uploadWorkspace(String projectId) =>
      upload(workspacesCollection, projectId, {
        'projectId': projectId,
        'tasks': [for (final task in tasksFor(projectId)) task.toJson()],
      });

  /// Mulai sinkronisasi realtime papan tugas dan karya portofolio.
  void startSync(CloudStore cloud) {
    beginSync(cloud);
    listenRemote(portfolioItemsCollection, (documents) {
      if (documents.isEmpty) {
        // Server masih kosong: karya di perangkat ini menjadi data awal.
        for (final item in _portfolioItems) {
          final imageId = item.imageId;
          final photo = imageId == null ? null : imageFor(imageId);
          if (photo != null) _uploadImage(imageId!, photo, item.owner);
          upload(portfolioItemsCollection, item.id!, item.toJson());
        }
        return;
      }
      final remote = [
        ...decodeAll(documents, PortfolioItem.tryFromJson).map(_withId),
      ];
      final merged = mergeById(_portfolioItems, remote, (item) => item.id!);
      _portfolioItems
        ..clear()
        ..addAll(merged);
      notifyListeners();
      _persist();
    });
    listenRemote(workspacesCollection, (documents) {
      if (documents.isEmpty) {
        // Server masih kosong: papan tugas di perangkat ini menjadi data awal.
        _tasks.keys.toList().forEach(_uploadWorkspace);
        return;
      }
      _tasks.clear();
      for (final document in documents) {
        final projectId = document['projectId'];
        final tasks = document['tasks'];
        if (projectId is! String || tasks is! List) continue;
        _tasks[projectId] = [
          for (final task in tasks)
            if (task is Map)
              if (WorkspaceTask.tryFromJson(Map<String, dynamic>.from(task))
                  case final WorkspaceTask parsed)
                parsed,
        ];
      }
      notifyListeners();
      _persist();
    });
  }
}
