import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_data.dart';

class RecommendationPreferences {
  const RecommendationPreferences({
    required this.skills,
    required this.interests,
    required this.weeklyAvailableHours,
  });

  final List<String> skills;
  final List<String> interests;
  final int weeklyAvailableHours;
}

class RecommendationPreferencesStore {
  const RecommendationPreferencesStore();

  static const _keyPrefix = 'project_nexus_recommendation_preferences_';

  Future<RecommendationPreferences?> load(String accountId) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_keyFor(accountId));
    if (stored == null) return null;

    final decoded = jsonDecode(stored);
    if (decoded is! Map<String, dynamic> ||
        decoded['skills'] is! List ||
        decoded['interests'] is! List ||
        decoded['weeklyAvailableHours'] is! int) {
      throw const FormatException(
        'Preferensi rekomendasi yang tersimpan memiliki format tidak valid.',
      );
    }

    final rawSkills = decoded['skills'] as List;
    final rawInterests = decoded['interests'] as List;
    if (rawSkills.any((skill) => skill is! String) ||
        rawInterests.any((interest) => interest is! String)) {
      throw const FormatException(
        'Keahlian atau minat tersimpan memiliki format tidak valid.',
      );
    }
    final skills = rawSkills.cast<String>();
    final interests = rawInterests.cast<String>();
    final weeklyHours = decoded['weeklyAvailableHours'] as int;
    if (!availableWeeklyHours.contains(weeklyHours)) {
      throw const FormatException(
        'Pilihan waktu luang yang tersimpan tidak didukung.',
      );
    }

    return RecommendationPreferences(
      skills: skills,
      interests: interests,
      weeklyAvailableHours: weeklyHours,
    );
  }

  Future<void> save(String accountId, ProfileData profile) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = jsonEncode({
      'skills': profile.skills,
      'interests': profile.interests,
      'weeklyAvailableHours': profile.weeklyAvailableHours,
    });
    final saved = await preferences.setString(_keyFor(accountId), stored);
    if (!saved) {
      throw StateError('Preferensi rekomendasi gagal disimpan.');
    }
  }

  String _keyFor(String accountId) =>
      '$_keyPrefix${Uri.encodeComponent(accountId.trim().toLowerCase())}';
}
