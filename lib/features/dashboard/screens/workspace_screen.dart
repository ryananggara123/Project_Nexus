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
          icon: Icons.view_kanban_rounded,
          bottom: _HeroProgress(
            progress: progress,
            label: '$completedCount dari ${tasks.length} tugas selesai',
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
          subtitle: 'Pilih menu pada kartu untuk memindahkan tugas ke tahap berikutnya.',
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

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final task = await showDialog<WorkspaceTask>(
      context: context,
      builder: (context) => _AddWorkspaceTaskDialog(
        assignees: members
            .where((member) => member.$2 != 'Guru pendamping')
            .map((member) => member.$1)
            .toList(),
      ),
    );
    if (task != null) onAddTask(task);
  }
}

class _HeroProgress extends StatelessWidget {
  const _HeroProgress({required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFF1C36D)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: HeroBanner.onHeroMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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
  });

  final WorkspaceTaskStatus status;
  final List<WorkspaceTask> tasks;
  final void Function(WorkspaceTask task, WorkspaceTaskStatus status)
  onTaskStatusChanged;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      WorkspaceTaskStatus.todo => ProjectNexusColors.muted,
      WorkspaceTaskStatus.inProgress => ProjectNexusColors.teal,
      WorkspaceTaskStatus.done => ProjectNexusColors.success,
    };

    return Container(
      key: ValueKey('workspace_column_${status.name}'),
      width: 272,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${tasks.length}',
                  style: const TextStyle(
                    color: ProjectNexusColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE3E3)),
              ),
              child: const Text(
                'Belum ada tugas di tahap ini.',
                style: TextStyle(color: ProjectNexusColors.muted, fontSize: 12),
              ),
            )
          else
            ...tasks.map(
              (task) => _TaskCard(
                task: task,
                onStatusChanged: (newStatus) =>
                    onTaskStatusChanged(task, newStatus),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onStatusChanged});

  final WorkspaceTask task;
  final ValueChanged<WorkspaceTaskStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
      decoration: BoxDecoration(
        color: ProjectNexusColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ProjectNexusColors.border),
      ),
      child: Column(
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
              PopupMenuButton<WorkspaceTaskStatus>(
                tooltip: 'Ubah status tugas',
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: ProjectNexusColors.muted,
                  size: 20,
                ),
                onSelected: onStatusChanged,
                itemBuilder: (context) => WorkspaceTaskStatus.values
                    .map(
                      (status) => PopupMenuItem(
                        value: status,
                        child: Text('Pindahkan ke ${status.label}'),
                      ),
                    )
                    .toList(),
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
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(
                width: 20,
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: ProjectNexusColors.muted,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.dueLabel,
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
        ],
      ),
    );
  }
}

class _AddWorkspaceTaskDialog extends StatefulWidget {
  const _AddWorkspaceTaskDialog({required this.assignees});

  final List<String> assignees;

  @override
  State<_AddWorkspaceTaskDialog> createState() =>
      _AddWorkspaceTaskDialogState();
}

class _AddWorkspaceTaskDialogState extends State<_AddWorkspaceTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _assignee;

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
      title: const Text('Tambah tugas'),
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
            Navigator.pop(
              context,
              WorkspaceTask(
                title: _titleController.text.trim(),
                assignee: _assignee!,
                dueLabel: 'Baru ditambahkan',
                status: WorkspaceTaskStatus.todo,
              ),
            );
          },
          child: const Text('Simpan tugas'),
        ),
      ],
    );
  }
}
