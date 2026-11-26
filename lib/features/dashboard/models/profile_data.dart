class ProfileData {
  const ProfileData({
    required this.name,
    required this.roleLabel,
    required this.institution,
    required this.email,
    required this.bio,
    required this.skills,
    this.interests = const [],
    this.weeklyAvailableHours = 3,
  });

  final String name;
  final String roleLabel;
  final String institution;
  final String email;
  final String bio;
  final List<String> skills;
  final List<String> interests;
  final int weeklyAvailableHours;

  ProfileData copyWith({
    String? name,
    String? institution,
    String? bio,
    List<String>? skills,
    List<String>? interests,
    int? weeklyAvailableHours,
  }) {
    return ProfileData(
      name: name ?? this.name,
      roleLabel: roleLabel,
      institution: institution ?? this.institution,
      email: email,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      weeklyAvailableHours: weeklyAvailableHours ?? this.weeklyAvailableHours,
    );
  }
}

/// Minat untuk rekomendasi, mencakup semua jenis lomba dan proyek.
const availableStudentInterests = [
  'Teknologi',
  'Lingkungan',
  'Desain & UI/UX',
  'Riset',
  'Pendidikan',
  'Sosial & Budaya',
  'Seni & Pertunjukan',
  'Olahraga',
  'Sains & Olimpiade',
  'Bahasa & Debat',
  'Kewirausahaan',
];

const availableWeeklyHours = [1, 2, 3, 5, 8, 10];
