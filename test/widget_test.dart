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

  testWidgets('student workspace shows sample tasks and can add one', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester);

    await tester.tap(find.text('Workspace'));
    await tester.pumpAndSettle();

    expect(find.text('Aplikasi Pemantau Kualitas Air IoT'), findsOneWidget);
    expect(find.text('Papan tugas'), findsOneWidget);
    expect(find.text('Menyusun rancangan sensor IoT'), findsOneWidget);
    expect(find.text('To-Do'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('workspace_column_todo')),
        matching: find.text('Menghubungkan data sensor ke aplikasi'),
      ),
      findsOneWidget,
    );

    final taskMenu = find.byTooltip('Ubah status tugas').first;
    await tester.ensureVisible(taskMenu);
    await tester.tap(taskMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pindahkan ke In Progress'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('workspace_column_inProgress')),
        matching: find.text('Menghubungkan data sensor ke aplikasi'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Tambah tugas').last);
    await tester.tap(find.text('Tambah tugas').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('workspace_task_title')),
      'Menguji prototipe sensor',
    );
    await tester.tap(find.text('Simpan tugas'));
    await tester.pumpAndSettle();

    expect(find.text('Menguji prototipe sensor'), findsOneWidget);
  });

  testWidgets('teacher workspace shows the same team board', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester, role: 'Guru');

    await tester.tap(find.text('Workspace'));
    await tester.pumpAndSettle();

    expect(find.text('PANEL PEMBIMBING'), findsOneWidget);
    expect(find.text('Aplikasi Pemantau Kualitas Air IoT'), findsOneWidget);
    expect(find.text('Menyusun rancangan sensor IoT'), findsOneWidget);
  });

  testWidgets('student can view and add a portfolio item', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester);

    await tester.tap(find.text('Portofolio'));
    await tester.pumpAndSettle();
    expect(find.text('Karya saya'), findsOneWidget);
    expect(find.text('Aplikasi Jadwal Kelas'), findsOneWidget);
    expect(find.text('Inovasi Teknologi Lingkungan'), findsNothing);

    await tester.tap(find.byKey(const Key('portfolio_add_item')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('portfolio_item_title')),
      'Proyek Robotik',
    );
    await tester.enterText(
      find.byKey(const Key('portfolio_item_category')),
      'Robotika',
    );
    await tester.enterText(
      find.byKey(const Key('portfolio_item_description')),
      'Membuat prototipe robot penyiram tanaman otomatis.',
    );
    await tester.tap(find.text('Simpan karya'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek Robotik'), findsOneWidget);
  });

  testWidgets('teacher portfolio shows student work gallery', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester, role: 'Guru');

    await tester.tap(find.text('Portofolio'));
    await tester.pumpAndSettle();

    expect(find.text('Karya siswa'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Nadia Putri'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Nadia Putri'), findsOneWidget);
    expect(find.text('Inovasi Teknologi Lingkungan'), findsOneWidget);
    expect(find.byKey(const Key('portfolio_add_item')), findsNothing);
  });

  testWidgets('student can edit profile details', (WidgetTester tester) async {
    await _loginAs(tester);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Ryan Anggara Deki'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile_edit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile_name')), 'Ryan Deki');
    await tester.tap(find.text('Simpan profil'));
    await tester.pumpAndSettle();

    expect(find.text('Ryan Deki'), findsOneWidget);
  });

  testWidgets('teacher profile shows mentor information', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester, role: 'Guru');

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Guru Pendamping · Teknologi Informasi'), findsOneWidget);
    expect(find.text('Mentoring'), findsOneWidget);
  });

  testWidgets('student can apply to a project only once', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    await _loginAs(tester);

    final detailButton = find.widgetWithText(TextButton, 'Detail').first;
    await tester.tap(detailButton);
    await tester.pumpAndSettle();
    expect(find.text('Ajukan bergabung'), findsOneWidget);

    await tester.ensureVisible(find.text('Ajukan bergabung'));
    await tester.tap(find.text('Ajukan bergabung'));
    await tester.pumpAndSettle();
    expect(
      find.text('Pengajuan bergabung terkirim kepada ketua proyek.'),
      findsOneWidget,
    );

    await tester.ensureVisible(detailButton);
    await tester.tap(detailButton);
    await tester.pumpAndSettle();
    expect(find.text('Pengajuan terkirim'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
      isNull,
    );
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
