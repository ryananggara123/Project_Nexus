import 'dashboard_models.dart';
import 'profile_data.dart';

class ProjectRecommendation {
  const ProjectRecommendation({
    required this.project,
    required this.score,
    required this.reason,
  });

  final ProjectListing project;
  final int score;
  final String reason;
}

class ProjectRecommender {
  const ProjectRecommender._();

  static const _interestKeywords = {
    'Teknologi': [
      'flutter',
      'iot',
      'aplikasi',
      'digital',
      'sistem',
      'teknologi',
      'basis data',
    ],
    'Lingkungan': [
      'air',
      'kebun',
      'kelembapan',
      'tanah',
      'lingkungan',
      'hidroponik',
    ],
    'Desain & UI/UX': [
      'ui/ux',
      'desain',
      'pengalaman',
      'antarmuka',
      'prototipe',
    ],
    'Riset': [
      'riset',
      'penelitian',
      'wawancarai',
      'wawancara',
      'kumpulkan',
      'kompetisi riset',
    ],
    'Pendidikan': ['sekolah', 'perpustakaan', 'buku', 'siswa', 'pelajar'],
    'Sosial & Budaya': ['sejarah', 'cerita', 'warga', 'budaya', 'komunitas'],
  };

  static List<ProjectRecommendation> rank({
    required Iterable<ProjectListing> projects,
    required ProfileData profile,
  }) {
    final ranked = projects
        .map((project) => _recommend(project, profile))
        .toList();
    final originalOrder = {
      for (var index = 0; index < ranked.length; index++)
        ranked[index].project.id: index,
    };
    ranked.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      return scoreOrder != 0
          ? scoreOrder
          : originalOrder[a.project.id]!.compareTo(
              originalOrder[b.project.id]!,
            );
    });
    return ranked;
  }

  static ProjectRecommendation _recommend(
    ProjectListing project,
    ProfileData profile,
  ) {
    final normalizedSkills = profile.skills.map(_normalize).toSet();
    final matchedSkills = project.skills
        .where((skill) => normalizedSkills.contains(_normalize(skill)))
        .toList();
    final projectText =
        '${project.title} ${project.event} ${project.description} ${project.skills.join(' ')}'
            .toLowerCase();
    final matchedInterests = profile.interests.where((interest) {
      final keywords = _interestKeywords[interest] ?? [interest.toLowerCase()];
      return keywords.any(projectText.contains);
    }).toList();

    var score = 0.0;
    if (project.skills.isNotEmpty && normalizedSkills.isNotEmpty) {
      score += matchedSkills.length / project.skills.length * 40;
    }
    if (profile.interests.isNotEmpty) {
      score += matchedInterests.length / profile.interests.length * 40;
    }
    final timeDifference = profile.weeklyAvailableHours - project.weeklyHours;
    score += timeDifference >= 0 ? 20 : (20 + timeDifference * 4).clamp(0, 20);

    final reasons = <String>[
      if (matchedSkills.isNotEmpty)
        'Keahlian: ${matchedSkills.take(2).join(', ')}',
      if (matchedInterests.isNotEmpty)
        'Minat: ${matchedInterests.take(2).join(', ')}',
      if (timeDifference >= 0) 'Waktu sesuai',
    ];

    return ProjectRecommendation(
      project: project,
      score: score.round(),
      reason: reasons.isEmpty
          ? 'Proyek tersedia untuk dijelajahi'
          : reasons.join(' · '),
    );
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}
