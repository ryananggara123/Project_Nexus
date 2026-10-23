import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/auth/screens/auth_gate.dart';
import 'package:project_nexus/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('data remains after the app is closed and opened again', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final database = LocalDatabase(MemoryKeyValueStore());

    await _openApp(tester, database);
    await _register(tester);
    await _login(tester, 'ryananggara', 'password123');
    await _submitProject(tester, 'Kebun Sekolah Pintar');
    await _addPortfolioItem(tester, 'Robot Penyiram Tanaman');

    // Tutup aplikasi sepenuhnya, lalu buka kembali dengan database yang sama.
    await tester.pumpWidget(const SizedBox());
    await _openApp(tester, database);

    // Akun hasil registrasi masih bisa dipakai, dan kata sandi salah ditolak.
    await _login(tester, 'ryananggara', 'salah123');
    expect(find.text('Kata sandi tidak sesuai.'), findsOneWidget);
    await _login(tester, 'ryananggara', 'password123');

    await tester.tap(find.text('Pengajuan saya'));
    await tester.pumpAndSettle();
    expect(find.text('Kebun Sekolah Pintar'), findsOneWidget);

    await tester.tap(find.text('Portofolio'));
    await tester.pumpAndSettle();
    expect(find.text('Robot Penyiram Tanaman'), findsOneWidget);
  });
}

Future<void> _openApp(WidgetTester tester, LocalDatabase database) async {
  await tester.pumpWidget(ProjectNexusApp(database: database));
  await tester.pump(AuthGate.splashDuration);
  await tester.pumpAndSettle();
}

Future<void> _register(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open_registration')));
  await tester.pumpAndSettle();
  final fields = {
    'registration_name': 'Ryan Anggara Deki',
    'registration_nim': '2413025074',
    'registration_username': 'ryananggara',
    'registration_email': 'ryan@school.id',
    'registration_password': 'password123',
    'registration_confirm_password': 'password123',
  };
  for (final MapEntry(:key, :value) in fields.entries) {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.enterText(find.byKey(Key(key)), value);
  }
  await tester.ensureVisible(find.byKey(const Key('registration_submit')));
  await tester.tap(find.byKey(const Key('registration_submit')));
  await tester.pumpAndSettle();
}

Future<void> _login(
  WidgetTester tester,
  String identifier,
  String password,
) async {
  await tester.enterText(find.byKey(const Key('login_email')), identifier);
  await tester.enterText(find.byKey(const Key('login_password')), password);
  await tester.ensureVisible(find.byKey(const Key('login_submit')));
  await tester.tap(find.byKey(const Key('login_submit')));
  await tester.pumpAndSettle();
}

Future<void> _submitProject(WidgetTester tester, String title) async {
  await tester.tap(find.text('Ajukan proyek'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('draft_project_title')), title);
  await tester.enterText(
    find.byKey(const Key('draft_project_description')),
    'Memantau kelembapan tanah kebun sekolah secara otomatis.',
  );
  await tester.enterText(
    find.byKey(const Key('draft_project_first_step')),
    'Catat tanaman yang sering layu.',
  );
  await tester.ensureVisible(find.byKey(const Key('draft_skill_Flutter')));
  await tester.tap(find.byKey(const Key('draft_skill_Flutter')));
  await tester.ensureVisible(find.byKey(const Key('draft_project_teacher')));
  await tester.tap(find.byKey(const Key('draft_project_teacher')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Budi Santoso').last);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Kirim untuk ditinjau'));
  await tester.tap(find.text('Kirim untuk ditinjau'));
  await tester.pumpAndSettle();
}

Future<void> _addPortfolioItem(WidgetTester tester, String title) async {
  await tester.tap(find.text('Portofolio'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('portfolio_add_item')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('portfolio_item_title')), title);
  await tester.enterText(
    find.byKey(const Key('portfolio_item_category')),
    'Robotika',
  );
  await tester.enterText(
    find.byKey(const Key('portfolio_item_description')),
    'Prototipe robot penyiram tanaman otomatis.',
  );
  await tester.tap(find.text('Simpan karya'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Beranda').last);
  await tester.pumpAndSettle();
}
