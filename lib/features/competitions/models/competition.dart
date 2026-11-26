enum CompetitionLevel {
  school('Sekolah'),
  city('Kota/Kabupaten'),
  province('Provinsi'),
  national('Nasional'),
  international('Internasional');

  const CompetitionLevel(this.label);

  final String label;
}

/// Informasi lomba yang dipasang guru di Papan Info Lomba.
class Competition {
  const Competition({
    required this.id,
    required this.title,
    required this.organizer,
    required this.field,
    required this.level,
    required this.deadline,
    required this.description,
    required this.postedBy,
    this.prize = '',
    this.link = '',
  });

  final String id;
  final String title;
  final String organizer;

  /// Bidang lomba, misalnya Seni, Olahraga, Sains, atau Teknologi.
  final String field;
  final CompetitionLevel level;

  /// Batas akhir pendaftaran.
  final DateTime deadline;
  final String description;
  final String prize;
  final String link;

  /// Nama guru yang memasang info lomba.
  final String postedBy;

  /// Sisa hari pendaftaran dihitung dari [today] (negatif bila sudah tutup).
  int daysLeft(DateTime today) => DateTime(
    deadline.year,
    deadline.month,
    deadline.day,
  ).difference(DateTime(today.year, today.month, today.day)).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'organizer': organizer,
    'field': field,
    'level': level.name,
    'deadline': deadline.millisecondsSinceEpoch,
    'description': description,
    'prize': prize,
    'link': link,
    'postedBy': postedBy,
  };

  /// Membaca lomba dari database; `null` bila datanya tidak lengkap.
  static Competition? tryFromJson(Map<String, dynamic> json) {
    try {
      return Competition(
        id: json['id'] as String,
        title: json['title'] as String,
        organizer: json['organizer'] as String,
        field: json['field'] as String,
        level: CompetitionLevel.values.byName(json['level'] as String),
        deadline: DateTime.fromMillisecondsSinceEpoch(json['deadline'] as int),
        description: json['description'] as String,
        prize: json['prize'] as String? ?? '',
        link: json['link'] as String? ?? '',
        postedBy: json['postedBy'] as String,
      );
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }
}
