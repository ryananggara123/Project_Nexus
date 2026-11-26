import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';
import 'talent_profile.dart';

/// Siswa contoh dari berbagai bidang untuk mode lokal dan pengujian. Pada mode
/// cloud, direktori hanya berisi siswa sungguhan yang sudah membuka aplikasi.
const sampleTalents = [
  TalentProfile(
    name: 'Nadia Putri',
    bio: 'Suka meneliti lingkungan sekitar sekolah dan menari tradisional.',
    skills: ['Riset', 'Tari', 'Koreografi', 'IoT'],
    interests: ['Lingkungan', 'Seni & Pertunjukan'],
    weeklyHours: 5,
  ),
  TalentProfile(
    name: 'Rizky Ramadhan',
    bio: 'Penulis cerpen dan pencinta sejarah lokal Lampung.',
    skills: ['Penulis', 'Riset', 'Public Speaking'],
    interests: ['Sosial & Budaya', 'Bahasa & Debat'],
  ),
  TalentProfile(
    name: 'Siti Aminah',
    bio: 'Senang merancang tampilan aplikasi dan poster acara sekolah.',
    skills: ['UI/UX', 'Desain Grafis', 'Flutter'],
    interests: ['Desain & UI/UX', 'Teknologi'],
    weeklyHours: 5,
  ),
  TalentProfile(
    name: 'Dimas Pratama',
    bio: 'Kapten futsal kelas XI, juga fotografer dokumentasi OSIS.',
    skills: ['Futsal', 'Fotografi', 'Kepemimpinan'],
    interests: ['Olahraga'],
    weeklyHours: 8,
  ),
  TalentProfile(
    name: 'Aulia Rahma',
    bio: 'Anggota klub debat bahasa Inggris, suka berbicara di depan umum.',
    skills: ['Debat', 'Bahasa Inggris', 'Public Speaking'],
    interests: ['Bahasa & Debat', 'Pendidikan'],
    openToInvite: false,
  ),
];

/// Direktori Bakat: profil publik siswa beserta catatan ajakan yang sudah
/// dikirim dari perangkat ini.
class TalentStore extends ChangeNotifier with CloudSync {
  TalentStore({this.database}) {
    final stored = database?.readList(LocalDatabase.talentProfilesKey);
    _profiles.addAll(
      stored == null
          ? sampleTalents
          : decodeAll(stored, TalentProfile.tryFromJson),
    );
    for (final json
        in database?.readList(LocalDatabase.sentInvitesKey) ?? const []) {
      if (json['key'] case final String key) _sentInvites.add(key);
    }
  }

  static const collection = 'talent_profiles';

  final LocalDatabase? database;
  final List<TalentProfile> _profiles = [];
  final Set<String> _sentInvites = {};

  List<TalentProfile> get profiles => List.unmodifiable(_profiles);

  TalentProfile? byName(String name) {
    final id = TalentProfile.idFor(name);
    for (final profile in _profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  /// Siswa selain [me], urut nama. Bila [neededSkills] diisi, siswa dengan
  /// keahlian paling cocok ditaruh paling atas.
  List<TalentProfile> directoryFor(
    String me, {
    Iterable<String> neededSkills = const [],
  }) {
    final myId = TalentProfile.idFor(me);
    final others = [
      for (final profile in _profiles)
        if (profile.id != myId) profile,
    ];
    return others..sort((a, b) {
      final byMatch = b
          .matchingSkills(neededSkills)
          .length
          .compareTo(a.matchingSkills(neededSkills).length);
      if (byMatch != 0) return byMatch;
      if (a.openToInvite != b.openToInvite) return a.openToInvite ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  /// Menyimpan profil sendiri ke direktori. Tidak mengirim apa pun bila
  /// isinya sama dengan yang sudah tersimpan.
  void publish(TalentProfile profile) {
    final index = _profiles.indexWhere((item) => item.id == profile.id);
    if (index != -1 && _profiles[index].sameAs(profile)) return;
    if (index == -1) {
      _profiles.add(profile);
    } else {
      _profiles[index] = profile;
    }
    _changed();
    upload(collection, profile.id, profile.toJson());
  }

  static String _inviteKey(String projectId, String name) =>
      '$projectId|${TalentProfile.idFor(name)}';

  bool wasInvited(String projectId, String name) =>
      _sentInvites.contains(_inviteKey(projectId, name));

  /// Mencatat ajakan agar tombol tidak dapat ditekan dua kali.
  void markInvited(String projectId, String name) {
    if (!_sentInvites.add(_inviteKey(projectId, name))) return;
    notifyListeners();
    unawaited(
      database?.writeList(LocalDatabase.sentInvitesKey, [
        for (final key in _sentInvites) {'key': key},
      ]),
    );
  }

  int get invitesSent => _sentInvites.length;

  void startSync(CloudStore cloud) {
    beginSync(cloud);
    listenRemote(collection, (documents) {
      _profiles
        ..clear()
        ..addAll(decodeAll(documents, TalentProfile.tryFromJson));
      _changed();
    });
  }

  void _changed() {
    notifyListeners();
    unawaited(
      database?.writeList(LocalDatabase.talentProfilesKey, [
        for (final profile in _profiles) profile.toJson(),
      ]),
    );
  }
}
