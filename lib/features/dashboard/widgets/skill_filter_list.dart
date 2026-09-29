import 'package:flutter/material.dart';

import '../data/dashboard_sample_data.dart';

class SkillFilterList extends StatelessWidget {
  const SkillFilterList({
    required this.selectedSkill,
    required this.onSelected,
    super.key,
  });

  final String selectedSkill;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dashboardSkillFilters.map((skill) {
          final selected = selectedSkill == skill;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(skill),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(skill),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFD6ECEB),
              labelStyle: TextStyle(
                color: selected
                    ? const Color(0xFF087E8B)
                    : const Color(0xFF172A2D),
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF087E8B)
                    : const Color(0xFFDCE4E3),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
