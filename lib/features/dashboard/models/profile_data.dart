class ProfileData {
  const ProfileData({
    required this.name,
    required this.roleLabel,
    required this.institution,
    required this.email,
    required this.bio,
    required this.skills,
  });

  final String name;
  final String roleLabel;
  final String institution;
  final String email;
  final String bio;
  final List<String> skills;

  ProfileData copyWith({
    String? name,
    String? institution,
    String? bio,
  }) {
    return ProfileData(
      name: name ?? this.name,
      roleLabel: roleLabel,
      institution: institution ?? this.institution,
      email: email,
      bio: bio ?? this.bio,
      skills: skills,
    );
  }
}
