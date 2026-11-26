/// Profil publik seorang siswa di Direktori Bakat. Siswa lain dapat melihat
/// keahlian dan minatnya, lalu mengajaknya bergabung ke tim.
class TalentProfile {
  const TalentProfile({
    required this.name,
    required this.bio,
    required this.skills,
    this.interests = const [],
    this.weeklyHours = 3,
    this.openToInvite = true,
  });

  final String name;
  final String bio;
  final List<String> skills;
  final List<String> interests;
  final int weeklyHours;

  /// Bila `false`, siswa tetap tampil tetapi tidak dapat diajak bergabung.
  final bool openToInvite;

  /// ID dokumen dibentuk dari nama agar sama di semua perangkat.
  String get id => idFor(name);

  static String idFor(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');

  TalentProfile copyWith({bool? openToInvite}) => TalentProfile(
    name: name,
    bio: bio,
    skills: skills,
    interests: interests,
    weeklyHours: weeklyHours,
    openToInvite: openToInvite ?? this.openToInvite,
  );

  /// Keahlian siswa yang dibutuhkan [needed], tanpa membedakan huruf besar.
  List<String> matchingSkills(Iterable<String> needed) {
    final wanted = {for (final skill in needed) skill.trim().toLowerCase()};
    return [
      for (final skill in skills)
        if (wanted.contains(skill.trim().toLowerCase())) skill,
    ];
  }

  /// Apakah profil cocok dengan kata pencarian (nama, keahlian, atau minat).
  bool matchesQuery(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return true;
    return '$name ${skills.join(' ')} ${interests.join(' ')} $bio'
        .toLowerCase()
        .contains(text);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bio': bio,
    'skills': skills,
    'interests': interests,
    'weeklyHours': weeklyHours,
    'openToInvite': openToInvite,
  };

  bool sameAs(TalentProfile other) =>
      name == other.name &&
      bio == other.bio &&
      skills.join('|') == other.skills.join('|') &&
      interests.join('|') == other.interests.join('|') &&
      weeklyHours == other.weeklyHours &&
      openToInvite == other.openToInvite;

  static TalentProfile? tryFromJson(Map<String, dynamic> json) {
    try {
      return TalentProfile(
        name: json['name'] as String,
        bio: json['bio'] as String? ?? '',
        skills: List<String>.unmodifiable(json['skills'] as List),
        interests: List<String>.unmodifiable(
          json['interests'] as List? ?? const [],
        ),
        weeklyHours: json['weeklyHours'] as int? ?? 3,
        openToInvite: json['openToInvite'] as bool? ?? true,
      );
    } on TypeError {
      return null;
    }
  }
}
