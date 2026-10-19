import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../../auth/models/user_role.dart';
import '../models/portfolio_item.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/project_card.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({
    required this.header,
    required this.role,
    required this.studentName,
    required this.items,
    required this.onAddItem,
    super.key,
  });

  final Widget header;
  final UserRole role;
  final String studentName;
  final List<PortfolioItem> items;
  final ValueChanged<PortfolioItem> onAddItem;

  bool get _isTeacher => role == UserRole.teacher;

  @override
  Widget build(BuildContext context) {
    final visibleItems = _isTeacher
        ? items
        : items.where((item) => item.owner == studentName).toList();

    return MenuPage(
      header: header,
      maxWidth: 900,
      children: [
        HeroBanner(
          eyebrow: _isTeacher ? 'GALERI SEKOLAH' : 'PORTOFOLIO DIGITAL',
          title: _isTeacher
              ? 'Karya yang menginspirasi.'
              : 'Tunjukkan hasil karyamu.',
          description: _isTeacher
              ? '${visibleItems.length} karya dari siswa ProjectNexus.'
              : '${visibleItems.length} karya tersimpan di portofoliomu.',
          icon: _isTeacher
              ? Icons.auto_awesome_rounded
              : Icons.collections_bookmark_rounded,
        ),
        const SizedBox(height: 24),
        SectionTitle(
          _isTeacher ? 'Karya siswa' : 'Karya saya',
          subtitle: _isTeacher
              ? 'Portofolio membantu guru mengenali potensi dan minat setiap siswa.'
              : 'Tugas yang selesai di Workspace otomatis tercatat sebagai kontribusi.',
          action: _isTeacher
              ? null
              : FilledButton.icon(
                  key: const Key('portfolio_add_item'),
                  onPressed: () => _showAddItemDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah karya'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 14),
        if (visibleItems.isEmpty)
          const _EmptyPortfolio()
        else
          _buildPortfolioCollection(visibleItems),
      ],
    );
  }

  Widget _buildPortfolioCollection(List<PortfolioItem> visibleItems) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            children: visibleItems
                .map(
                  (item) => _PortfolioCard(item: item, showOwner: _isTeacher),
                )
                .toList(),
          );
        }
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          children: visibleItems
              .map(
                (item) => SizedBox(
                  width: cardWidth,
                  child: _PortfolioCard(item: item, showOwner: _isTeacher),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final item = await showDialog<PortfolioItem>(
      context: context,
      builder: (context) => _AddPortfolioItemDialog(studentName: studentName),
    );
    if (item != null) onAddItem(item);
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.item, required this.showOwner});

  final PortfolioItem item;
  final bool showOwner;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showOwner) ...[
                    Text(
                      item.owner,
                      style: const TextStyle(
                        color: ProjectNexusColors.teal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: ProjectNexusColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (item.isContribution)
                        const StatusPill(
                          label: 'Kontribusi tim',
                          color: ProjectNexusColors.teal,
                        ),
                      SkillTag(item.category),
                      SkillTag(item.year),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.collections_bookmark_outlined,
            size: 32,
            color: ProjectNexusColors.muted,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada karya di portofolio.',
            style: TextStyle(color: ProjectNexusColors.muted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _AddPortfolioItemDialog extends StatefulWidget {
  const _AddPortfolioItemDialog({required this.studentName});

  final String studentName;

  @override
  State<_AddPortfolioItemDialog> createState() =>
      _AddPortfolioItemDialogState();
}

class _AddPortfolioItemDialogState extends State<_AddPortfolioItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah karya'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('portfolio_item_title'),
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nama karya'),
                validator: _required,
              ),
              const SizedBox(height: 11),
              TextFormField(
                key: const Key('portfolio_item_category'),
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: _required,
              ),
              const SizedBox(height: 11),
              TextFormField(
                key: const Key('portfolio_item_description'),
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi singkat',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
            ],
          ),
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
              PortfolioItem(
                owner: widget.studentName,
                title: _titleController.text.trim(),
                category: _categoryController.text.trim(),
                description: _descriptionController.text.trim(),
                year: DateTime.now().year.toString(),
                icon: Icons.auto_awesome_outlined,
                color: ProjectNexusColors.teal,
              ),
            );
          },
          child: const Text('Simpan karya'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi.';
    }
    return null;
  }
}
