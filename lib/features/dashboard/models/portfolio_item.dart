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
    this.imageId,
    this.id,
  });

  /// ID karya untuk sinkronisasi. Karya lama tanpa ID memakai [idFor].
  final String? id;
  final String owner;
  final String title;
  final String category;
  final String description;
  final String year;
  final IconData icon;
  final Color color;
  final bool isContribution;

  /// ID foto karya di database lokal; `null` bila karya tidak memiliki foto.
  final String? imageId;

  /// ID tetap dari pemilik dan judul, sehingga data contoh dan karya lama
  /// mendapat ID yang sama di semua perangkat.
  static String idFor(String owner, String title) {
    String slug(String text) =>
        text.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');
    return '${slug(owner)}__${slug(title)}';
  }

  PortfolioItem copyWith({
    String? id,
    String? owner,
    bool? isContribution,
    String? imageId,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      title: title,
      category: category,
      description: description,
      year: year,
      icon: icon,
      color: color,
      isContribution: isContribution ?? this.isContribution,
      imageId: imageId ?? this.imageId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
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
    'imageId': imageId,
  };

  /// Membaca karya dari database; `null` bila datanya tidak lengkap atau rusak.
  static PortfolioItem? tryFromJson(Map<String, dynamic> json) {
    try {
      return PortfolioItem(
        id: json['id'] as String?,
        owner: json['owner'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        year: json['year'] as String,
        icon: portfolioIcons[json['icon']] ?? Icons.auto_awesome_outlined,
        color: Color(json['color'] as int),
        isContribution: json['isContribution'] as bool? ?? false,
        imageId: json['imageId'] as String?,
      );
    } on TypeError {
      return null;
    }
  }
}
