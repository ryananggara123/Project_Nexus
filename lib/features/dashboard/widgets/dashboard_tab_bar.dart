import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';

/// Tab teks dengan garis bawah teal; bisa digeser jika layar sempit.
class DashboardTabBar extends StatelessWidget {
  const DashboardTabBar({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  static const _labels = [
    'Feed proyek',
    'Pengajuan saya',
    'Lamaran saya',
    'Katalog prestasi',
  ];

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ProjectNexusColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _labels.length; i++)
              _TabItem(
                label: _labels[i],
                selected: selectedIndex == i,
                onTap: () => onChanged(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? ProjectNexusColors.teal : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? ProjectNexusColors.ink
                  : ProjectNexusColors.muted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
