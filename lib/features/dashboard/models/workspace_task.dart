enum WorkspaceTaskStatus {
  todo('To-Do'),
  inProgress('In Progress'),
  done('Done');

  const WorkspaceTaskStatus(this.label);

  final String label;
}

class WorkspaceTask {
  const WorkspaceTask({
    required this.title,
    required this.assignee,
    required this.dueLabel,
    required this.status,
  });

  final String title;
  final String assignee;
  final String dueLabel;
  final WorkspaceTaskStatus status;

  WorkspaceTask copyWith({WorkspaceTaskStatus? status}) {
    return WorkspaceTask(
      title: title,
      assignee: assignee,
      dueLabel: dueLabel,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'assignee': assignee,
    'dueLabel': dueLabel,
    'status': status.name,
  };

  /// Membaca tugas dari database; `null` bila datanya tidak lengkap atau rusak.
  static WorkspaceTask? tryFromJson(Map<String, dynamic> json) {
    try {
      return WorkspaceTask(
        title: json['title'] as String,
        assignee: json['assignee'] as String,
        dueLabel: json['dueLabel'] as String,
        status: WorkspaceTaskStatus.values.byName(json['status'] as String),
      );
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }
}
