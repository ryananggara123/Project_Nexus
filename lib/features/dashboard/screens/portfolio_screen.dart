import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/media/photo_picker.dart';
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
    this.imageFor,
    super.key,
  });

  final Widget header;
  final UserRole role;
  final String studentName;
  final List<PortfolioItem> items;
  final void Function(PortfolioItem item, Uint8List? image) onAddItem;

  /// Mengambil foto karya berdasarkan ID-nya.
  final Uint8List? Function(String imageId)? imageFor;

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
                    textStyle: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
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
                  (item) => _PortfolioCard(
                    item: item,
                    showOwner: _isTeacher,
                    image: _imageOf(item),
                  ),
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
                  child: _PortfolioCard(
                    item: item,
                    showOwner: _isTeacher,
                    image: _imageOf(item),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Uint8List? _imageOf(PortfolioItem item) {
    final imageId = item.imageId;
    return imageId == null ? null : imageFor?.call(imageId);
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final result = await showDialog<(PortfolioItem, Uint8List?)>(
      context: context,
      builder: (context) => _AddPortfolioItemDialog(studentName: studentName),
    );
    if (result != null) onAddItem(result.$1, result.$2);
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({
    required this.item,
    required this.showOwner,
    this.image,
  });

  final PortfolioItem item;
  final bool showOwner;
  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.memory(
                image,
                key: Key('portfolio_image_${item.title}'),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: ProjectNexusColors.field,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: ProjectNexusColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
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
        ],
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
  Uint8List? _photo;
  String? _photoError;
  bool _pickingPhoto = false;

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
              const SizedBox(height: 14),
              _PhotoField(
                photo: _photo,
                error: _photoError,
                busy: _pickingPhoto,
                onPick: _pickPhoto,
                onRemove: () => setState(() => _photo = null),
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
            Navigator.pop(context, (
              PortfolioItem(
                owner: widget.studentName,
                title: _titleController.text.trim(),
                category: _categoryController.text.trim(),
                description: _descriptionController.text.trim(),
                year: DateTime.now().year.toString(),
                icon: Icons.auto_awesome_outlined,
                color: ProjectNexusColors.teal,
              ),
              _photo,
            ));
          },
          child: const Text('Simpan karya'),
        ),
      ],
    );
  }

  Future<void> _pickPhoto(PhotoSource source) async {
    setState(() {
      _pickingPhoto = true;
      _photoError = null;
    });
    try {
      final photo = await PhotoPicker.instance.pick(source);
      if (!mounted || photo == null) return;
      if (photo.length > PhotoPicker.maxBytes) {
        setState(() => _photoError = 'Ukuran foto maksimal 2 MB.');
        return;
      }
      setState(() => _photo = photo);
    } on Exception {
      // Misalnya izin kamera ditolak atau perangkat tidak memiliki kamera.
      if (mounted) {
        setState(
          () =>
              _photoError = 'Foto tidak dapat diambil. Coba pilih dari galeri.',
        );
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi.';
    }
    return null;
  }
}

/// Pilihan foto karya: tombol kamera dan galeri, atau pratinjau foto terpilih.
class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.photo,
    required this.error,
    required this.busy,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? photo;
  final String? error;
  final bool busy;
  final ValueChanged<PhotoSource> onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    final error = this.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto karya (opsional)',
          style: TextStyle(
            color: ProjectNexusColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (photo != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.memory(
                photo,
                key: const Key('portfolio_photo_preview'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('portfolio_photo_remove'),
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Hapus foto'),
            ),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('portfolio_photo_camera'),
                  onPressed: busy ? null : () => onPick(PhotoSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Kamera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('portfolio_photo_gallery'),
                  onPressed: busy ? null : () => onPick(PhotoSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Galeri'),
                ),
              ),
            ],
          ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error,
            style: const TextStyle(
              color: ProjectNexusColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
