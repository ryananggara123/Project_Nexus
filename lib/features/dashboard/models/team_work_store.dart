import 'package:flutter/foundation.dart';

import '../../../core/storage/local_database.dart';
import '../data/dashboard_sample_data.dart';
import 'portfolio_item.dart';
import 'workspace_task.dart';

/// Menyimpan tugas Workspace per proyek dan karya portofolio siswa.
/// Data ini dulu disimpan di layar Beranda sehingga hilang setiap kali
/// pengguna keluar; kini dikelola di sini dan disimpan ke database lokal.
class TeamWorkStore extends ChangeNotifier {
  TeamWorkStore({this.database}) {
    _restore();
  }

  final LocalDatabase? database;
  final Map<String, List<WorkspaceTask>> _tasks = {};
  final List<PortfolioItem> _portfolioItems = [];
  Future<void> _lastSave = Future.value();

  /// Selesai ketika penyimpanan terakhir ke database sudah tertulis.
  Future<void> get saved => _lastSave;

  List<PortfolioItem> get portfolioItems => List.unmodifiable(_portfolioItems);

  /// Pasangan (ID proyek, daftar tugas) untuk seluruh proyek yang memiliki tugas.
  Iterable<MapEntry<String, List<WorkspaceTask>>> get taskEntries =>
      _tasks.entries.map(
        (entry) => MapEntry(entry.key, List.unmodifiable(entry.value)),
      );

  bool hasTasks(String projectId) => _tasks.containsKey(projectId);

  List<WorkspaceTask> tasksFor(String projectId) =>
      List.unmodifiable(_tasks[projectId] ?? const []);

  void addTask(String projectId, WorkspaceTask task) {
    _tasks.putIfAbsent(projectId, () => []).add(task);
    _commit();
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
    _commit();
  }

  void addPortfolioItem(PortfolioItem item) {
    _portfolioItems.insert(0, item);
    _commit();
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

  void _commit() {
    notifyListeners();
    _persist();
  }
}
