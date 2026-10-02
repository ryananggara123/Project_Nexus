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
}
