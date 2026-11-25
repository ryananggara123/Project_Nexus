import 'package:flutter_test/flutter_test.dart';

import 'package:project_nexus/features/dashboard/screens/workspace_screen.dart';

void main() {
  test('Indonesian due dates are parsed for overdue highlighting', () {
    expect(parseDueDate('15 Okt 2026'), DateTime(2026, 10, 15));
    expect(parseDueDate('3 Agustus 2027'), DateTime(2027, 8, 3));
    expect(parseDueDate('Besok'), isNull);
    expect(parseDueDate('Baru ditambahkan'), isNull);
    expect(parseDueDate('12 Xyz 2026'), isNull);
  });
}
