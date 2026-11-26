import 'package:flutter/material.dart';

import '../../../core/media/photo_picker.dart';
import '../../../core/theme/project_nexus_colors.dart';
import '../models/profile_data.dart';
import '../models/profile_photo_store.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/project_card.dart';
import '../widgets/skill_picker.dart';

/// Satu angka ringkasan di profil, misalnya jumlah proyek.
typedef ProfileStat = ({String label, int value, IconData icon});

/// Lencana pencapaian; [earned] false ditampilkan terkunci.
typedef ProfileBadge = ({
  String title,
  String hint,
  IconData icon,
  bool earned,
});

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.header,
    required this.profile,
    required this.onProfileChanged,
    this.stats = const [],
    this.badges = const [],
    this.highlight,
    this.openToInvite,
    this.onOpenToInviteChanged,
    super.key,
  });

  /// Kartu tambahan di bawah statistik, misalnya level dan misi.
  final Widget? highlight;

  /// Status di Direktori Bakat; `null` menyembunyikan pengaturannya.
  final bool? openToInvite;
  final ValueChanged<bool>? onOpenToInviteChanged;

  final Widget header;
  final ProfileData profile;
  final ValueChanged<ProfileData> onProfileChanged;
  final List<ProfileStat> stats;
  final List<ProfileBadge> badges;

  bool get _isStudentProfile => profile.roleLabel.startsWith('Siswa');

  @override
  Widget build(BuildContext context) {
    return MenuPage(
      header: header,
      children: [
        _ProfileCover(
          profile: profile,
          avatar: _ProfileAvatar(
            name: profile.name,
            initials: _initials(profile.name),
            onTap: () => _showPhotoOptions(context),
          ),
          onEdit: () => _showEditDialog(context),
        ),
        if (stats.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ProfileStats(stats),
        ],
        if (highlight case final highlight?) ...[
          const SizedBox(height: 16),
          highlight,
        ],
        const SizedBox(height: 16),
        if (badges.isNotEmpty)
          _ProfileSection(
            title: 'Lencana',
            icon: Icons.workspace_premium_outlined,
            child: _BadgeShowcase(badges),
          ),
        _ProfileSection(
          title: 'Tentang',
          icon: Icons.person_outline_rounded,
          child: Text(
            profile.bio,
            style: const TextStyle(
              color: ProjectNexusColors.muted,
              height: 1.55,
              fontSize: 14,
            ),
          ),
        ),
        _ProfileSection(
          title: 'Keahlian',
          icon: Icons.bolt_rounded,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profile.skills.map(SkillTag.new).toList(),
          ),
        ),
        if (_isStudentProfile)
          _ProfileSection(
            title: 'Preferensi rekomendasi',
            icon: Icons.tune_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Minat',
                  style: TextStyle(
                    color: ProjectNexusColors.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.interests
                      .map(
                        (interest) => StatusPill(
                          label: interest,
                          color: ProjectNexusColors.teal,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  'Waktu luang: ${profile.weeklyAvailableHours} jam per minggu',
                  style: const TextStyle(
                    color: ProjectNexusColors.ink,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        if (openToInvite case final open?)
          _ProfileSection(
            title: 'Direktori Bakat',
            icon: Icons.diversity_3_rounded,
            child: SwitchListTile(
              key: const Key('profile_open_to_invite'),
              contentPadding: EdgeInsets.zero,
              value: open,
              onChanged: onOpenToInviteChanged,
              title: const Text('Terbuka untuk diajak bergabung'),
              subtitle: const Text(
                'Siswa lain dapat melihat keahlianmu dan mengajakmu ke tim.',
              ),
            ),
          ),
        _ProfileSection(
          title: 'Informasi kontak',
          icon: Icons.contact_mail_outlined,
          child: Column(
            children: [
              _ContactRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: profile.email,
              ),
              const SizedBox(height: 12),
              _ContactRow(
                icon: Icons.location_on_outlined,
                label: 'Institusi',
                value: profile.institution,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ketuk foto profil untuk menggantinya. Foto terlihat oleh anggota tim dan guru.',
          textAlign: TextAlign.center,
          style: TextStyle(color: ProjectNexusColors.muted, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final editedProfile = await showDialog<ProfileData>(
      context: context,
      builder: (context) => _EditProfileDialog(profile: profile),
    );
    if (editedProfile != null) onProfileChanged(editedProfile);
  }

  /// Pilihan foto profil: kamera, galeri, atau hapus foto.
  Future<void> _showPhotoOptions(BuildContext context) async {
    final store = ProfilePhotoScope.maybeOf(context);
    if (store == null) return;
    final hasPhoto = store.photoFor(profile.name) != null;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Foto profil',
                style: TextStyle(
                  color: ProjectNexusColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              key: const Key('profile_photo_camera'),
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dari kamera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              key: const Key('profile_photo_gallery'),
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (hasPhoto)
              ListTile(
                key: const Key('profile_photo_remove'),
                leading: const Icon(
                  Icons.delete_outline,
                  color: ProjectNexusColors.error,
                ),
                title: const Text(
                  'Hapus foto',
                  style: TextStyle(color: ProjectNexusColors.error),
                ),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    void show(String text) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

    if (choice == 'remove') {
      store.removePhoto(profile.name);
      show('Foto profil dihapus.');
      return;
    }
    try {
      final photo = await PhotoPicker.instance.pick(
        choice == 'camera' ? PhotoSource.camera : PhotoSource.gallery,
      );
      if (photo == null) return;
      if (photo.length > PhotoPicker.maxBytes) {
        show('Ukuran foto maksimal 700 KB.');
        return;
      }
      store.setPhoto(profile.name, photo);
      show('Foto profil diperbarui.');
    } on Exception {
      // Misalnya izin kamera ditolak atau perangkat tidak memiliki kamera.
      show('Foto tidak dapat diambil. Coba pilih dari galeri.');
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ProjectNexusColors.mint,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, size: 16, color: ProjectNexusColors.teal),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: ProjectNexusColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ProjectNexusColors.muted),
        const SizedBox(width: 10),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(
              color: ProjectNexusColors.muted,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: ProjectNexusColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.profile});

  final ProfileData profile;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _institutionController;
  late final TextEditingController _bioController;
  late final Set<String> _selectedSkills;
  late final Set<String> _selectedInterests;
  late int _weeklyAvailableHours;

  bool get _isStudentProfile => widget.profile.roleLabel.startsWith('Siswa');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _institutionController = TextEditingController(
      text: widget.profile.institution,
    );
    _bioController = TextEditingController(text: widget.profile.bio);
    _selectedSkills = {...widget.profile.skills};
    _selectedInterests = {...widget.profile.interests};
    _weeklyAvailableHours = widget.profile.weeklyAvailableHours;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit profil'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('profile_name'),
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: _required,
              ),
              const SizedBox(height: 11),
              TextFormField(
                key: const Key('profile_institution'),
                controller: _institutionController,
                decoration: const InputDecoration(labelText: 'Institusi'),
                validator: _required,
              ),
              const SizedBox(height: 11),
              TextFormField(
                key: const Key('profile_bio'),
                controller: _bioController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Tentang',
                  alignLabelWithHint: true,
                ),
                validator: _required,
              ),
              if (_isStudentProfile) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Keahlian yang sudah kamu miliki',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                SkillPicker(
                  keyPrefix: 'profile_skill_',
                  selected: _selectedSkills,
                  onChanged: (skills) => setState(() {
                    _selectedSkills
                      ..clear()
                      ..addAll(skills);
                  }),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Topik yang kamu minati',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 0,
                  children: availableStudentInterests.map((interest) {
                    return FilterChip(
                      key: Key('profile_interest_$interest'),
                      label: Text(interest),
                      selected: _selectedInterests.contains(interest),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedInterests.add(interest);
                          } else {
                            _selectedInterests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: const Key('profile_weekly_hours'),
                  initialValue: _weeklyAvailableHours,
                  decoration: const InputDecoration(
                    labelText: 'Waktu luang per minggu',
                    prefixIcon: Icon(Icons.schedule_outlined),
                  ),
                  items: availableWeeklyHours
                      .map(
                        (hours) => DropdownMenuItem(
                          value: hours,
                          child: Text('$hours jam per minggu'),
                        ),
                      )
                      .toList(),
                  onChanged: (hours) {
                    if (hours != null) {
                      setState(() => _weeklyAvailableHours = hours);
                    }
                  },
                ),
              ],
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
              widget.profile.copyWith(
                name: _nameController.text.trim(),
                institution: _institutionController.text.trim(),
                bio: _bioController.text.trim(),
                skills: _isStudentProfile ? _selectedSkills.toList() : null,
                interests: _isStudentProfile
                    ? _selectedInterests.toList()
                    : null,
                weeklyAvailableHours: _isStudentProfile
                    ? _weeklyAvailableHours
                    : null,
              ),
            );
          },
          child: const Text('Simpan profil'),
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

/// Avatar besar di kartu profil: foto bila ada, inisial bila belum, dengan
/// lencana kamera sebagai tanda bahwa foto dapat diganti.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    required this.initials,
    required this.onTap,
  });

  final String name;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = ProfilePhotoScope.maybeOf(context)?.photoFor(name);
    return Semantics(
      button: true,
      label: 'Ganti foto profil',
      child: GestureDetector(
        key: const Key('profile_avatar'),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    ProjectNexusColors.goldLight,
                    ProjectNexusColors.gold,
                  ],
                ),
                boxShadow: AppShadows.raised,
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                backgroundImage: photo == null ? null : MemoryImage(photo),
                child: photo != null
                    ? null
                    : Text(
                        initials,
                        style: const TextStyle(
                          color: ProjectNexusColors.tealDark,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: ProjectNexusColors.teal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sampul profil: latar gradien berornamen, foto profil besar yang menumpang
/// di tepi bawah, lalu nama dan peran di tengah.
class _ProfileCover extends StatelessWidget {
  const _ProfileCover({
    required this.profile,
    required this.avatar,
    required this.onEdit,
  });

  final ProfileData profile;
  final Widget avatar;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 52),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ProjectNexusColors.tealDeep,
                    ProjectNexusColors.tealDark,
                    Color(0xFF176B68),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppShadows.raised,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(left: -40, top: -60, child: _Ring(size: 170)),
                  Positioned(right: -30, bottom: -70, child: _Ring(size: 190)),
                  const Positioned(
                    left: 20,
                    top: 18,
                    child: Text(
                      'PROFIL PENGGUNA',
                      style: TextStyle(
                        color: Color(0xFFC9E9E2),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 8,
                    child: IconButton(
                      key: const Key('profile_edit'),
                      tooltip: 'Edit profil',
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            avatar,
          ],
        ),
        const SizedBox(height: 12),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ProjectNexusColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: ProjectNexusColors.goldSoft,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            profile.roleLabel,
            style: const TextStyle(
              color: Color(0xFF8A6512),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          profile.institution,
          textAlign: TextAlign.center,
          style: const TextStyle(color: ProjectNexusColors.muted, fontSize: 13),
        ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 22,
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats(this.stats);

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (final (i, stat) in stats.indexed) ...[
                if (i > 0) const VerticalDivider(indent: 6, endIndent: 6),
                Expanded(
                  child: Column(
                    children: [
                      Icon(stat.icon, size: 20, color: ProjectNexusColors.teal),
                      const SizedBox(height: 8),
                      Text(
                        '${stat.value}',
                        style: const TextStyle(
                          color: ProjectNexusColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ProjectNexusColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lencana yang sudah diraih berwarna emas; yang belum ditampilkan terkunci
/// beserta petunjuk cara meraihnya.
class _BadgeShowcase extends StatelessWidget {
  const _BadgeShowcase(this.badges);

  final List<ProfileBadge> badges;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final badge in badges)
              SizedBox(width: width, child: _BadgeTile(badge)),
          ],
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile(this.badge);

  final ProfileBadge badge;

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned ? ProjectNexusColors.goldSoft : ProjectNexusColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: earned
              ? ProjectNexusColors.goldLight
              : ProjectNexusColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: earned
                  ? const LinearGradient(
                      colors: [
                        ProjectNexusColors.goldLight,
                        ProjectNexusColors.gold,
                      ],
                    )
                  : null,
              color: earned ? null : const Color(0xFFE4E9E8),
            ),
            child: Icon(
              earned ? badge.icon : Icons.lock_outline_rounded,
              size: 19,
              color: earned ? Colors.white : ProjectNexusColors.muted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: earned
                        ? const Color(0xFF6E5210)
                        : ProjectNexusColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.hint,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProjectNexusColors.muted,
                    fontSize: 11,
                    height: 1.3,
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
