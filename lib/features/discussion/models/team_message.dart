/// Satu pesan di ruang diskusi tim sebuah proyek.
class TeamMessage {
  const TeamMessage({
    required this.id,
    required this.projectId,
    required this.sender,
    required this.text,
    required this.sentAt,
  });

  /// Batas panjang pesan, sama dengan aturan keamanan server.
  static const maxLength = 1000;

  final String id;
  final String projectId;
  final String sender;
  final String text;
  final DateTime sentAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'sender': sender,
    'text': text,
    'sentAt': sentAt.millisecondsSinceEpoch,
  };

  static TeamMessage? tryFromJson(Map<String, dynamic> json) {
    try {
      return TeamMessage(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        sender: json['sender'] as String,
        text: json['text'] as String,
        sentAt: DateTime.fromMillisecondsSinceEpoch(json['sentAt'] as int),
      );
    } on TypeError {
      return null;
    }
  }
}
