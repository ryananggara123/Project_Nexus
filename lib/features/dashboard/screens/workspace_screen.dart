import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/workspace_task.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({
    required this.tasks,
    required this.isTeacherView,
    required this.onAddTask,
    required this.onTaskStatusChanged,
    super.key,
  });

  final List<WorkspaceTask> tasks;
  final bool isTeacherView;
  final ValueChanged<WorkspaceTask> onAddTask;
  final void Function(WorkspaceTask task, WorkspaceTaskStatus status)
  onTaskStatusChanged;

  static const _members = [
    ('Nadia Putri', 'Ketua proyek'),
    ('Ryan Anggara Deki', 'Pengembang aplikasi'),
    ('Rizky Ramadhan', 'Riset & data'),
    ('Budi Santoso', 'Guru pendamping'),
  ];

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks
        .where((task) => task.status == WorkspaceTaskStatus.done)
        .length;
    final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1020),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(context, completedCount, progress),
              const SizedBox(height: 18),
              _buildProjectSummary(),
              const SizedBox(height: 18),
              _buildSectionTitle(
                context,
                'Anggota tim',
                '${_members.length} orang',
              ),
              const SizedBox(height: 10),
              _buildTeamMembers(),
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                'Papan tugas',
                '${tasks.length} tugas',
              ),
              const SizedBox(height: 5),
              const Text(
                'Pilih menu pada kartu untuk memindahkan tugas ke tahap berikutnya.',
                style: TextStyle(
                  color: ProjectNexusColors.muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              _buildBoard(context),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddTaskDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah tugas'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ProjectNexusColors.tealDark,
                    side: const BorderSide(color: ProjectNexusColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, int completedCount, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ProjectNexusColors.tealDark, Color(0xFF176B68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.view_kanban_rounded,
                color: Color(0xFFB9E2D8),
                size: 26,
              ),
              const SizedBox(width: 9),
              Text(
                isTeacherView ? 'PANEL PEMBIMBING' : 'RUANG KERJA TIM',
                style: const TextStyle(
                  color: Color(0xFFC9E9E2),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Workspace tim',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            isTeacherView
                ? 'Pantau pembagian tugas dan progres tim bimbingan.'
                : 'Atur pekerjaan bersama dan wujudkan ide jadi karya.',
            style: const TextStyle(
              color: Color(0xFFD7E9E5),
              height: 1.45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
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
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '$completedCount dari ${tasks.length} tugas selesai',
            style: const TextStyle(color: Color(0xFFD7E9E5), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: ProjectNexusColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ProjectNexusColors.mint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: ProjectNexusColors.teal,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROYEK AKTIF',
                  style: TextStyle(
                    color: ProjectNexusColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Aplikasi Pemantau Kualitas Air IoT',
                  style: TextStyle(
                    color: ProjectNexusColors.ink,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.verified_rounded,
            color: ProjectNexusColors.teal,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String trailing,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ProjectNexusColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: ProjectNexusColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMembers() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _members.map((member) {
          final isTeacher = member.$2 == 'Guru pendamping';
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 9),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: ProjectNexusColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isTeacher
                      ? const Color(0xFFFFF2E5)
                      : ProjectNexusColors.mint,
                  child: Text(
                    member.$1.substring(0, 1),
                    style: TextStyle(
                      color: isTeacher
                          ? const Color(0xFF9A572C)
                          : ProjectNexusColors.teal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        member.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProjectNexusColors.muted,
                          fontSize: 9,
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
      builder: (context) => const _AddWorkspaceTaskDialog(),
    );
    if (task != null) onAddTask(task);
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
      WorkspaceTaskStatus.todo => const Color(0xFF77878A),
      WorkspaceTaskStatus.inProgress => const Color(0xFF087E8B),
      WorkspaceTaskStatus.done => const Color(0xFF39825A),
    };

    return Container(
      key: ValueKey('workspace_column_${status.name}'),
      width: 270,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F1),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status.label,
                  style: const TextStyle(
                    color: ProjectNexusColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: const TextStyle(
                    color: ProjectNexusColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Belum ada tugas di tahap ini.',
                style: TextStyle(color: ProjectNexusColors.muted, fontSize: 11),
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
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ProjectNexusColors.border),
        boxShadow: [
          BoxShadow(
            color: ProjectNexusColors.ink.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: ProjectNexusColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
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
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 15,
                color: ProjectNexusColors.muted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  task.assignee,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProjectNexusColors.muted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: ProjectNexusColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                task.dueLabel,
                style: const TextStyle(
                  color: ProjectNexusColors.muted,
                  fontSize: 10,
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
  const _AddWorkspaceTaskDialog();

  @override
  State<_AddWorkspaceTaskDialog> createState() =>
      _AddWorkspaceTaskDialogState();
}

class _AddWorkspaceTaskDialogState extends State<_AddWorkspaceTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _assignee = 'Ryan Anggara Deki';

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
              items: const [
                DropdownMenuItem(
                  value: 'Nadia Putri',
                  child: Text('Nadia Putri'),
                ),
                DropdownMenuItem(
                  value: 'Ryan Anggara Deki',
                  child: Text('Ryan Anggara Deki'),
                ),
                DropdownMenuItem(
                  value: 'Rizky Ramadhan',
                  child: Text('Rizky Ramadhan'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _assignee = value);
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
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              WorkspaceTask(
                title: _titleController.text.trim(),
                assignee: _assignee,
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
