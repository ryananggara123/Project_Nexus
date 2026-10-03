import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../../auth/models/user_role.dart';
import '../models/portfolio_item.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({
    required this.role,
    required this.studentName,
    required this.items,
    required this.onAddItem,
    super.key,
  });

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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList.list(
                children: [
                  _buildHero(context, visibleItems.length),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isTeacher ? 'Karya siswa' : 'Karya saya',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: ProjectNexusColors.ink,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      if (!_isTeacher)
                        FilledButton.icon(
                          key: const Key('portfolio_add_item'),
                          onPressed: () => _showAddItemDialog(context),
                          icon: const Icon(Icons.add_rounded, size: 19),
                          label: const Text('Tambah karya'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isTeacher
                        ? 'Jelajahi contoh karya dan pencapaian siswa.'
                        : 'Kumpulan proyek dan pencapaian yang bisa dilihat tim.',
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (visibleItems.isEmpty)
                    const _EmptyPortfolio()
                  else
                    _buildPortfolioCollection(visibleItems),
                  const SizedBox(height: 8),
                  _buildPortfolioNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCollection(List<PortfolioItem> visibleItems) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 2 : 1;
        if (columns == 1) {
          return Column(
            children: visibleItems
                .map(
                  (item) => _PortfolioCard(
                    item: item,
                    showOwner: _isTeacher,
                  ),
                )
                .toList(),
          );
        }
        final cardWidth = (constraints.maxWidth - 14) / 2;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
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

  Widget _buildHero(BuildContext context, int itemCount) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ProjectNexusColors.tealDark, Color(0xFF176B68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isTeacher ? 'GALERI SEKOLAH' : 'PORTOFOLIO DIGITAL',
                  style: const TextStyle(
                    color: Color(0xFFC9E9E2),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isTeacher ? 'Karya yang menginspirasi.' : 'Tunjukkan hasil karyamu.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _isTeacher
                      ? '$itemCount karya dari siswa ProjectNexus'
                      : '$itemCount karya tersimpan di portofoliomu',
                  style: const TextStyle(
                    color: Color(0xFFD7E9E5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            _isTeacher
                ? Icons.auto_awesome_rounded
                : Icons.collections_bookmark_rounded,
            color: const Color(0xFFF1C36D),
            size: 43,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProjectNexusColors.mint,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 19,
            color: ProjectNexusColors.teal,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _isTeacher
                  ? 'Portofolio membantu guru mengenali potensi dan minat setiap siswa.'
                  : 'Lengkapi portofolio dengan karya nyata agar ketua proyek dapat mengenal keahlianmu.',
              style: const TextStyle(
                color: ProjectNexusColors.tealDark,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final item = await showDialog<PortfolioItem>(
      context: context,
      builder: (context) => _AddPortfolioItemDialog(
        studentName: studentName,
      ),
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
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: ProjectNexusColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.color.withValues(alpha: 0.18),
                    item.color.withValues(alpha: 0.07),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(item.icon, color: item.color, size: 25),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showOwner) ...[
                    Text(
                      item.owner,
                      style: const TextStyle(
                        color: ProjectNexusColors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ProjectNexusColors.ink,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      _PortfolioTag(item.category),
                      _PortfolioTag(item.year),
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

class _PortfolioTag extends StatelessWidget {
  const _PortfolioTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ProjectNexusColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
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
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.collections_bookmark_outlined,
            size: 40,
            color: ProjectNexusColors.teal,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada karya di portofolio.',
            style: TextStyle(color: ProjectNexusColors.muted),
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
