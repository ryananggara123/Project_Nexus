import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/dashboard/data/dashboard_sample_data.dart';
import 'package:project_nexus/features/dashboard/models/portfolio_item.dart';
import 'package:project_nexus/features/dashboard/models/team_work_store.dart';

const _karya = PortfolioItem(
  owner: 'Ryan Anggara Deki',
  title: 'Robot Penyiram Tanaman',
  category: 'IoT',
  description: 'Penyiram otomatis berbasis sensor kelembapan.',
  year: '2026',
  icon: Icons.auto_awesome_outlined,
  color: Color(0xFF087E8B),
);

PortfolioItem _edited(String title) => PortfolioItem(
  owner: 'Ryan Anggara Deki',
  title: title,
  category: 'IoT',
  description: 'Versi dengan panel surya.',
  year: '2026',
  icon: Icons.auto_awesome_outlined,
  color: const Color(0xFF087E8B),
);

PortfolioItem _find(TeamWorkStore store, String title) =>
    store.portfolioItems.firstWhere((item) => item.title == title);

void main() {
  late MemoryCloudStore cloud;
  late TeamWorkStore ryanDevice;
  late TeamWorkStore otherDevice;
  late LocalDatabase otherDatabase;

  setUp(() async {
    cloud = MemoryCloudStore();
    ryanDevice = TeamWorkStore()..startSync(cloud);
    await pumpEventQueue();
    otherDatabase = LocalDatabase(MemoryKeyValueStore());
    otherDevice = TeamWorkStore(database: otherDatabase)..startSync(cloud);
    await pumpEventQueue();
  });

  tearDown(() {
    ryanDevice.dispose();
    otherDevice.dispose();
  });

  test('sample and legacy items get the same ID on every device', () {
    expect(
      PortfolioItem.idFor('Ryan Anggara Deki', 'Aplikasi Jadwal Kelas'),
      'ryan-anggara-deki__aplikasi-jadwal-kelas',
    );
    expect(
      cloud.documents(TeamWorkStore.portfolioItemsCollection),
      hasLength(samplePortfolioItems.length),
    );
    expect(
      otherDevice.portfolioItems.map((item) => item.id),
      ryanDevice.portfolioItems.map((item) => item.id),
    );
  });

  test('item and photo appear on another device', () async {
    final photo = Uint8List.fromList(List.filled(32, 7));
    ryanDevice.addPortfolioItem(_karya, image: photo);
    await pumpEventQueue();

    final received = _find(otherDevice, 'Robot Penyiram Tanaman');
    expect(received.id, startsWith('item-'));
    final photoDocument = cloud
        .documents(TeamWorkStore.portfolioPhotosCollection)
        .single;
    expect(photoDocument['owner'], 'Ryan Anggara Deki');

    // Foto diunduh saat pertama kali dibutuhkan lalu tampilan diberi tahu.
    var notified = false;
    otherDevice.addListener(() => notified = true);
    expect(otherDevice.imageFor(received.imageId!), isNull);
    await pumpEventQueue();
    expect(otherDevice.imageFor(received.imageId!), photo);
    expect(notified, isTrue);
    // Foto juga tersimpan di database lokal perangkat lain sebagai cache.
    expect(
      otherDatabase.readBytes(
        LocalDatabase.portfolioImageKey(received.imageId!),
      ),
      photo,
    );
  });

  test('editing and deleting reach other devices and the server', () async {
    ryanDevice.addPortfolioItem(_karya, image: Uint8List.fromList([1, 2, 3]));
    await pumpEventQueue();
    final original = _find(ryanDevice, 'Robot Penyiram Tanaman');

    ryanDevice.updatePortfolioItem(
      original,
      _edited('Robot Penyiram Tanaman v2'),
      photo: Uint8List.fromList([9, 9]),
    );
    await pumpEventQueue();
    final edited = _find(otherDevice, 'Robot Penyiram Tanaman v2');
    expect(edited.id, original.id);
    expect(edited.description, 'Versi dengan panel surya.');
    // Foto lama dihapus dari server, diganti foto baru.
    expect(
      cloud
          .documents(TeamWorkStore.portfolioPhotosCollection)
          .map((doc) => doc['id']),
      [edited.imageId],
    );

    ryanDevice.removePortfolioItem(
      _find(ryanDevice, 'Robot Penyiram Tanaman v2'),
    );
    await pumpEventQueue();
    expect(
      otherDevice.portfolioItems.map((item) => item.title),
      isNot(contains('Robot Penyiram Tanaman v2')),
    );
    expect(cloud.documents(TeamWorkStore.portfolioPhotosCollection), isEmpty);
  });
}
