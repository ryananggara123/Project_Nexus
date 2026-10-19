import 'package:flutter/material.dart';

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
}
