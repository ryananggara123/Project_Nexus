import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_nexus/core/storage/local_database.dart';
import 'package:project_nexus/features/auth/screens/auth_gate.dart';
import 'package:project_nexus/features/dashboard/models/portfolio_item.dart';
import 'package:project_nexus/features/dashboard/models/team_work_store.dart';
import 'package:project_nexus/features/dashboard/models/workspace_task.dart';
import 'package:project_nexus/main.dart';

const _karya = PortfolioItem(
  owner: 'Ryan Anggara Deki',
  title: 'Poster Lomba',
  category: 'Desain',
  description: 'Poster awal.',
  year: '2026',
  icon: Icons.design_services_outlined,
  color: Color(0xFF087E8B),
);

PortfolioItem _edited(String title) => PortfolioItem(
  owner: 'Ryan Anggara Deki',
  title: title,
  category: 'Desain Grafis',
  description: 'Poster revisi.',
  year: '2026',
  icon: Icons.auto_awesome_outlined,
  color: const Color(0xFF000000),
);

void main() {
  group('TeamWorkStore edit dan hapus', () {
    late LocalDatabase database;
    late TeamWorkStore store;

    setUp(() {
      database = LocalDatabase(MemoryKeyValueStore());
      store = TeamWorkStore(database: database);
    });

    test('task can be edited and deleted', () async {
      final task = store.tasksFor('sample-water-iot').first;
      store.updateTask(
        'sample-water-iot',
        task,
        WorkspaceTask(
          title: 'Riset parameter pH dan suhu air',
          assignee: task.assignee,
          dueLabel: task.dueLabel,
          status: task.status,
        ),
      );
      expect(
        store.tasksFor('sample-water-iot').first.title,
        'Riset parameter pH dan suhu air',
      );

      final count = store.tasksFor('sample-water-iot').length;
      store.removeTask(
        'sample-water-iot',
        store.tasksFor('sample-water-iot').first,
      );
      await store.saved;

      final reopened = TeamWorkStore(database: database);
      expect(reopened.tasksFor('sample-water-iot'), hasLength(count - 1));
      expect(
        reopened.tasksFor('sample-water-iot').map((task) => task.title),
        isNot(contains('Riset parameter pH dan suhu air')),
      );
    });

    test('editing keeps, replaces, or removes the photo', () async {
      final photo = Uint8List.fromList([1, 2, 3]);
      store.addPortfolioItem(_karya, image: photo);
      var item = store.portfolioItems.first;
      final firstImageId = item.imageId!;

      // Foto tidak diubah: ID foto tetap.
      store.updatePortfolioItem(
        item,
        _edited('Poster Revisi 1'),
        photo: store.imageFor(firstImageId),
      );
      item = store.portfolioItems.first;
      expect(item.title, 'Poster Revisi 1');
      expect(item.category, 'Desain Grafis');
      expect(item.imageId, firstImageId);
      expect(item.icon, Icons.design_services_outlined);

      // Foto diganti: foto lama dihapus dari database.
      final newPhoto = Uint8List.fromList([9, 9]);
      store.updatePortfolioItem(
        item,
        _edited('Poster Revisi 2'),
        photo: newPhoto,
      );
      item = store.portfolioItems.first;
      await store.saved;
      expect(item.imageId, isNot(firstImageId));
      expect(store.imageFor(item.imageId!), newPhoto);
      expect(
        database.readBytes(LocalDatabase.portfolioImageKey(firstImageId)),
        isNull,
      );

      // Foto dihapus.
      final secondImageId = item.imageId!;
      store.updatePortfolioItem(item, _edited('Poster Revisi 3'));
      await store.saved;
      expect(store.portfolioItems.first.imageId, isNull);
      expect(
        database.readBytes(LocalDatabase.portfolioImageKey(secondImageId)),
        isNull,
      );
    });

    test('deleting an item also deletes its photo', () async {
      store.addPortfolioItem(_karya, image: Uint8List.fromList([4, 5]));
      final item = store.portfolioItems.first;
      final imageId = item.imageId!;

      store.removePortfolioItem(item);
      await store.saved;

      expect(store.portfolioItems, isNot(contains(item)));
      expect(
        database.readBytes(LocalDatabase.portfolioImageKey(imageId)),
        isNull,
      );
      expect(
        TeamWorkStore(database: database).portfolioItems.map((i) => i.title),
        isNot(contains('Poster Lomba')),
      );
    });
  });

  group('tampilan edit dan hapus', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('student edits and deletes a portfolio item', (tester) async {
      _useTallPhone(tester);
      await _login(tester);
      await tester.tap(find.text('Portofolio'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('portfolio_menu_Aplikasi Jadwal Kelas')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit karya'));
      await tester.pumpAndSettle();
      expect(find.text('Edit karya'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('portfolio_item_title')),
        'Aplikasi Jadwal Kelas v2',
      );
      await tester.tap(find.text('Simpan perubahan'));
      await tester.pumpAndSettle();
      expect(find.text('Aplikasi Jadwal Kelas v2'), findsOneWidget);
      expect(find.text('Aplikasi Jadwal Kelas'), findsNothing);

      await tester.tap(
        find.byKey(const Key('portfolio_menu_Aplikasi Jadwal Kelas v2')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus karya'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus karya?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm_delete')));
      await tester.pumpAndSettle();
      expect(find.text('Aplikasi Jadwal Kelas v2'), findsNothing);
    });

    testWidgets('workspace task can be edited and deleted', (tester) async {
      _useTallPhone(tester);
      await _login(tester);
      await tester.tap(find.text('Workspace').last);
      await tester.pumpAndSettle();

      final menu = find.descendant(
        of: find.byKey(const Key('workspace_column_todo')),
        matching: find.byTooltip('Opsi tugas'),
      );
      await tester.ensureVisible(menu.first);
      await tester.tap(menu.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit tugas'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('workspace_task_title')),
        'Menghubungkan sensor pH ke aplikasi',
      );
      await tester.tap(find.text('Simpan perubahan'));
      await tester.pumpAndSettle();
      expect(find.text('Menghubungkan sensor pH ke aplikasi'), findsOneWidget);

      await tester.ensureVisible(menu.first);
      await tester.tap(menu.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus tugas'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_delete')));
      await tester.pumpAndSettle();
      expect(find.text('Menghubungkan sensor pH ke aplikasi'), findsNothing);
    });
  });
}

void _useTallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

Future<void> _login(WidgetTester tester) async {
  await tester.pumpWidget(
    ProjectNexusApp(database: LocalDatabase(MemoryKeyValueStore())),
  );
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
}
