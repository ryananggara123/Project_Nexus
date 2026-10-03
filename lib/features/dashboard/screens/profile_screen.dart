import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/profile_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.profile,
    required this.onProfileChanged,
    super.key,
  });

  final ProfileData profile;
  final ValueChanged<ProfileData> onProfileChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              sliver: SliverList.list(
                children: [
                  Text(
                    'AKUN & IDENTITAS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ProjectNexusColors.teal,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Profil',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ProjectNexusColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 17),
                  _buildHeader(context),
                  const SizedBox(height: 14),
                  _buildAboutCard(context),
                  const SizedBox(height: 14),
                  _buildSkillsCard(context),
                  const SizedBox(height: 14),
                  _buildContactCard(context),
                  const SizedBox(height: 15),
                  const Text(
                    'Profil contoh untuk pratinjau. Perubahan tersimpan selama aplikasi berjalan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 11,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102F35),
            ProjectNexusColors.tealDark,
            Color(0xFF176B68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ProjectNexusColors.tealDark.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_circle_outlined,
                color: Color(0xFFC9E9E2),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PROFIL PENGGUNA',
                  style: TextStyle(
                    color: Color(0xFFC9E9E2),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              IconButton(
                key: const Key('profile_edit'),
                tooltip: 'Edit profil',
                onPressed: () => _showEditDialog(context),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 37,
                  backgroundColor: const Color(0xFFE5F3F1),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      _initials(profile.name),
                      style: const TextStyle(
                        color: ProjectNexusColors.tealDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.roleLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD7E9E5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                color: Color(0xFFC9E9E2),
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  profile.institution,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return _ProfileSection(
      icon: Icons.person_outline_rounded,
      title: 'Tentang',
      child: Text(
        profile.bio,
        style: const TextStyle(
          color: ProjectNexusColors.muted,
          height: 1.55,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSkillsCard(BuildContext context) {
    return _ProfileSection(
      icon: Icons.auto_awesome_outlined,
      title: 'Keahlian',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: profile.skills
            .map(
              (skill) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: ProjectNexusColors.mint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: ProjectNexusColors.tealDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return _ProfileSection(
      icon: Icons.contact_mail_outlined,
      title: 'Informasi kontak',
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
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final editedProfile = await showDialog<ProfileData>(
      context: context,
      builder: (context) => _EditProfileDialog(profile: profile),
    );
    if (editedProfile != null) onProfileChanged(editedProfile);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: ProjectNexusColors.border),
        boxShadow: [
          BoxShadow(
            color: ProjectNexusColors.ink.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ProjectNexusColors.teal, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: ProjectNexusColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
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
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: ProjectNexusColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _institutionController = TextEditingController(
      text: widget.profile.institution,
    );
    _bioController = TextEditingController(text: widget.profile.bio);
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
