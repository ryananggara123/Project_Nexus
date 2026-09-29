import 'package:flutter/material.dart';

class ProjectListing {
  const ProjectListing({
    required this.title,
    required this.leader,
    required this.event,
    required this.description,
    required this.skills,
    required this.teacherName,
    required this.statusAcc,
  });

  final String title;
  final String leader;
  final String event;
  final String description;
  final List<String> skills;
  final String teacherName;
  final String statusAcc;

  ProjectListing copyWith({String? statusAcc}) {
    return ProjectListing(
      title: title,
      leader: leader,
      event: event,
      description: description,
      skills: skills,
      teacherName: teacherName,
      statusAcc: statusAcc ?? this.statusAcc,
    );
  }
}

class SchoolAchievement {
  const SchoolAchievement({
    required this.title,
    required this.category,
    required this.team,
    required this.year,
    required this.icon,
    required this.color,
  });

  final String title;
  final String category;
  final String team;
  final String year;
  final IconData icon;
  final Color color;
}
