import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';

/// Saran keahlian dari berbagai bidang. ProjectNexus dipakai untuk lomba dan
/// proyek apa pun, bukan hanya teknologi, sehingga keahlian juga dapat
/// diketik sendiri di [SkillPicker].
const skillSuggestions = <String, List<String>>{
  'Umum': [
    'Kepemimpinan',
    'Public Speaking',
    'Kolaborasi',
    'Penulis',
    'Riset',
    'Desain',
    'Dokumentasi',
  ],
  'Seni & Budaya': [
    'Tari',
    'Musik',
    'Vokal',
    'Teater',
    'Lukis',
    'Fotografi',
    'Videografi',
    'Kriya',
  ],
  'Olahraga': [
    'Futsal',
    'Basket',
    'Voli',
    'Bulu Tangkis',
    'Atletik',
    'Pencak Silat',
    'E-sport',
  ],
  'Sains': [
    'Matematika',
    'Fisika',
    'Kimia',
    'Biologi',
    'Lingkungan',
    'Olimpiade Sains',
  ],
  'Bahasa & Debat': [
    'Debat',
    'Bahasa Inggris',
    'Menulis Esai',
    'Puisi',
    'Jurnalistik',
    'MC',
  ],
  'Teknologi': [
    'Flutter',
    'UI/UX',
    'IoT',
    'Basis Data',
    'Pemrograman',
    'Robotik',
    'Prototyping',
  ],
  'Wirausaha': ['Bisnis', 'Pemasaran', 'Keuangan', 'Kuliner'],
};

/// Pemilih keahlian: keahlian terpilih di atas, kolom untuk mengetik
/// keahlian sendiri, lalu saran yang dikelompokkan per bidang.
class SkillPicker extends StatefulWidget {
  const SkillPicker({
    required this.selected,
    required this.onChanged,
    this.keyPrefix = 'skill_',
    this.initialGroup = 'Umum',
    super.key,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  /// Awalan key setiap chip saran, misalnya `draft_skill_`.
  final String keyPrefix;
  final String initialGroup;

  @override
  State<SkillPicker> createState() => _SkillPickerState();
}

class _SkillPickerState extends State<SkillPicker> {
  final _controller = TextEditingController();
  late String _group = widget.initialGroup;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _has(String skill) => widget.selected.any(
    (item) => item.toLowerCase() == skill.trim().toLowerCase(),
  );

  void _toggle(String skill) {
    final next = {...widget.selected};
    if (_has(skill)) {
      next.removeWhere(
        (item) => item.toLowerCase() == skill.trim().toLowerCase(),
      );
    } else {
      next.add(skill.trim());
    }
    widget.onChanged(next);
  }

  void _addTyped() {
    final skill = _controller.text.trim();
    if (skill.isEmpty) return;
    if (!_has(skill)) widget.onChanged({...widget.selected, skill});
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selected.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final skill in widget.selected)
                InputChip(
                  key: Key('${widget.keyPrefix}selected_$skill'),
                  label: Text(skill),
                  selected: true,
                  showCheckmark: false,
                  selectedColor: ProjectNexusColors.mint,
                  labelStyle: const TextStyle(
                    color: ProjectNexusColors.tealDark,
                    fontWeight: FontWeight.w600,
                  ),
                  deleteIconColor: ProjectNexusColors.tealDark,
                  onDeleted: () => _toggle(skill),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          key: Key('${widget.keyPrefix}input'),
          controller: _controller,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addTyped(),
          decoration: InputDecoration(
            hintText: 'Ketik keahlian lain, misalnya Tari Saman',
            counterText: '',
            prefixIcon: const Icon(Icons.add_circle_outline_rounded),
            suffixIcon: IconButton(
              key: Key('${widget.keyPrefix}add'),
              tooltip: 'Tambahkan keahlian',
              onPressed: _addTyped,
              icon: const Icon(Icons.keyboard_return_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Atau pilih dari saran:',
          style: TextStyle(color: ProjectNexusColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final group in skillSuggestions.keys)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    key: Key('${widget.keyPrefix}group_$group'),
                    label: Text(group),
                    selected: _group == group,
                    showCheckmark: false,
                    selectedColor: ProjectNexusColors.tealDark,
                    labelStyle: TextStyle(
                      color: _group == group
                          ? Colors.white
                          : ProjectNexusColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _group = group),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 2,
          children: [
            for (final skill in skillSuggestions[_group] ?? const <String>[])
              FilterChip(
                key: Key('${widget.keyPrefix}$skill'),
                label: Text(skill),
                selected: _has(skill),
                onSelected: (_) => _toggle(skill),
              ),
          ],
        ),
      ],
    );
  }
}
