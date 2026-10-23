import 'package:flutter/material.dart';

/// Ikon karya yang dapat disimpan ke database melalui nama kuncinya.
/// Ikon disimpan sebagai kunci, bukan kode ikon, agar tetap konstan.
const portfolioIcons = <String, IconData>{
  'mobile': Icons.phone_android_rounded,
  'design': Icons.design_services_outlined,
  'trophy': Icons.emoji_events_outlined,
  'map': Icons.map_outlined,
  'task': Icons.task_alt_rounded,
  'spark': Icons.auto_awesome_outlined,
};

class PortfolioItem {
  const PortfolioItem({
    required this.owner,
    required this.title,
    required this.category,
    required this.description,
    required this.year,
    required this.icon,
    required this.color,
    this.isContribution = false,
  });

  final String owner;
  final String title;
  final String category;
  final String description;
  final String year;
  final IconData icon;
  final Color color;
  final bool isContribution;

  PortfolioItem copyWith({String? owner, bool? isContribution}) {
    return PortfolioItem(
      owner: owner ?? this.owner,
      title: title,
      category: category,
      description: description,
      year: year,
      icon: icon,
      color: color,
      isContribution: isContribution ?? this.isContribution,
    );
  }

  Map<String, dynamic> toJson() => {
    'owner': owner,
    'title': title,
    'category': category,
    'description': description,
    'year': year,
    'icon': portfolioIcons.entries
        .firstWhere(
          (entry) => entry.value == icon,
          orElse: () => const MapEntry('spark', Icons.auto_awesome_outlined),
        )
        .key,
    'color': color.toARGB32(),
    'isContribution': isContribution,
  };

  /// Membaca karya dari database; `null` bila datanya tidak lengkap atau rusak.
  static PortfolioItem? tryFromJson(Map<String, dynamic> json) {
    try {
      return PortfolioItem(
        owner: json['owner'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        year: json['year'] as String,
        icon: portfolioIcons[json['icon']] ?? Icons.auto_awesome_outlined,
        color: Color(json['color'] as int),
        isContribution: json['isContribution'] as bool? ?? false,
      );
    } on TypeError {
      return null;
    }
  }
}
