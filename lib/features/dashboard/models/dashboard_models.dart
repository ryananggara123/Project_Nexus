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
    this.reviewNote,
  });

  final String title;
  final String leader;
  final String event;
  final String description;
  final List<String> skills;
  final String teacherName;
  final String statusAcc;
  final String? reviewNote;

  ProjectListing copyWith({
    String? title,
    String? description,
    String? statusAcc,
    String? reviewNote,
    bool clearReviewNote = false,
  }) {
    return ProjectListing(
      title: title ?? this.title,
      leader: leader,
      event: event,
      description: description ?? this.description,
      skills: skills,
      teacherName: teacherName,
      statusAcc: statusAcc ?? this.statusAcc,
      reviewNote: clearReviewNote ? null : reviewNote ?? this.reviewNote,
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
