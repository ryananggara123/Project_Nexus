import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/profile_data.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/project_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.header,
    required this.profile,
    required this.onProfileChanged,
    super.key,
  });

  final Widget header;
  final ProfileData profile;
  final ValueChanged<ProfileData> onProfileChanged;

  bool get _isStudentProfile => profile.roleLabel.startsWith('Siswa');

  @override
  Widget build(BuildContext context) {
    return MenuPage(
      header: header,
      children: [
        HeroBanner(
          eyebrow: 'PROFIL PENGGUNA',
          title: profile.name,
          subtitle: profile.roleLabel,
          description: profile.institution,
          leading: CircleAvatar(
            radius: 34,
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
          trailing: IconButton(
            key: const Key('profile_edit'),
            tooltip: 'Edit profil',
            onPressed: () => _showEditDialog(context),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ProfileSection(
          title: 'Tentang',
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
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profile.skills.map(SkillTag.new).toList(),
          ),
        ),
        if (_isStudentProfile)
          _ProfileSection(
            title: 'Preferensi rekomendasi',
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
        _ProfileSection(
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
        ),
        const SizedBox(height: 4),
        const Text(
          'Profil contoh untuk pratinjau. Perubahan tersimpan selama aplikasi berjalan.',
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.child});

  final String title;
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
              Text(
                title,
                style: const TextStyle(
                  color: ProjectNexusColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
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
                Wrap(
                  spacing: 6,
                  runSpacing: 0,
                  children: availableStudentSkills.map((skill) {
                    return FilterChip(
                      key: Key('profile_skill_$skill'),
                      label: Text(skill),
                      selected: _selectedSkills.contains(skill),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSkills.add(skill);
                          } else {
                            _selectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
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
