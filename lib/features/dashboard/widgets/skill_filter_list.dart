import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../data/dashboard_sample_data.dart';

class SkillFilterList extends StatelessWidget {
  const SkillFilterList({
    required this.selectedSkill,
    required this.onSelected,
    required this.beginnerOnly,
    required this.onBeginnerOnlyChanged,
    super.key,
  });

  final String selectedSkill;
  final ValueChanged<String> onSelected;
  final bool beginnerOnly;
  final ValueChanged<bool> onBeginnerOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final skill in dashboardSkillFilters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(
                label: skill,
                selected: selectedSkill == skill,
                onSelected: (_) => onSelected(skill),
              ),
            ),
          _chip(
            key: const Key('beginner_project_filter'),
            label: 'Ramah pemula',
            selected: beginnerOnly,
            onSelected: onBeginnerOnlyChanged,
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Key? key,
  }) {
    return FilterChip(
      key: key,
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      backgroundColor: ProjectNexusColors.surface,
      selectedColor: ProjectNexusColors.ink,
      side: BorderSide(
        color: selected ? ProjectNexusColors.ink : ProjectNexusColors.border,
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : ProjectNexusColors.ink,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    );
  }
}
