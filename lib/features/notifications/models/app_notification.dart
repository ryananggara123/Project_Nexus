import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';

enum NotificationType {
  projectSubmitted(Icons.outbox_rounded, ProjectNexusColors.warning),
  projectApproved(Icons.verified_rounded, ProjectNexusColors.success),
  projectRejected(Icons.edit_note_rounded, ProjectNexusColors.error),
  newApplicant(Icons.person_add_alt_1_rounded, ProjectNexusColors.teal),
  applicationAccepted(Icons.celebration_rounded, ProjectNexusColors.success),
  applicationRejected(Icons.person_off_outlined, ProjectNexusColors.muted),
  taskAssigned(Icons.assignment_ind_rounded, ProjectNexusColors.teal),
  resultRecorded(Icons.emoji_events_rounded, ProjectNexusColors.gold);

  const NotificationType(this.icon, this.color);

  final IconData icon;
  final Color color;
}

/// Pemberitahuan untuk satu pengguna, misalnya draf disetujui atau ada pelamar
/// baru. Penerima dan pengirim dicatat dengan nama, sama seperti data proyek.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipient,
    required this.sender,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.projectId,
    this.read = false,
  });

  final String id;
  final String recipient;
  final String sender;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? projectId;
  final bool read;

  AppNotification markedRead() => AppNotification(
    id: id,
    recipient: recipient,
    sender: sender,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    projectId: projectId,
    read: true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipient': recipient,
    'sender': sender,
    'type': type.name,
    'title': title,
    'body': body,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'projectId': projectId,
    'read': read,
  };

  /// Membaca notifikasi dari database; `null` bila datanya tidak lengkap.
  static AppNotification? tryFromJson(Map<String, dynamic> json) {
    try {
      return AppNotification(
        id: json['id'] as String,
        recipient: json['recipient'] as String,
        sender: json['sender'] as String,
        type: NotificationType.values.byName(json['type'] as String),
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAt'] as int,
        ),
        projectId: json['projectId'] as String?,
        read: json['read'] as bool,
      );
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }
}

/// Waktu relatif dalam bahasa Indonesia, misalnya "5 menit lalu".
String relativeTimeLabel(DateTime time, DateTime now) {
  final elapsed = now.difference(time);
  if (elapsed.inMinutes < 1) return 'Baru saja';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes} menit lalu';
  if (elapsed.inDays < 1) return '${elapsed.inHours} jam lalu';
  if (elapsed.inDays == 1) return 'Kemarin';
  if (elapsed.inDays < 7) return '${elapsed.inDays} hari lalu';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', //
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${time.day} ${months[time.month - 1]} ${time.year}';
}
