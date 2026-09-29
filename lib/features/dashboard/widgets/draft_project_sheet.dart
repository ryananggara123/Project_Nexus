import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';

class DraftProjectSheet extends StatefulWidget {
  const DraftProjectSheet({super.key});

  @override
  State<DraftProjectSheet> createState() => _DraftProjectSheetState();
}

class _DraftProjectSheetState extends State<DraftProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedTeacher;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAF9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7D1D0),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ajukan draf proyek',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF172A2D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Draf perlu ditinjau guru sebelum tampil di feed.',
                    style: TextStyle(color: Color(0xFF627174)),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('draft_project_title'),
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul proyek atau lomba',
                      border: OutlineInputBorder(),
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
                      labelText: 'Deskripsi dan target',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Deskripsi proyek wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    key: const Key('draft_project_teacher'),
                    initialValue: _selectedTeacher,
                    decoration: const InputDecoration(
                      labelText: 'Guru pendamping',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Budi Santoso',
                        child: Text('Budi Santoso'),
                      ),
                      DropdownMenuItem(
                        value: 'Siti Rahmawati',
                        child: Text('Siti Rahmawati'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedTeacher = value),
                    validator: (value) =>
                        value == null ? 'Pilih guru pendamping.' : null,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(
                            context,
                            ProjectListing(
                              title: _titleController.text.trim(),
                              leader: 'Ryan Anggara Deki',
                              event: 'Proyek siswa',
                              description: _descriptionController.text.trim(),
                              skills: const [],
                              teacherName: _selectedTeacher!,
                              statusAcc: 'pending',
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Kirim untuk ditinjau'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF172A2D),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
