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
    this.onEditItem,
    this.onDeleteItem,
    super.key,
  });

  final Widget header;
  final UserRole role;
  final String studentName;
  final List<PortfolioItem> items;
  final void Function(PortfolioItem item, Uint8List? image) onAddItem;

  /// Mengambil foto karya berdasarkan ID-nya.
  final Uint8List? Function(String imageId)? imageFor;

  /// Menyimpan hasil edit karya. [photo] adalah foto setelah diedit.
  final void Function(
    PortfolioItem item,
    PortfolioItem edited,
    Uint8List? photo,
  )?
  onEditItem;

  final ValueChanged<PortfolioItem>? onDeleteItem;

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
    return _PortfolioGallery(
      items: visibleItems,
      cardBuilder: (item) => Builder(
        builder: (context) => _PortfolioCard(
          item: item,
          showOwner: _isTeacher,
          image: _imageOf(item),
          onEdit: _canManage(item)
              ? () => _showEditItemDialog(context, item)
              : null,
          onDelete: _canManage(item)
              ? () => _confirmDelete(context, item)
              : null,
        ),
      ),
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

  /// Siswa hanya dapat mengubah karyanya sendiri; kontribusi dari Workspace
  /// tercatat otomatis sehingga tidak dapat diedit.
  bool _canManage(PortfolioItem item) =>
      !_isTeacher && !item.isContribution && item.owner == studentName;

  Future<void> _showEditItemDialog(
    BuildContext context,
    PortfolioItem item,
  ) async {
    final result = await showDialog<(PortfolioItem, Uint8List?)>(
      context: context,
      builder: (context) => _AddPortfolioItemDialog(
        studentName: studentName,
        initial: item,
        initialPhoto: _imageOf(item),
      ),
    );
    if (result != null) onEditItem?.call(item, result.$1, result.$2);
  }

  Future<void> _confirmDelete(BuildContext context, PortfolioItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus karya?'),
        content: Text(
          '“${item.title}” akan dihapus dari portofoliomu beserta fotonya.',
        ),
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
    if (confirmed ?? false) onDeleteItem?.call(item);
  }
}

/// Galeri karya dua kolom bergaya masonry dengan filter kategori.
class _PortfolioGallery extends StatefulWidget {
  const _PortfolioGallery({required this.items, required this.cardBuilder});

  final List<PortfolioItem> items;
  final Widget Function(PortfolioItem item) cardBuilder;

  @override
  State<_PortfolioGallery> createState() => _PortfolioGalleryState();
}

class _PortfolioGalleryState extends State<_PortfolioGallery> {
  static const _all = 'Semua';
  String _category = _all;

  @override
  Widget build(BuildContext context) {
    final categories = {
      for (final item in widget.items)
        if (!item.isContribution) item.category,
      if (widget.items.any((item) => item.isContribution)) 'Kontribusi',
    }.toList();
    if (!categories.contains(_category)) _category = _all;
    final shown = widget.items.where((item) {
      if (_category == _all) return true;
      if (_category == 'Kontribusi') return item.isContribution;
      return !item.isContribution && item.category == _category;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categories.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in [_all, ...categories])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      showCheckmark: false,
                      selectedColor: ProjectNexusColors.tealDark,
                      labelStyle: TextStyle(
                        color: _category == category
                            ? Colors.white
                            : ProjectNexusColors.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 680 ? 3 : 2;
            const gap = 12.0;
            // Karya dibagi bergantian ke setiap kolom (masonry sederhana).
            final lanes = List.generate(columns, (_) => <Widget>[]);
            for (final (i, item) in shown.indexed) {
              lanes[i % columns].add(
                Padding(
                  padding: const EdgeInsets.only(bottom: gap),
                  child: widget.cardBuilder(item),
                ),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, lane) in lanes.indexed) ...[
                  if (i > 0) const SizedBox(width: gap),
                  Expanded(child: Column(children: lane)),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Kartu galeri: foto (atau sampul gradien bila tanpa foto), judul, dan
/// kategori. Diketuk untuk membuka detail karya.
class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({
    required this.item,
    required this.showOwner,
    this.image,
    this.onEdit,
    this.onDelete,
  });

  final PortfolioItem item;
  final bool showOwner;
  final Uint8List? image;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String get _heroTag => 'portfolio_${item.id ?? item.title}_${item.owner}';

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => _PortfolioDetailPage(
              item: item,
              image: image,
              heroTag: _heroTag,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Hero(
                  tag: _heroTag,
                  child: image != null
                      ? AspectRatio(
                          aspectRatio: 4 / 5,
                          child: Image.memory(
                            image,
                            key: Key('portfolio_image_${item.title}'),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) =>
                                _CoverPlaceholder(item: item),
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: 1,
                          child: _CoverPlaceholder(item: item),
                        ),
                ),
                if (item.isContribution)
                  const Positioned(left: 10, top: 10, child: _GoldTag()),
                if (onEdit != null || onDelete != null)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: const CircleBorder(),
                      child: PopupMenuButton<String>(
                        key: Key('portfolio_menu_${item.title}'),
                        tooltip: 'Opsi karya',
                        iconSize: 20,
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: ProjectNexusColors.ink,
                        ),
                        onSelected: (action) => action == 'edit'
                            ? onEdit?.call()
                            : onDelete?.call(),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit karya'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete_outline_rounded,
                                color: ProjectNexusColors.error,
                              ),
                              title: Text('Hapus karya'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showOwner) ...[
                    Row(
                      children: [
                        PersonAvatar(item.owner, radius: 9),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.owner,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ProjectNexusColors.teal,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProjectNexusColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.isContribution ? 'Kontribusi' : item.category} · ${item.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
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

/// Sampul gradien berwarna kategori untuk karya tanpa foto.
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.item});

  final PortfolioItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            item.color.withValues(alpha: 0.95),
            Color.lerp(item.color, ProjectNexusColors.tealDeep, 0.55)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(
              item.icon,
              size: 120,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Center(child: Icon(item.icon, size: 40, color: Colors.white)),
        ],
      ),
    );
  }
}

/// Label emas untuk kontribusi dari Workspace. Teks "Kontribusi tim" tetap
/// sama seperti sebelumnya.
class _GoldTag extends StatelessWidget {
  const _GoldTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ProjectNexusColors.goldLight, ProjectNexusColors.gold],
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: const Text(
        'Kontribusi tim',
        style: TextStyle(
          color: ProjectNexusColors.tealDeep,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Detail karya: foto besar yang dapat diperbesar, lalu informasi karya.
class _PortfolioDetailPage extends StatelessWidget {
  const _PortfolioDetailPage({
    required this.item,
    required this.image,
    required this.heroTag,
  });

  final PortfolioItem item;
  final Uint8List? image;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    return Scaffold(
      backgroundColor: ProjectNexusColors.tealDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Detail karya',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: heroTag,
                child: image != null
                    ? InteractiveViewer(
                        maxScale: 4,
                        child: Center(
                          child: Image.memory(
                            image,
                            key: Key('portfolio_detail_image_${item.title}'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : _CoverPlaceholder(item: item),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
              decoration: const BoxDecoration(
                color: ProjectNexusColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      PersonAvatar(item.owner, radius: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.owner,
                          style: const TextStyle(
                            color: ProjectNexusColors.teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        item.year,
                        style: const TextStyle(
                          color: ProjectNexusColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: ProjectNexusColors.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (item.isContribution) const _GoldTag(),
                      SkillTag(item.category),
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
  const _AddPortfolioItemDialog({
    required this.studentName,
    this.initial,
    this.initialPhoto,
  });

  final String studentName;

  /// Karya yang sedang diedit; `null` saat menambah karya baru.
  final PortfolioItem? initial;
  final Uint8List? initialPhoto;

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

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _titleController.text = initial.title;
      _categoryController.text = initial.category;
      _descriptionController.text = initial.description;
      _photo = widget.initialPhoto;
    }
  }

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
      title: Text(_isEditing ? 'Edit karya' : 'Tambah karya'),
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
          child: Text(_isEditing ? 'Simpan perubahan' : 'Simpan karya'),
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
        setState(() => _photoError = 'Ukuran foto maksimal 700 KB.');
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
