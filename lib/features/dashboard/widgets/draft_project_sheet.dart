import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/dashboard_models.dart';

class DraftProjectSheet extends StatefulWidget {
  const DraftProjectSheet({
    required this.studentName,
    this.projectToRevise,
    super.key,
  });

  final String studentName;
  final ProjectListing? projectToRevise;

  @override
  State<DraftProjectSheet> createState() => _DraftProjectSheetState();
}

class _DraftProjectSheetState extends State<DraftProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedSkills = {};
  late String? _selectedTeacher;

  static const _availableSkills = [
    'Flutter',
    'UI/UX',
    'Riset',
    'Penulis',
    'IoT',
    'Desain',
    'Basis Data',
  ];

  @override
  void initState() {
    super.initState();
    final project = widget.projectToRevise;
    _titleController.text = project?.title ?? '';
    _descriptionController.text = project?.description ?? '';
    _selectedTeacher = project?.teacherName;
    _selectedSkills.addAll(project?.skills ?? const []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectToRevise = widget.projectToRevise;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            decoration: const BoxDecoration(
              color: ProjectNexusColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8E1DF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    projectToRevise == null
                        ? 'PENGAJUAN PROYEK'
                        : 'REVISI PENGAJUAN',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ProjectNexusColors.teal,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    projectToRevise == null
                        ? 'Ceritakan ide proyekmu'
                        : 'Sempurnakan idemu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ProjectNexusColors.ink,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    projectToRevise == null
                        ? 'Lengkapi informasi berikut agar guru dapat meninjau rencanamu.'
                        : 'Perbarui detail proyek berdasarkan masukan guru, lalu kirim kembali untuk ditinjau.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ProjectNexusColors.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F7F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ProjectNexusColors.border,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: ProjectNexusColors.teal,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            projectToRevise == null
                                ? 'Pengajuan akan ditampilkan di feed setelah disetujui guru pendamping.'
                                : 'Revisi dikirim kepada ${projectToRevise.teacherName}. Guru pendamping tidak dapat diubah.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: ProjectNexusColors.ink,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    key: const Key('draft_project_title'),
                    controller: _titleController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.title_rounded),
                      labelText: 'Judul proyek atau lomba',
                      hintText: 'Contoh: Sistem Kebun Hidroponik Pintar',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Judul proyek wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    key: const Key('draft_project_description'),
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.notes_rounded),
                      ),
                      labelText: 'Deskripsi dan target',
                      hintText: 'Jelaskan masalah, ide solusi, dan target proyek.',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Deskripsi proyek wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: 13),
                  FormField<Set<String>>(
                    initialValue: _selectedSkills,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Pilih minimal satu keahlian yang dibutuhkan.'
                        : null,
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Keahlian yang dibutuhkan',
                          style: TextStyle(
                            color: ProjectNexusColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          children: _availableSkills.map((skill) {
                            final selected = _selectedSkills.contains(skill);
                            return FilterChip(
                              key: Key('draft_skill_$skill'),
                              label: Text(skill),
                              selected: selected,
                              onSelected: (isSelected) {
                                if (isSelected) {
                                  _selectedSkills.add(skill);
                                } else {
                                  _selectedSkills.remove(skill);
                                }
                                field.didChange(Set.of(_selectedSkills));
                              },
                            );
                          }).toList(),
                        ),
                        if (field.errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 5),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    key: const Key('draft_project_teacher'),
                    initialValue: _selectedTeacher,
                    decoration: InputDecoration(
                      labelText: 'Guru pendamping',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      helperText: projectToRevise == null
                          ? 'Pilih guru yang akan meninjau pengajuan.'
                          : 'Tetap ditinjau oleh guru yang sama.',
                    ),
                    items: [
                      if (projectToRevise == null &&
                          _selectedTeacher != 'Budi Santoso')
                        const DropdownMenuItem(
                          value: 'Budi Santoso',
                          child: Text('Budi Santoso'),
                        ),
                      if (projectToRevise == null &&
                          _selectedTeacher != 'Siti Rahmawati')
                        const DropdownMenuItem(
                          value: 'Siti Rahmawati',
                          child: Text('Siti Rahmawati'),
                        ),
                      if (_selectedTeacher != null)
                        DropdownMenuItem(
                          value: _selectedTeacher,
                          child: Text(_selectedTeacher!),
                        ),
                    ],
                    onChanged: projectToRevise == null
                        ? (value) => setState(() => _selectedTeacher = value)
                        : null,
                    validator: (value) =>
                        value == null ? 'Pilih guru pendamping.' : null,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('draft_project_submit'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final previous = widget.projectToRevise;
                          Navigator.pop(
                            context,
                            previous == null
                                ? ProjectListing(
                                    id: 'project-${DateTime.now().microsecondsSinceEpoch}',
                                    title: _titleController.text.trim(),
                                    leader: widget.studentName,
                                    event: 'Proyek siswa',
                                    description: _descriptionController.text
                                        .trim(),
                                    skills: _selectedSkills.toList(),
                                    teacherName: _selectedTeacher!,
                                    statusAcc: 'pending',
                                    recruitmentOpen: false,
                                  )
                                : previous.copyWith(
                                    title: _titleController.text.trim(),
                                    description: _descriptionController.text
                                        .trim(),
                                    statusAcc: 'pending',
                                    clearReviewNote: true,
                                  ),
                          );
                        }
                      },
                      icon: Icon(
                        projectToRevise == null
                            ? Icons.send_rounded
                            : Icons.replay_rounded,
                      ),
                      label: Text(
                        widget.projectToRevise == null
                            ? 'Kirim untuk ditinjau'
                            : 'Kirim ulang untuk ditinjau',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF123C40),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
        ),
      ),
        ),
      ),
    );
  }
}
