import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_nexus/features/dashboard/models/dashboard_models.dart';
import 'package:project_nexus/features/dashboard/models/profile_data.dart';
import 'package:project_nexus/features/dashboard/models/project_recommender.dart';
import 'package:project_nexus/features/dashboard/widgets/project_card.dart';
import 'package:project_nexus/features/dashboard/widgets/skill_picker.dart';

ProjectListing _project(String id, String title, List<String> skills) =>
    ProjectListing(
      id: id,
      title: title,
      leader: 'Nadia Putri',
      event: 'Lomba antarsekolah',
      description: 'Deskripsi $title.',
      skills: skills,
      teacherName: 'Budi Santoso',
      statusAcc: 'approved',
      recruitmentOpen: true,
    );

void main() {
  test('project icons cover non-IT competitions', () {
    expect(
      projectCategory(_project('a', 'Tari Kreasi', ['Tari', 'Musik'])).icon,
      Icons.theater_comedy_outlined,
    );
    expect(
      projectCategory(_project('b', 'Liga Sekolah', ['Futsal'])).icon,
      Icons.sports_soccer_rounded,
    );
    expect(
      projectCategory(_project('c', 'Lomba Debat', ['Public Speaking'])).icon,
      Icons.record_voice_over_outlined,
    );
    expect(
      projectCategory(_project('d', 'Pameran', ['Kepemimpinan'])).icon,
      Icons.emoji_events_outlined,
    );
  });

  test('an arts student is recommended the dance project first', () {
    const dancer = ProfileData(
      name: 'Sinta',
      roleLabel: 'Siswa · Kelas XI',
      institution: 'SMA Nusantara',
      email: 'sinta@school.id',
      bio: '-',
      skills: ['Tari', 'Vokal'],
      interests: ['Seni & Pertunjukan'],
    );
    final ranked = ProjectRecommender.rank(
      projects: [
        _project('app', 'Aplikasi Absensi', ['Flutter', 'UI/UX']),
        _project('dance', 'Tari Kreasi Nusantara', ['Tari', 'Musik']),
      ],
      profile: dancer,
    );
    expect(ranked.first.project.id, 'dance');
    expect(ranked.first.reason, contains('Keahlian: Tari'));
  });

  testWidgets('skills can be typed or picked from any field', (tester) async {
    var selected = <String>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: SkillPicker(
                keyPrefix: 'skill_',
                selected: selected,
                onChanged: (skills) => setState(() => selected = skills),
              ),
            ),
          ),
        ),
      ),
    );

    // Keahlian yang tidak ada di saran dapat diketik sendiri.
    await tester.enterText(find.byKey(const Key('skill_input')), 'Tari Saman');
    await tester.tap(find.byKey(const Key('skill_add')));
    await tester.pump();
    expect(selected, {'Tari Saman'});

    // Keahlian yang sama (beda huruf besar/kecil) tidak ditambah dua kali.
    await tester.enterText(find.byKey(const Key('skill_input')), 'tari saman');
    await tester.tap(find.byKey(const Key('skill_add')));
    await tester.pump();
    expect(selected, {'Tari Saman'});

    await tester.tap(find.byKey(const Key('skill_group_Olahraga')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('skill_Futsal')));
    await tester.pump();
    expect(selected, {'Tari Saman', 'Futsal'});

    // Keahlian terpilih dapat dihapus lewat ikon silang pada chip.
    await tester.tap(
      find
          .descendant(
            of: find.byKey(const Key('skill_selected_Tari Saman')),
            matching: find.byType(Icon),
          )
          .last,
    );
    await tester.pump();
    expect(selected, {'Futsal'});
  });
}
