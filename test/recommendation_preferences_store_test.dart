import 'package:flutter_test/flutter_test.dart';
import 'package:project_nexus/features/dashboard/data/recommendation_preferences_store.dart';
import 'package:project_nexus/features/dashboard/models/profile_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saves and restores recommendation preferences per account', () async {
    SharedPreferences.setMockInitialValues({});
    const store = RecommendationPreferencesStore();
    const profile = ProfileData(
      name: 'Dewi Anggraini',
      roleLabel: 'Siswa',
      institution: 'SMA Nusantara',
      email: 'dewi@school.id',
      bio: 'Suka lingkungan.',
      skills: ['Riset', 'Flutter'],
      interests: ['Lingkungan', 'Pendidikan'],
      weeklyAvailableHours: 5,
    );

    await store.save(profile.email, profile);

    final restored = await store.load(profile.email);
    expect(restored?.skills, profile.skills);
    expect(restored?.interests, profile.interests);
    expect(restored?.weeklyAvailableHours, 5);
    expect(await store.load('other@school.id'), isNull);
  });

  test('rejects corrupt stored recommendation preferences', () async {
    SharedPreferences.setMockInitialValues({
      'project_nexus_recommendation_preferences_student%40school.id':
          '{"skills":[],"interests":[],"weeklyAvailableHours":4}',
    });
    const store = RecommendationPreferencesStore();

    expect(() => store.load('student@school.id'), throwsFormatException);
  });
}
