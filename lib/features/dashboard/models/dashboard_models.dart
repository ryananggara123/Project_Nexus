import 'package:flutter/material.dart';

enum ProjectDifficulty {
  beginner('Pemula'),
  intermediate('Menengah'),
  advanced('Lanjutan');

  const ProjectDifficulty(this.label);

  final String label;
}

class ProjectListing {
  const ProjectListing({
    required this.id,
    required this.title,
    required this.leader,
    required this.event,
    required this.description,
    required this.skills,
    required this.teacherName,
    required this.statusAcc,
    required this.recruitmentOpen,
    this.difficulty = ProjectDifficulty.beginner,
    this.weeklyHours = 3,
    this.firstStep = '',
    this.reviewNote,
  });

  final String id;
  final String title;
  final String leader;
  final String event;
  final String description;
  final List<String> skills;
  final String teacherName;
  final String statusAcc;
  final bool recruitmentOpen;
  final ProjectDifficulty difficulty;
  final int weeklyHours;
  final String firstStep;
  final String? reviewNote;

  ProjectListing copyWith({
    String? title,
    String? description,
    String? statusAcc,
    bool? recruitmentOpen,
    ProjectDifficulty? difficulty,
    int? weeklyHours,
    String? firstStep,
    String? reviewNote,
    bool clearReviewNote = false,
  }) {
    return ProjectListing(
      id: id,
      title: title ?? this.title,
      leader: leader,
      event: event,
      description: description ?? this.description,
      skills: skills,
      teacherName: teacherName,
      statusAcc: statusAcc ?? this.statusAcc,
      recruitmentOpen: recruitmentOpen ?? this.recruitmentOpen,
      difficulty: difficulty ?? this.difficulty,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      firstStep: firstStep ?? this.firstStep,
      reviewNote: clearReviewNote ? null : reviewNote ?? this.reviewNote,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'leader': leader,
    'event': event,
    'description': description,
    'skills': skills,
    'teacherName': teacherName,
    'statusAcc': statusAcc,
    'recruitmentOpen': recruitmentOpen,
    'difficulty': difficulty.name,
    'weeklyHours': weeklyHours,
    'firstStep': firstStep,
    'reviewNote': reviewNote,
  };

  /// Membaca proyek dari database; `null` bila datanya tidak lengkap atau rusak.
  static ProjectListing? tryFromJson(Map<String, dynamic> json) {
    try {
      return ProjectListing(
        id: json['id'] as String,
        title: json['title'] as String,
        leader: json['leader'] as String,
        event: json['event'] as String,
        description: json['description'] as String,
        skills: List<String>.unmodifiable(json['skills'] as List),
        teacherName: json['teacherName'] as String,
        statusAcc: json['statusAcc'] as String,
        recruitmentOpen: json['recruitmentOpen'] as bool,
        difficulty: ProjectDifficulty.values.byName(
          json['difficulty'] as String,
        ),
        weeklyHours: json['weeklyHours'] as int,
        firstStep: json['firstStep'] as String,
        reviewNote: json['reviewNote'] as String?,
      );
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
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
