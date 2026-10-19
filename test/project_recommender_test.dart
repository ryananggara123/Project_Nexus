import 'package:flutter_test/flutter_test.dart';
import 'package:project_nexus/features/dashboard/models/dashboard_models.dart';
import 'package:project_nexus/features/dashboard/models/profile_data.dart';
import 'package:project_nexus/features/dashboard/models/project_recommender.dart';

void main() {
  test('ranks projects by skills, interests, and available time', () {
    const profile = ProfileData(
      name: 'Dewi',
      roleLabel: 'Siswa',
      institution: 'SMA Nusantara',
      email: 'dewi@school.id',
      bio: 'Suka teknologi lingkungan.',
      skills: ['Flutter'],
      interests: ['Lingkungan'],
      weeklyAvailableHours: 2,
    );
    const bothMatch = ProjectListing(
      id: 'both-match',
      title: 'Aplikasi Kebun Hidroponik',
      leader: 'Nadia',
      event: 'Proyek sekolah',
      description: 'Pantau kelembapan tanah menggunakan Flutter.',
      skills: ['Flutter'],
      teacherName: 'Budi',
      statusAcc: 'approved',
      recruitmentOpen: true,
      weeklyHours: 2,
    );
    const skillMatch = ProjectListing(
      id: 'skill-match',
      title: 'Aplikasi Jadwal Kelas',
      leader: 'Rizky',
      event: 'Proyek sekolah',
      description: 'Aplikasi mobile untuk jadwal pelajaran.',
      skills: ['Flutter'],
      teacherName: 'Budi',
      statusAcc: 'approved',
      recruitmentOpen: true,
      weeklyHours: 2,
    );
    const timeMismatch = ProjectListing(
      id: 'time-mismatch',
      title: 'Aplikasi Pemantau Air',
      leader: 'Siti',
      event: 'Proyek sekolah',
      description: 'Pantau kualitas air dengan aplikasi Flutter.',
      skills: ['Flutter'],
      teacherName: 'Budi',
      statusAcc: 'approved',
      recruitmentOpen: true,
      weeklyHours: 8,
    );

    final recommendations = ProjectRecommender.rank(
      projects: const [skillMatch, timeMismatch, bothMatch],
      profile: profile,
    );

    expect(recommendations.map((recommendation) => recommendation.project.id), [
      'both-match',
      'time-mismatch',
      'skill-match',
    ]);
    expect(recommendations.first.score, 100);
    expect(recommendations.first.reason, contains('Keahlian: Flutter'));
    expect(recommendations.first.reason, contains('Minat: Lingkungan'));
    expect(recommendations[1].score, greaterThan(recommendations.last.score));
    expect(recommendations.last.reason, contains('Waktu sesuai'));
  });

  test('keeps every project available to explore, including low matches', () {
    const profile = ProfileData(
      name: 'Dewi',
      roleLabel: 'Siswa',
      institution: 'SMA Nusantara',
      email: 'dewi@school.id',
      bio: '',
      skills: [],
      interests: [],
      weeklyAvailableHours: 1,
    );
    const project = ProjectListing(
      id: 'explore',
      title: 'Peta Cerita Sejarah Lokal',
      leader: 'Rizky',
      event: 'Kompetisi Riset Pelajar',
      description: 'Kumpulkan cerita warga sekitar sekolah.',
      skills: ['Riset'],
      teacherName: 'Budi',
      statusAcc: 'approved',
      recruitmentOpen: true,
      weeklyHours: 5,
    );

    final recommendations = ProjectRecommender.rank(
      projects: const [project],
      profile: profile,
    );

    expect(recommendations, hasLength(1));
    expect(recommendations.single.project, project);
  });
}
