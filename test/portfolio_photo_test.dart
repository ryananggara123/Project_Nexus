import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_nexus/core/media/photo_picker.dart';
import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/auth/screens/auth_gate.dart';
import 'package:project_nexus/main.dart';

/// Gambar PNG 1×1 piksel yang valid.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

/// Pengganti kamera/galeri: mengembalikan foto yang sudah disiapkan.
class _FakePhotoPicker implements PhotoPicker {
  _FakePhotoPicker(this.photo);

  final Uint8List? photo;
  final requested = <PhotoSource>[];

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    requested.add(source);
    return photo;
  }
}

void main() {
  late PhotoPicker originalPicker;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    originalPicker = PhotoPicker.instance;
  });

  tearDown(() => PhotoPicker.instance = originalPicker);

  testWidgets('photo from the gallery is saved and remains after restart', (
    WidgetTester tester,
  ) async {
    _useTallPhone(tester);
    final picker = _FakePhotoPicker(_png);
    PhotoPicker.instance = picker;
    final database = LocalDatabase(MemoryKeyValueStore());

    await _openPortfolio(tester, database);
    await _fillItem(tester, 'Poster Lomba Inovasi');
    await tester.tap(find.byKey(const Key('portfolio_photo_gallery')));
    await tester.pumpAndSettle();

    expect(picker.requested, [PhotoSource.gallery]);
    expect(find.byKey(const Key('portfolio_photo_preview')), findsOneWidget);
    await tester.tap(find.text('Simpan karya'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('portfolio_image_Poster Lomba Inovasi')),
      findsOneWidget,
    );

    // Tutup aplikasi, buka kembali dengan database yang sama.
    await tester.pumpWidget(const SizedBox());
    await _openPortfolio(tester, database);
    expect(
      find.byKey(const Key('portfolio_image_Poster Lomba Inovasi')),
      findsOneWidget,
    );
  });

  testWidgets('photo larger than 2 MB is rejected', (
    WidgetTester tester,
  ) async {
    _useTallPhone(tester);
    PhotoPicker.instance = _FakePhotoPicker(
      Uint8List(PhotoPicker.maxBytes + 1),
    );

    await _openPortfolio(tester, LocalDatabase(MemoryKeyValueStore()));
    await tester.tap(find.byKey(const Key('portfolio_add_item')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('portfolio_photo_camera')));
    await tester.pumpAndSettle();

    expect(find.text('Ukuran foto maksimal 2 MB.'), findsOneWidget);
    expect(find.byKey(const Key('portfolio_photo_preview')), findsNothing);
  });

  testWidgets('chosen photo can be removed before saving', (
    WidgetTester tester,
  ) async {
    _useTallPhone(tester);
    PhotoPicker.instance = _FakePhotoPicker(_png);

    await _openPortfolio(tester, LocalDatabase(MemoryKeyValueStore()));
    await _fillItem(tester, 'Esai Lingkungan');
    await tester.tap(find.byKey(const Key('portfolio_photo_gallery')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('portfolio_photo_remove')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan karya'));
    await tester.pumpAndSettle();

    expect(find.text('Esai Lingkungan'), findsOneWidget);
    expect(
      find.byKey(const Key('portfolio_image_Esai Lingkungan')),
      findsNothing,
    );
  });
}

void _useTallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

Future<void> _openPortfolio(WidgetTester tester, LocalDatabase database) async {
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
  await tester.tap(find.text('Portofolio'));
  await tester.pumpAndSettle();
}

Future<void> _fillItem(WidgetTester tester, String title) async {
  await tester.tap(find.byKey(const Key('portfolio_add_item')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('portfolio_item_title')), title);
  await tester.enterText(
    find.byKey(const Key('portfolio_item_category')),
    'Desain',
  );
  await tester.enterText(
    find.byKey(const Key('portfolio_item_description')),
    'Karya yang dibuat untuk kegiatan sekolah.',
  );
}
