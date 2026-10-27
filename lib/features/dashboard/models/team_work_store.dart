import 'package:flutter/foundation.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';
import '../data/dashboard_sample_data.dart';
import 'portfolio_item.dart';
import 'workspace_task.dart';

/// Menyimpan tugas Workspace per proyek dan karya portofolio siswa.
/// Data ini dulu disimpan di layar Beranda sehingga hilang setiap kali
/// pengguna keluar; kini dikelola di sini dan disimpan ke database lokal.
/// Tugas Workspace juga disinkronkan ke server agar seluruh anggota tim
/// melihat papan tugas yang sama; portofolio (berisi foto) tetap lokal.
class TeamWorkStore extends ChangeNotifier with CloudSync {
  TeamWorkStore({this.database}) {
    _restore();
  }

  static const workspacesCollection = 'workspaces';

  final LocalDatabase? database;
  final Map<String, List<WorkspaceTask>> _tasks = {};
  final List<PortfolioItem> _portfolioItems = [];
  final Map<String, Uint8List> _images = {};
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
    var saved = item;
    Future<void>? imageWrite;
    if (image != null) {
      final imageId = 'img-${DateTime.now().microsecondsSinceEpoch}';
      _images[imageId] = image;
      saved = item.copyWith(imageId: imageId);
      imageWrite = database?.writeBytes(
        LocalDatabase.portfolioImageKey(imageId),
        image,
      );
    }
    _portfolioItems.insert(0, saved);
    _commit();
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
        _images[imageId] = photo;
        final write = database?.writeBytes(
          LocalDatabase.portfolioImageKey(imageId),
          photo,
        );
        if (write != null) writes.add(write);
      }
    }
    _portfolioItems[index] = PortfolioItem(
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
    _commit();
    if (writes.isNotEmpty) _lastSave = Future.wait([_lastSave, ...writes]);
  }

  /// Menghapus karya beserta fotonya dari database.
  void removePortfolioItem(PortfolioItem item) {
    if (!_portfolioItems.remove(item)) return;
    final imageId = item.imageId;
    final writes = imageId == null ? <Future<void>>[] : _deleteImage(imageId);
    _commit();
    if (writes.isNotEmpty) _lastSave = Future.wait([_lastSave, ...writes]);
  }

  List<Future<void>> _deleteImage(String imageId) {
    _images.remove(imageId);
    final delete = database?.delete(LocalDatabase.portfolioImageKey(imageId));
    return [?delete];
  }

  /// Foto karya berdasarkan ID; dibaca dari database sekali lalu disimpan di memori.
  Uint8List? imageFor(String imageId) {
    final cached = _images[imageId];
    if (cached != null) return cached;
    final stored = database?.readBytes(
      LocalDatabase.portfolioImageKey(imageId),
    );
    if (stored != null) _images[imageId] = stored;
    return stored;
  }

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
      storedItems == null
          ? samplePortfolioItems
          : decodeAll(storedItems, PortfolioItem.tryFromJson),
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
  /// dikirim ke server.
  void _commit({String? projectId}) {
    notifyListeners();
    _persist();
    if (projectId != null) _uploadWorkspace(projectId);
  }

  /// Satu dokumen per proyek berisi seluruh tugasnya. Bila dua anggota
  /// mengubah papan bersamaan, perubahan terakhir yang dipakai.
  void _uploadWorkspace(String projectId) =>
      upload(workspacesCollection, projectId, {
        'projectId': projectId,
        'tasks': [for (final task in tasksFor(projectId)) task.toJson()],
      });

  /// Mulai sinkronisasi realtime papan tugas seluruh proyek.
  void startSync(CloudStore cloud) {
    beginSync(cloud);
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
