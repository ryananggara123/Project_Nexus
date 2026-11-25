import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_nexus/core/cloud/cloud_store.dart';
import 'package:project_nexus/core/media/photo_picker.dart';
import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/auth/screens/auth_gate.dart';
import 'package:project_nexus/features/dashboard/models/profile_photo_store.dart';
import 'package:project_nexus/main.dart';

/// PNG 1×1 piksel yang valid agar dapat ditampilkan sebagai gambar.
final _png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _FakePhotoPicker implements PhotoPicker {
  _FakePhotoPicker(this.photo);

  final Uint8List photo;

  @override
  Future<Uint8List?> pick(PhotoSource source) async => photo;
}

void main() {
  group('ProfilePhotoStore', () {
    test('photo is shared with other devices and can be removed', () async {
      final cloud = MemoryCloudStore();
      final mine = ProfilePhotoStore()..startSync(cloud);
      final otherDatabase = LocalDatabase(MemoryKeyValueStore());
      final other = ProfilePhotoStore(database: otherDatabase)
        ..startSync(cloud);
      addTearDown(mine.dispose);
      addTearDown(other.dispose);
      await pumpEventQueue();

      mine.setPhoto('Ryan Anggara Deki', _png);
      await pumpEventQueue();
      expect(cloud.documents(ProfilePhotoStore.collection).single, {
        'id': 'ryan-anggara-deki',
        'owner': 'Ryan Anggara Deki',
        'data': isA<String>(),
      });
      expect(other.photoFor('ryan anggara deki'), _png);
      // Foto juga tersimpan sebagai cache di perangkat lain.
      expect(
        ProfilePhotoStore(database: otherDatabase)
            .photoFor('Ryan Anggara Deki'),
        _png,
      );

      mine.removePhoto('Ryan Anggara Deki');
      await pumpEventQueue();
      expect(cloud.documents(ProfilePhotoStore.collection), isEmpty);
      expect(other.photoFor('Ryan Anggara Deki'), isNull);
    });
  });

  group('menu Profil', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));
    tearDown(() => PhotoPicker.instance = ImagePickerPhotoPicker());

    testWidgets('student uploads and removes a profile photo', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      PhotoPicker.instance = _FakePhotoPicker(_png);
      final database = LocalDatabase(MemoryKeyValueStore());

      await tester.pumpWidget(ProjectNexusApp(database: database));
      await tester.pump(AuthGate.splashDuration);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('login_email')),
        'test@school.id',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'password123',
      );
      await tester.ensureVisible(find.byKey(const Key('login_submit')));
      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profil').last);
      await tester.pumpAndSettle();

      ImageProvider? avatarImage() => tester
          .widget<CircleAvatar>(
            find.descendant(
              of: find.byKey(const Key('profile_avatar')),
              matching: find.byType(CircleAvatar),
            ),
          )
          .backgroundImage;
      expect(avatarImage(), isNull);

      await tester.tap(find.byKey(const Key('profile_avatar')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile_photo_remove')), findsNothing);
      await tester.tap(find.byKey(const Key('profile_photo_gallery')));
      await tester.pumpAndSettle();
      expect(find.text('Foto profil diperbarui.'), findsOneWidget);
      expect(avatarImage(), isA<MemoryImage>());
      // Foto tersimpan di database lokal dan tetap ada setelah aplikasi dibuka ulang.
      expect(
        ProfilePhotoStore(database: database).photoFor('Ryan Anggara Deki'),
        _png,
      );

      await tester.tap(find.byKey(const Key('profile_avatar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile_photo_remove')));
      await tester.pumpAndSettle();
      expect(find.text('Foto profil dihapus.'), findsOneWidget);
      expect(avatarImage(), isNull);
    });
  });
}
