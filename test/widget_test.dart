// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_nexus/main.dart';

void main() {
  testWidgets('login validates email and password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProjectNexusApp());

    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi minimal 6 karakter.'), findsOneWidget);
  });

  testWidgets('dashboard filters approved projects by skill', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester);

    expect(find.text('Rekrutmen terbuka'), findsOneWidget);
    expect(find.text('Aplikasi Pemantau Kualitas Air IoT'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Riset'));
    await tester.pumpAndSettle();

    expect(find.text('Peta Cerita Sejarah Lokal'), findsOneWidget);
    expect(find.text('Aplikasi Pemantau Kualitas Air IoT'), findsNothing);
  });

  testWidgets('dashboard shows school achievement catalog', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester);

    await tester.tap(find.text('Katalog prestasi'));
    await tester.pumpAndSettle();

    expect(find.text('Karya yang membanggakan'), findsOneWidget);
    expect(find.text('Inovasi Teknologi Lingkungan'), findsOneWidget);
  });

  testWidgets('student can submit a draft that stays out of public feed', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester);

    await tester.tap(find.text('Ajukan proyek'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('draft_project_title')),
      'Kebun Hidroponik Pintar',
    );
    await tester.enterText(
      find.byKey(const Key('draft_project_description')),
      'Mengembangkan sistem hidroponik otomatis untuk sekolah.',
    );
    await tester.ensureVisible(find.byKey(const Key('draft_project_teacher')));
    await tester.tap(find.byKey(const Key('draft_project_teacher')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Budi Santoso').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Kirim untuk ditinjau'));
    await tester.tap(find.text('Kirim untuk ditinjau'));
    await tester.pumpAndSettle();

    expect(
      find.text('Draf terkirim dan menunggu persetujuan guru.'),
      findsOneWidget,
    );
    expect(find.text('Kebun Hidroponik Pintar'), findsNothing);
  });

  testWidgets('teacher login opens assigned approval queue', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester, role: 'Guru');

    expect(find.text('Antrean persetujuan'), findsOneWidget);
    expect(find.text('1 draf menunggu tinjauan'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Draf Sistem Kebun Sekolah'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Draf Sistem Kebun Sekolah'), findsOneWidget);

    await tester.tap(find.text('Setujui (ACC)'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak ada draf yang menunggu persetujuan.'),
      findsOneWidget,
    );
  });

  testWidgets('logout returns to login page', (WidgetTester tester) async {
    await _loginAs(tester);

    await tester.tap(find.byTooltip('Keluar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });
}

Future<void> _loginAs(WidgetTester tester, {String role = 'Siswa'}) async {
  await tester.pumpWidget(const ProjectNexusApp());
  await tester.enterText(
    find.byKey(const Key('login_email')),
    'test@school.id',
  );
  await tester.enterText(
    find.byKey(const Key('login_password')),
    'password123',
  );
  if (role == 'Guru') {
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('login_role_selector')),
        matching: find.text('Guru'),
      ),
    );
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(find.byKey(const Key('login_submit')));
  await tester.tap(find.byKey(const Key('login_submit')));
  await tester.pumpAndSettle();
}
