// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_nexus/features/auth/screens/auth_gate.dart';
import 'package:project_nexus/main.dart';

void main() {
  testWidgets('splash shows app branding before login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProjectNexusApp());

    expect(find.text('ProjectNexus'), findsOneWidget);
    expect(find.text('SATU TIM, BANYAK IDE'), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsNothing);

    await tester.pump(AuthGate.splashDuration);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    expect(find.text('ProjectNexus'), findsNothing);
  });

  testWidgets('login screen adapts to wide screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProjectNexusApp());
    await tester.pump(AuthGate.splashDuration);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali!'), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login screen fits a mobile viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProjectNexusApp());
    await tester.pump(AuthGate.splashDuration);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali!'), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login validates email and password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProjectNexusApp());
    await tester.pump(AuthGate.splashDuration);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan email, NIM, atau username.'), findsOneWidget);
    expect(find.text('Kata sandi minimal 6 karakter.'), findsOneWidget);
  });

  testWidgets('student can register and log in with username or NIM', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProjectNexusApp());
    await tester.pump(AuthGate.splashDuration);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('open_registration')));
    await tester.tap(find.byKey(const Key('open_registration')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('registration_name')));
    await tester.enterText(
      find.byKey(const Key('registration_name')),
      'Dewi Anggraini',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_nim')));
    await tester.enterText(
      find.byKey(const Key('registration_nim')),
      '2413025074',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_username')));
    await tester.enterText(
      find.byKey(const Key('registration_username')),
      'dewi.anggraini',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_email')));
    await tester.enterText(
      find.byKey(const Key('registration_email')),
      'dewi@school.id',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_password')));
    await tester.enterText(
      find.byKey(const Key('registration_password')),
      'password123',
    );
    await tester.ensureVisible(
      find.byKey(const Key('registration_confirm_password')),
    );
    await tester.enterText(
      find.byKey(const Key('registration_confirm_password')),
      'password123',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      find.text('Akun berhasil dibuat. Masuk menggunakan NIM atau username.'),
      findsOneWidget,
    );
    expect(find.text('2413025074'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'dewi.anggraini',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'wrongpass',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login_email')))
          .controller!
          .text,
      'dewi.anggraini',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login_password')))
          .controller!
          .text,
      'wrongpass',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    expect(find.text('Kata sandi tidak sesuai.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login_password')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_submit')), findsNothing);
    final navigationBar = tester.getRect(find.byType(NavigationBar));
    await tester.tapAt(
      Offset(
        navigationBar.left + navigationBar.width * 0.875,
        navigationBar.center.dy,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dewi Anggraini'), findsOneWidget);
    await tester.tap(find.text('Workspace'));
    await tester.pumpAndSettle();
    expect(find.text('Workspace belum tersedia'), findsOneWidget);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    await tester.tapAt(
      Offset(
        navigationBar.left + navigationBar.width * 0.125,
        navigationBar.center.dy,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Keluar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('login_email')), '2413025074');
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    final secondNavigationBar = tester.getRect(find.byType(NavigationBar));
    await tester.tapAt(
      Offset(
        secondNavigationBar.left + secondNavigationBar.width * 0.875,
        secondNavigationBar.center.dy,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dewi Anggraini'), findsOneWidget);
  });

  testWidgets('dashboard filters approved projects by skill', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester);

    await tester.scrollUntilVisible(
      find.text('Rekrutmen terbuka'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Rekrutmen terbuka'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Aplikasi Pemantau Kualitas Air IoT'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Aplikasi Pemantau Kualitas Air IoT'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Riset'));
    await tester.tap(find.widgetWithText(FilterChip, 'Riset'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Peta Cerita Sejarah Lokal'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
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
    await tester.scrollUntilVisible(
      find.text('Inovasi Teknologi Lingkungan'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Inovasi Teknologi Lingkungan'), findsOneWidget);
  });

  testWidgets('student workspace shows sample tasks and can add one', (
    WidgetTester tester,
  ) async {
    await _loginAs(tester);

    await tester.tap(find.text('Workspace'));
    await tester.pumpAndSettle();

    expect(find.text('Aplikasi Pemantau Kualitas Air IoT'), findsNWidgets(2));
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
    expect(find.text('Aplikasi Pemantau Kualitas Air IoT'), findsNWidgets(3));
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

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -460),
    );
    await tester.pumpAndSettle();
    final libraryProject = find.ancestor(
      of: find.text('Sistem Informasi Perpustakaan'),
      matching: find.byType(Card),
    );
    final libraryDetailButton = find.descendant(
      of: libraryProject,
      matching: find.widgetWithText(TextButton, 'Detail'),
    );
    await tester.ensureVisible(libraryDetailButton);
    await tester.tap(libraryDetailButton);
    await tester.pumpAndSettle();
    expect(find.text('Ajukan bergabung'), findsOneWidget);
    await tester.tap(find.text('Ajukan bergabung'));
    await tester.pumpAndSettle();
    expect(
      find.text('Lamaran telah dikirim kepada ketua proyek.'),
      findsOneWidget,
    );

    await tester.tap(libraryDetailButton);
    await tester.pumpAndSettle();
    expect(find.text('Menunggu'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('apply_sample-library')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lamaran saya'));
    await tester.tap(find.text('Lamaran saya'));
    await tester.pumpAndSettle();
    expect(find.text('Sistem Informasi Perpustakaan'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
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
    await tester.ensureVisible(find.text('Kirim untuk ditinjau'));
    await tester.tap(find.text('Kirim untuk ditinjau'));
    await tester.pumpAndSettle();
    expect(
      find.text('Pilih minimal satu keahlian yang dibutuhkan.'),
      findsOneWidget,
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

    final approveButton = find.widgetWithText(FilledButton, 'Setujui (ACC)');
    await tester.scrollUntilVisible(
      approveButton,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -160),
    );
    await tester.pumpAndSettle();
    await tester.tap(approveButton);
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak ada draf yang menunggu persetujuan.'),
      findsOneWidget,
    );
  });

  testWidgets('student submission appears in teacher queue and approved feed', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _loginAs(tester);
    await _submitProject(tester, 'Aplikasi Bank Sampah Pintar');

    expect(
      find.text('Draf terkirim dan menunggu persetujuan guru.'),
      findsOneWidget,
    );
    expect(find.text('Aplikasi Bank Sampah Pintar'), findsNothing);

    await _switchAccount(tester, role: 'Guru');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Aplikasi Bank Sampah Pintar'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Diajukan oleh: Ryan Anggara Deki'), findsOneWidget);
    final approveButton = find
        .widgetWithText(FilledButton, 'Setujui (ACC)')
        .first;
    await tester.scrollUntilVisible(
      approveButton,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();
    await tester.tap(approveButton);
    await tester.pumpAndSettle();
    expect(find.text('Proyek disetujui dan sudah masuk feed.'), findsOneWidget);

    await _switchAccount(tester);
    await tester.tap(find.text('Pengajuan saya'));
    await tester.pumpAndSettle();
    expect(find.text('Disetujui'), findsOneWidget);
    final manageApplicants = find.text('Kelola pelamar (rekrutmen terbuka)');
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(manageApplicants);
    await tester.tap(manageApplicants);
    await tester.pumpAndSettle();
    expect(
      find.text('Belum ada pelamar yang menunggu keputusan.'),
      findsOneWidget,
    );
    expect(find.text('1 anggota termasuk ketua'), findsOneWidget);
    await tester.tap(find.text('Tutup').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Feed proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Aplikasi Bank Sampah Pintar'), findsOneWidget);
  });

  testWidgets('student revises rejected project and resubmits for review', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _loginAs(tester);
    await _submitProject(
      tester,
      'Aplikasi Hemat Energi Sekolah',
      teacher: 'Siti Rahmawati',
    );

    await _switchAccount(
      tester,
      role: 'Guru',
      teacherEmail: 'siti.rahmawati@school.id',
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Aplikasi Hemat Energi Sekolah'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final rejectButton = find.widgetWithText(OutlinedButton, 'Tolak').first;
    await tester.scrollUntilVisible(
      rejectButton,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(rejectButton);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('rejection_note')),
      'Tambahkan rencana pengukuran penghematan energi.',
    );
    await tester.tap(find.byKey(const Key('confirm_project_rejection')));
    await tester.pumpAndSettle();
    expect(
      find.text('Pengajuan ditolak dan siswa diberi tahu.'),
      findsOneWidget,
    );

    await _switchAccount(tester);
    await tester.tap(find.text('Pengajuan saya'));
    await tester.pumpAndSettle();
    expect(find.text('Perlu diperbaiki'), findsOneWidget);
    expect(
      find.text(
        'Masukan guru: Tambahkan rencana pengukuran penghematan energi.',
      ),
      findsOneWidget,
    );
    final reviseButton = find.byKey(
      const Key('revise_submission_Aplikasi Hemat Energi Sekolah'),
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(reviseButton);
    await tester.tap(reviseButton);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('draft_project_title')))
          .controller!
          .text,
      'Aplikasi Hemat Energi Sekolah',
    );
    await tester.enterText(
      find.byKey(const Key('draft_project_description')),
      'Mengukur konsumsi listrik sebelum dan sesudah program hemat energi.',
    );
    await tester.ensureVisible(find.text('Kirim ulang untuk ditinjau'));
    await tester.tap(find.text('Kirim ulang untuk ditinjau'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('draft_project_title')), findsNothing);
    expect(find.text('Menunggu tinjauan'), findsOneWidget);
    expect(
      find.text(
        'Masukan guru: Tambahkan rencana pengukuran penghematan energi.',
      ),
      findsNothing,
    );

    await _switchAccount(
      tester,
      role: 'Guru',
      teacherEmail: 'siti.rahmawati@school.id',
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Setujui (ACC)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final approveButton = find.widgetWithText(FilledButton, 'Setujui (ACC)');
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    await tester.tap(approveButton);
    await tester.pumpAndSettle();

    await _switchAccount(tester);
    await tester.tap(find.text('Pengajuan saya'));
    await tester.pumpAndSettle();
    expect(find.text('Disetujui'), findsOneWidget);
  });

  testWidgets('accepted applicant gets access to project workspace', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _registerAndLoginAs(
      tester,
      name: 'Ryan Anggara Deki',
      nim: '2413025001',
      username: 'ryan.angg',
      email: 'test@school.id',
    );
    await _submitProject(tester, 'Proyek Kolaborasi Siswa');

    await _switchAccount(tester, role: 'Guru');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Proyek Kolaborasi Siswa'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    final approveButton = find
        .widgetWithText(FilledButton, 'Setujui (ACC)')
        .first;
    await tester.scrollUntilVisible(
      approveButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(approveButton);
    await tester.tap(approveButton);
    await tester.pumpAndSettle();
    expect(find.text('Proyek disetujui dan sudah masuk feed.'), findsOneWidget);

    await _switchAccount(tester);
    await tester.ensureVisible(find.text('Pengajuan saya'));
    await tester.tap(find.text('Pengajuan saya'));
    await tester.pumpAndSettle();
    final manageApplicants = find.text('Kelola pelamar (rekrutmen terbuka)');
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(manageApplicants);
    await tester.tap(manageApplicants);
    await tester.pumpAndSettle();
    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('recruitment_open_toggle')),
    );
    await tester.tap(find.byKey(const Key('recruitment_open_toggle')));
    await tester.pumpAndSettle();
    expect(toggle.value, isTrue);
    expect(find.text('Pengajuan baru ditutup.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('recruitment_open_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Siswa dapat mengajukan diri.'), findsOneWidget);
    await tester.tap(find.text('Tutup').last);
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Keluar'));
    await tester.tap(find.byTooltip('Keluar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    tester.view.physicalSize = const Size(390, 1100);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('login_role_selector')),
        matching: find.text('Siswa'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('open_registration')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('open_registration')));
    await tester.tap(find.byKey(const Key('open_registration')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('registration_name')));
    await tester.enterText(
      find.byKey(const Key('registration_name')),
      'Dewi Anggraini',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_nim')));
    await tester.enterText(
      find.byKey(const Key('registration_nim')),
      '2413025099',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_username')));
    await tester.enterText(
      find.byKey(const Key('registration_username')),
      'dewi.angg',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_email')));
    await tester.enterText(
      find.byKey(const Key('registration_email')),
      'dewi.angg@school.id',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_password')));
    await tester.enterText(
      find.byKey(const Key('registration_password')),
      'password123',
    );
    await tester.ensureVisible(
      find.byKey(const Key('registration_confirm_password')),
    );
    await tester.enterText(
      find.byKey(const Key('registration_confirm_password')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('registration_submit')));
    await tester.tap(find.byKey(const Key('registration_submit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Dewi'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Proyek Kolaborasi Siswa'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    final projectCard = find.ancestor(
      of: find.text('Proyek Kolaborasi Siswa'),
      matching: find.byType(Card),
    );
    final projectDetail = find.descendant(
      of: projectCard,
      matching: find.widgetWithText(TextButton, 'Detail'),
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -340),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(projectDetail);
    await tester.tap(projectDetail);
    await tester.pumpAndSettle();
    expect(find.text('Proyek Kolaborasi Siswa'), findsNWidgets(2));
    await tester.tap(find.text('Ajukan bergabung'));
    await tester.pumpAndSettle();

    await _switchAccount(tester);
    await tester.ensureVisible(find.text('Pengajuan saya'));
    await tester.tap(find.text('Pengajuan saya'));
    await tester.pumpAndSettle();
    final projectApplications = find.text('Kelola pelamar (rekrutmen terbuka)');
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(projectApplications);
    await tester.tap(projectApplications);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('accept_Dewi Anggraini')));
    await tester.tap(find.byKey(const Key('accept_Dewi Anggraini')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tutup').last);
    await tester.pumpAndSettle();

    await _switchAccount(tester, studentEmail: 'dewi.angg@school.id');
    await tester.ensureVisible(find.text('Lamaran saya'));
    await tester.tap(find.text('Lamaran saya'));
    await tester.pumpAndSettle();
    expect(find.text('Diterima'), findsWidgets);
    await tester.tap(find.byKey(const Key('open_application_workspace')));
    await tester.pumpAndSettle();
    expect(find.text('Proyek Kolaborasi Siswa'), findsOneWidget);
    expect(find.text('Workspace belum tersedia'), findsNothing);
  });

  testWidgets('logout returns to login page', (WidgetTester tester) async {
    await _loginAs(tester);

    await tester.tap(find.byTooltip('Keluar'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });
}

Future<void> _registerAndLoginAs(
  WidgetTester tester, {
  required String name,
  required String nim,
  required String username,
  required String email,
  String password = 'password123',
}) async {
  await tester.pumpWidget(const ProjectNexusApp());
  await tester.pump(AuthGate.splashDuration);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('open_registration')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('registration_name')), name);
  await tester.enterText(find.byKey(const Key('registration_nim')), nim);
  await tester.enterText(
    find.byKey(const Key('registration_username')),
    username,
  );
  await tester.enterText(find.byKey(const Key('registration_email')), email);
  await tester.enterText(
    find.byKey(const Key('registration_password')),
    password,
  );
  await tester.enterText(
    find.byKey(const Key('registration_confirm_password')),
    password,
  );
  await tester.ensureVisible(find.byKey(const Key('registration_submit')));
  await tester.tap(find.byKey(const Key('registration_submit')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('login_password')), password);
  await tester.tap(find.byKey(const Key('login_submit')));
  await tester.pumpAndSettle();
}

Future<void> _loginAs(
  WidgetTester tester, {
  String role = 'Siswa',
  String email = 'test@school.id',
}) async {
  await tester.pumpWidget(const ProjectNexusApp());
  await tester.pump(AuthGate.splashDuration);
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('login_email')), email);
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

Future<void> _switchAccount(
  WidgetTester tester, {
  String role = 'Siswa',
  String teacherEmail = 'budi.santoso@school.id',
  String studentEmail = 'test@school.id',
}) async {
  await tester.drag(find.byType(CustomScrollView).first, const Offset(0, 1000));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byTooltip('Keluar'));
  await tester.tap(find.byTooltip('Keluar'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('login_email')),
    role == 'Guru' ? teacherEmail : studentEmail,
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

Future<void> _submitProject(
  WidgetTester tester,
  String title, {
  String teacher = 'Budi Santoso',
}) async {
  await tester.tap(find.text('Ajukan proyek'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('draft_project_title')), title);
  await tester.enterText(
    find.byKey(const Key('draft_project_description')),
    'Mengembangkan solusi yang bermanfaat bagi lingkungan sekolah.',
  );
  await tester.ensureVisible(find.byKey(const Key('draft_skill_Flutter')));
  await tester.tap(find.byKey(const Key('draft_skill_Flutter')));
  await tester.ensureVisible(find.byKey(const Key('draft_project_teacher')));
  await tester.tap(find.byKey(const Key('draft_project_teacher')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(teacher).last);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Kirim untuk ditinjau'));
  await tester.tap(find.text('Kirim untuk ditinjau'));
  await tester.pumpAndSettle();
}
