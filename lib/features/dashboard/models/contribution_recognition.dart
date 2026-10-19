import 'workspace_task.dart';

class ContributionBadge {
  const ContributionBadge({required this.title, required this.description});

  final String title;
  final String description;
}

class MemberContribution {
  const MemberContribution({
    required this.memberName,
    required this.assignedTaskCount,
    required this.completedTaskCount,
    required this.badges,
  });

  final String memberName;
  final int assignedTaskCount;
  final int completedTaskCount;
  final List<ContributionBadge> badges;

  double get progress =>
      assignedTaskCount == 0 ? 0 : completedTaskCount / assignedTaskCount;
}

class ContributionRecognition {
  const ContributionRecognition._();

  static List<MemberContribution> summarize({
    required Iterable<String> memberNames,
    required Iterable<WorkspaceTask> tasks,
  }) {
    return memberNames.map((memberName) {
      final memberTasks = tasks
          .where((task) => task.assignee == memberName)
          .toList();
      final completedCount = memberTasks
          .where((task) => task.status == WorkspaceTaskStatus.done)
          .length;
      return MemberContribution(
        memberName: memberName,
        assignedTaskCount: memberTasks.length,
        completedTaskCount: completedCount,
        badges: [
          if (completedCount >= 1)
            const ContributionBadge(
              title: 'Langkah Pertama',
              description: 'Menyelesaikan tugas pertamamu.',
            ),
          if (completedCount >= 3)
            const ContributionBadge(
              title: 'Konsisten',
              description: 'Tiga kontribusi selesai.',
            ),
          if (completedCount >= 5)
            const ContributionBadge(
              title: 'Penggerak Tim',
              description: 'Lima kontribusi selesai.',
            ),
        ],
      );
    }).toList();
  }
}
