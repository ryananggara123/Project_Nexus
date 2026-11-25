import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/contribution_recognition.dart';
import '../models/dashboard_models.dart';
import '../models/workspace_task.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/project_card.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({
    required this.header,
    required this.availableProjects,
    required this.selectedProjectId,
    required this.onProjectChanged,
    required this.projectTitle,
    required this.members,
    required this.tasks,
    required this.isTeacherView,
    required this.onAddTask,
    required this.onTaskStatusChanged,
    this.onEditTask,
    this.onDeleteTask,
    super.key,
  });

  final Widget header;
  final List<ProjectListing> availableProjects;
  final String selectedProjectId;
  final ValueChanged<String> onProjectChanged;
  final String projectTitle;
  final List<(String, String)> members;
  final List<WorkspaceTask> tasks;
  final bool isTeacherView;
  final ValueChanged<WorkspaceTask> onAddTask;
  final void Function(WorkspaceTask task, WorkspaceTaskStatus status)
  onTaskStatusChanged;
  final void Function(WorkspaceTask task, WorkspaceTask updated)? onEditTask;
  final ValueChanged<WorkspaceTask>? onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks
        .where((task) => task.status == WorkspaceTaskStatus.done)
        .length;
    final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

    return MenuPage(
      header: header,
      maxWidth: 1020,
      lazy: false,
      children: [
        HeroBanner(
          eyebrow: isTeacherView ? 'PANEL PEMBIMBING' : 'RUANG KERJA TIM',
          title: projectTitle,
          description: isTeacherView
              ? 'Pantau pembagian tugas dan progres tim bimbingan.'
              : 'Atur pekerjaan bersama dan wujudkan ide jadi karya.',
          trailing: _ProgressRing(progress: progress),
          bottom: _HeroProgress(
            label: '$completedCount dari ${tasks.length} tugas selesai',
            counts: {
              for (final status in WorkspaceTaskStatus.values)
                status: tasks.where((task) => task.status == status).length,
            },
          ),
        ),
        if (availableProjects.length > 1) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const Key('workspace_project_selector'),
            initialValue: selectedProjectId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Pilih proyek',
              prefixIcon: Icon(Icons.folder_open_rounded, size: 20),
            ),
            items: availableProjects
                .map(
                  (project) => DropdownMenuItem(
                    value: project.id,
                    child: Text(project.title, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (projectId) {
              if (projectId != null) onProjectChanged(projectId);
            },
          ),
        ],
        const SizedBox(height: 24),
        SectionTitle('Anggota tim', trailing: '${members.length} orang'),
        const SizedBox(height: 12),
        _buildTeamMembers(),
        const SizedBox(height: 28),
        const SectionTitle(
          'Apresiasi kontribusi',
          trailing: 'Dari tugas selesai',
          subtitle: 'Setiap anggota berkembang dengan langkahnya sendiri. Lencana diberikan dari tugas yang sudah ditandai selesai.',
        ),
        const SizedBox(height: 12),
        _buildContributionRecognition(),
        const SizedBox(height: 28),
        SectionTitle(
          'Papan tugas',
          trailing: '${tasks.length} tugas',
          subtitle: 'Tekan lama kartu lalu geser ke kolom lain, atau pakai menu ⋯ pada kartu.',
        ),
        const SizedBox(height: 12),
        _buildBoard(context),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showAddTaskDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah tugas'),
        ),
      ],
    );
  }

  Widget _buildTeamMembers() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: members.map((member) {
          return Container(
            width: 168,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ProjectNexusColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ProjectNexusColors.border),
            ),
            child: Row(
              children: [
                PersonAvatar(member.$1, radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProjectNexusColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProjectNexusColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContributionRecognition() {
    final studentMembers = members
        .where((member) => member.$2 != 'Guru pendamping')
        .map((member) => member.$1);
    final contributions = ContributionRecognition.summarize(
      memberNames: studentMembers,
      tasks: tasks,
    );

    return Column(
      children: contributions.map((contribution) {
        return Card(
          key: Key('member_contribution_${contribution.memberName}'),
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PersonAvatar(contribution.memberName, radius: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        contribution.memberName,
                        style: const TextStyle(
                          color: ProjectNexusColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${contribution.completedTaskCount}/${contribution.assignedTaskCount} selesai',
                      style: const TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: contribution.progress,
                    minHeight: 6,
                    backgroundColor: ProjectNexusColors.field,
                    valueColor: const AlwaysStoppedAnimation(
                      ProjectNexusColors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (contribution.badges.isEmpty)
                  const Text(
                    'Mulai dari satu tugas kecil. Progresmu akan tercatat di sini.',
                    style: TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: contribution.badges.map((badge) {
                      return Tooltip(
                        message: badge.description,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3D5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events_rounded,
                                size: 14,
                                color: Color(0xFF8C641C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                badge.title,
                                style: const TextStyle(
                                  color: Color(0xFF755315),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBoard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = WorkspaceTaskStatus.values.map((status) {
          final statusTasks = tasks
              .where((task) => task.status == status)
              .toList();
          return _TaskColumn(
            status: status,
            tasks: statusTasks,
            onTaskStatusChanged: onTaskStatusChanged,
            onEdit: (task) => _showEditTaskDialog(context, task),
            onDelete: (task) => _confirmDeleteTask(context, task),
          );
        }).toList();

        if (constraints.maxWidth >= 850) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns.map((column) => Expanded(child: column)).toList(),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns,
          ),
        );
      },
    );
  }

  List<String> get _assignees => members
      .where((member) => member.$2 != 'Guru pendamping')
      .map((member) => member.$1)
      .toList();

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final task = await showDialog<WorkspaceTask>(
      context: context,
      builder: (context) => _AddWorkspaceTaskDialog(assignees: _assignees),
    );
    if (task != null) onAddTask(task);
  }

  Future<void> _showEditTaskDialog(
    BuildContext context,
    WorkspaceTask task,
  ) async {
    final updated = await showDialog<WorkspaceTask>(
      context: context,
      builder: (context) =>
          _AddWorkspaceTaskDialog(assignees: _assignees, initial: task),
    );
    if (updated != null) onEditTask?.call(task, updated);
  }

  Future<void> _confirmDeleteTask(
    BuildContext context,
    WorkspaceTask task,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('“${task.title}” akan dihapus dari papan tugas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('confirm_delete'),
            style: FilledButton.styleFrom(
              backgroundColor: ProjectNexusColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onDeleteTask?.call(task);
  }
}

/// Membaca tenggat seperti "15 Okt 2026"; `null` bila bukan tanggal.
DateTime? parseDueDate(String label) {
  const months = [
    'jan', 'feb', 'mar', 'apr', 'mei', 'jun', //
    'jul', 'agu', 'sep', 'okt', 'nov', 'des',
  ];
  final match = RegExp(r'^(\d{1,2})\s+([a-zA-Z]{3})\w*\s+(\d{4})$')
      .firstMatch(label.trim());
  if (match == null) return null;
  final month = months.indexOf(match.group(2)!.toLowerCase()) + 1;
  if (month == 0) return null;
  return DateTime(
    int.parse(match.group(3)!),
    month,
    int.parse(match.group(1)!),
  );
}

/// Warna setiap tahap papan tugas.
Color statusColor(WorkspaceTaskStatus status) => switch (status) {
  WorkspaceTaskStatus.todo => const Color(0xFF6B7C93),
  WorkspaceTaskStatus.inProgress => ProjectNexusColors.gold,
  WorkspaceTaskStatus.done => const Color(0xFF2E9E6A),
};

/// Cincin persentase tugas selesai di hero Workspace.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox.square(
        dimension: 78,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation(
                ProjectNexusColors.goldLight,
              ),
            ),
            Center(
              child: Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ringkasan di bawah hero: jumlah tugas per tahap.
class _HeroProgress extends StatelessWidget {
  const _HeroProgress({required this.label, required this.counts});

  final String label;
  final Map<WorkspaceTaskStatus, int> counts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in counts.entries)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: entry.key == WorkspaceTaskStatus.todo
                            ? const Color(0xFFB8C4D4)
                            : statusColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key.label} ${entry.value}',
                      style: const TextStyle(
                        color: HeroBanner.onHeroMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TaskColumn extends StatelessWidget {
  const _TaskColumn({
    required this.status,
    required this.tasks,
    required this.onTaskStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkspaceTaskStatus status;
  final List<WorkspaceTask> tasks;
  final void Function(WorkspaceTask task, WorkspaceTaskStatus status)
  onTaskStatusChanged;
  final ValueChanged<WorkspaceTask> onEdit;
  final ValueChanged<WorkspaceTask> onDelete;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return DragTarget<WorkspaceTask>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) =>
          onTaskStatusChanged(details.data, status),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          key: ValueKey('workspace_column_${status.name}'),
          width: 264,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: hovering
                ? color.withValues(alpha: 0.14)
                : const Color(0xFFEEF2F1),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: hovering ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 4, width: double.infinity, color: color),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status.label,
                        style: const TextStyle(
                          color: ProjectNexusColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  children: [
                    if (tasks.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD6DEDD)),
                        ),
                        child: Text(
                          hovering
                              ? 'Lepaskan di sini'
                              : 'Belum ada tugas di tahap ini.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ProjectNexusColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      ...tasks.map(
                        (task) => _TaskCard(
                          task: task,
                          onStatusChanged: (newStatus) =>
                              onTaskStatusChanged(task, newStatus),
                          onEdit: () => onEdit(task),
                          onDelete: () => onDelete(task),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkspaceTask task;
  final ValueChanged<WorkspaceTaskStatus> onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final card = _content(context);
    // Tekan lama lalu geser ke kolom lain untuk memindahkan tahap tugas.
    return LongPressDraggable<WorkspaceTask>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 244,
          child: Transform.rotate(angle: -0.03, child: card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }

  Widget _content(BuildContext context) {
    final color = statusColor(task.status);
    final due = _dueStyle(task);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ProjectNexusColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
                child: _details(due),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Warna tenggat: merah bila terlambat, oranye bila hari ini, hijau bila
  /// tugas sudah selesai.
  static ({Color color, IconData icon}) _dueStyle(WorkspaceTask task) {
    final label = task.dueLabel.toLowerCase();
    if (task.status == WorkspaceTaskStatus.done) {
      return (color: const Color(0xFF2E9E6A), icon: Icons.check_circle_rounded);
    }
    final date = parseDueDate(task.dueLabel);
    final today = DateUtils.dateOnly(DateTime.now());
    if (label.contains('terlambat') || (date != null && date.isBefore(today))) {
      return (
        color: ProjectNexusColors.error,
        icon: Icons.error_outline_rounded,
      );
    }
    if (label.contains('hari ini') || date == today) {
      return (color: ProjectNexusColors.warning, icon: Icons.schedule_rounded);
    }
    return (
      color: ProjectNexusColors.muted,
      icon: Icons.calendar_today_outlined,
    );
  }

  Widget _details(({Color color, IconData icon}) due) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: ProjectNexusColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            // Nilai menu berupa status (pindah kolom) atau 'edit'/'delete'.
            PopupMenuButton<Object>(
              tooltip: 'Opsi tugas',
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: ProjectNexusColors.muted,
                size: 20,
              ),
              onSelected: (value) => switch (value) {
                WorkspaceTaskStatus status => onStatusChanged(status),
                'edit' => onEdit(),
                _ => onDelete(),
              },
              itemBuilder: (context) => [
                for (final status in WorkspaceTaskStatus.values)
                  if (status != task.status)
                    PopupMenuItem<Object>(
                      value: status,
                      child: Text('Pindahkan ke ${status.label}'),
                    ),
                const PopupMenuDivider(),
                const PopupMenuItem<Object>(
                  value: 'edit',
                  child: Text('Edit tugas'),
                ),
                const PopupMenuItem<Object>(
                  value: 'delete',
                  child: Text(
                    'Hapus tugas',
                    style: TextStyle(color: ProjectNexusColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            PersonAvatar(task.assignee, radius: 10),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                task.assignee,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ProjectNexusColors.muted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: due.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(due.icon, size: 13, color: due.color),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    task.dueLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: due.color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddWorkspaceTaskDialog extends StatefulWidget {
  const _AddWorkspaceTaskDialog({required this.assignees, this.initial});

  final List<String> assignees;

  /// Tugas yang sedang diedit; `null` saat menambah tugas baru.
  final WorkspaceTask? initial;

  @override
  State<_AddWorkspaceTaskDialog> createState() =>
      _AddWorkspaceTaskDialogState();
}

class _AddWorkspaceTaskDialogState extends State<_AddWorkspaceTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _assignee;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _titleController.text = initial.title;
      // Penanggung jawab lama dipertahankan bila masih anggota tim.
      if (widget.assignees.contains(initial.assignee)) {
        _assignee = initial.assignee;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _assignee ??= widget.assignees.firstOrNull;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Tambah tugas' : 'Edit tugas'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('workspace_task_title'),
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nama tugas'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama tugas wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('workspace_task_assignee'),
              initialValue: _assignee,
              decoration: const InputDecoration(labelText: 'Penanggung jawab'),
              items: widget.assignees
                  .map(
                    (assignee) => DropdownMenuItem(
                      value: assignee,
                      child: Text(assignee),
                    ),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Pilih anggota penanggung jawab.' : null,
              onChanged: (value) {
                setState(() => _assignee = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (widget.assignees.isEmpty) return;
            if (!_formKey.currentState!.validate()) return;
            final initial = widget.initial;
            Navigator.pop(
              context,
              WorkspaceTask(
                title: _titleController.text.trim(),
                assignee: _assignee!,
                dueLabel: initial?.dueLabel ?? 'Baru ditambahkan',
                status: initial?.status ?? WorkspaceTaskStatus.todo,
              ),
            );
          },
          child: Text(
            widget.initial == null ? 'Simpan tugas' : 'Simpan perubahan',
          ),
        ),
      ],
    );
  }
}
