import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';
import 'competition.dart';

/// Lomba contoh dari berbagai bidang, bukan hanya teknologi.
final sampleCompetitions = [
  Competition(
    id: 'sample-fls2n-tari',
    title: 'FLS2N Tari Kreasi',
    organizer: 'Dinas Pendidikan Kota Bandar Lampung',
    field: 'Seni & Budaya',
    level: CompetitionLevel.city,
    deadline: DateTime(2026, 12, 12),
    description:
        'Festival Lomba Seni Siswa Nasional cabang tari kreasi berkelompok '
        '(3–5 penari). Mengangkat tema budaya daerah Lampung.',
    prize: 'Piala, sertifikat, dan uang pembinaan',
    postedBy: 'Siti Rahmawati',
  ),
  Competition(
    id: 'sample-o2sn-futsal',
    title: 'Turnamen Futsal Antarsekolah',
    organizer: 'KONI Kota Bandar Lampung',
    field: 'Olahraga',
    level: CompetitionLevel.city,
    deadline: DateTime(2027, 1, 8),
    description:
        'Turnamen futsal putra dan putri tingkat SMA. Setiap sekolah '
        'mengirim satu tim berisi 8–12 pemain.',
    prize: 'Trofi dan uang pembinaan Rp5.000.000',
    postedBy: 'Budi Santoso',
  ),
  Competition(
    id: 'sample-lkti',
    title: 'Lomba Karya Tulis Ilmiah Remaja',
    organizer: 'Universitas Lampung',
    field: 'Sains',
    level: CompetitionLevel.province,
    deadline: DateTime(2027, 1, 20),
    description:
        'Tulis gagasan ilmiah untuk masalah lingkungan di sekitar sekolah. '
        'Tim berisi 2–3 siswa dengan satu guru pembimbing.',
    prize: 'Beasiswa dan sertifikat',
    postedBy: 'Budi Santoso',
  ),
  Competition(
    id: 'sample-debat',
    title: 'Lomba Debat Bahasa Indonesia',
    organizer: 'Balai Bahasa Provinsi Lampung',
    field: 'Bahasa & Debat',
    level: CompetitionLevel.province,
    deadline: DateTime(2027, 2, 5),
    description:
        'Debat beregu (3 orang) dengan mosi seputar pendidikan dan teknologi.',
    prize: 'Piala Gubernur',
    postedBy: 'Siti Rahmawati',
  ),
  Competition(
    id: 'sample-inovasi-digital',
    title: 'Lomba Inovasi Digital Pelajar',
    organizer: 'Kementerian Pendidikan',
    field: 'Teknologi',
    level: CompetitionLevel.national,
    deadline: DateTime(2027, 3, 1),
    description:
        'Kembangkan aplikasi atau perangkat yang membantu sekolah. Tim lintas '
        'keahlian: pemrogram, desainer, dan peneliti.',
    prize: 'Total hadiah Rp50.000.000',
    postedBy: 'Budi Santoso',
  ),
];

/// Papan Info Lomba. Lomba disimpan di database lokal dan, bila tersambung,
/// di koleksi `competitions` sehingga lomba yang dipasang guru langsung
/// terlihat oleh semua siswa.
class CompetitionStore extends ChangeNotifier with CloudSync {
  CompetitionStore({this.database}) {
    final stored = database?.readList(LocalDatabase.competitionsKey);
    _items.addAll(
      stored == null
          ? sampleCompetitions
          : decodeAll(stored, Competition.tryFromJson),
    );
  }

  static const collection = 'competitions';

  final LocalDatabase? database;
  final List<Competition> _items = [];

  /// Lomba diurutkan dari tenggat terdekat.
  List<Competition> get competitions =>
      [..._items]..sort((a, b) => a.deadline.compareTo(b.deadline));

  Competition? byId(String? id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void save(Competition competition) {
    final index = _items.indexWhere((item) => item.id == competition.id);
    if (index == -1) {
      _items.add(competition);
    } else {
      _items[index] = competition;
    }
    _changed();
    upload(collection, competition.id, competition.toJson());
  }

  void remove(Competition competition) {
    _items.removeWhere((item) => item.id == competition.id);
    _changed();
    removeRemote(collection, competition.id);
  }

  void startSync(CloudStore cloud) {
    beginSync(cloud);
    listenRemote(collection, (documents) {
      if (documents.isEmpty) {
        // Server masih kosong: lomba di perangkat ini menjadi data awal.
        // Aturan keamanan hanya menerima unggahan dari akun guru.
        for (final item in _items) {
          upload(collection, item.id, item.toJson());
        }
        return;
      }
      final merged = mergeById(
        _items,
        decodeAll(documents, Competition.tryFromJson),
        (item) => item.id,
      );
      _items
        ..clear()
        ..addAll(merged);
      _changed();
    });
  }

  void _changed() {
    notifyListeners();
    unawaited(
      database?.writeList(LocalDatabase.competitionsKey, [
        for (final item in _items) item.toJson(),
      ]),
    );
  }
}
