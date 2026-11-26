import 'package:flutter/material.dart';

/// Langkah yang dituju sebuah misi saat tombol "Mulai" ditekan.
enum MissionTarget {
  profile,
  feed,
  draft,
  directory,
  workspace,
  portfolio,
  submissions,
}

/// Satu misi pemula. Misi selesai dihitung dari data aplikasi yang sudah ada,
/// sehingga tidak perlu disimpan terpisah.
class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.hint,
    required this.xp,
    required this.icon,
    required this.target,
    required this.done,
  });

  final String id;
  final String title;
  final String hint;
  final int xp;
  final IconData icon;
  final MissionTarget target;
  final bool done;
}

/// Fakta tentang aktivitas siswa yang dipakai untuk menilai misi.
class MissionFacts {
  const MissionFacts({
    this.profileComplete = false,
    this.hasPhoto = false,
    this.applied = false,
    this.submitted = false,
    this.joinedTeam = false,
    this.invitedSomeone = false,
    this.finishedTask = false,
    this.addedWork = false,
    this.recordedResult = false,
    this.won = false,
  });

  final bool profileComplete;
  final bool hasPhoto;
  final bool applied;
  final bool submitted;
  final bool joinedTeam;
  final bool invitedSomeone;
  final bool finishedTask;
  final bool addedWork;
  final bool recordedResult;
  final bool won;
}

/// Tingkatan siswa berdasarkan total XP.
class MissionLevel {
  const MissionLevel(this.number, this.title, this.minXp);

  final int number;
  final String title;
  final int minXp;
}

const missionLevels = [
  MissionLevel(1, 'Pendatang Baru', 0),
  MissionLevel(2, 'Penjelajah', 50),
  MissionLevel(3, 'Kolaborator', 120),
  MissionLevel(4, 'Bintang Tim', 200),
  MissionLevel(5, 'Legenda Sekolah', 300),
];

class MissionProgress {
  const MissionProgress(this.missions);

  final List<Mission> missions;

  int get xp => missions.where((m) => m.done).fold(0, (sum, m) => sum + m.xp);
  int get maxXp => missions.fold(0, (sum, m) => sum + m.xp);
  int get completed => missions.where((m) => m.done).length;

  MissionLevel get level =>
      missionLevels.lastWhere((level) => xp >= level.minXp);

  /// Tingkat berikutnya; `null` bila sudah tertinggi.
  MissionLevel? get nextLevel {
    for (final level in missionLevels) {
      if (level.minXp > xp) return level;
    }
    return null;
  }

  /// Kemajuan menuju tingkat berikutnya, 0–1.
  double get levelProgress {
    final next = nextLevel;
    if (next == null) return 1;
    final span = next.minXp - level.minXp;
    return (xp - level.minXp) / span;
  }

  /// Misi pertama yang belum selesai, sebagai saran langkah berikutnya.
  Mission? get nextMission {
    for (final mission in missions) {
      if (!mission.done) return mission;
    }
    return null;
  }
}

/// Daftar misi berurutan dari yang paling mudah.
MissionProgress missionsFor(MissionFacts facts) => MissionProgress([
  Mission(
    id: 'profile',
    title: 'Lengkapi profil',
    hint: 'Tulis bio dan pilih minimal 3 keahlian.',
    xp: 20,
    icon: Icons.badge_outlined,
    target: MissionTarget.profile,
    done: facts.profileComplete,
  ),
  Mission(
    id: 'photo',
    title: 'Pasang foto profil',
    hint: 'Biar calon rekan tim mengenalimu.',
    xp: 10,
    icon: Icons.photo_camera_outlined,
    target: MissionTarget.profile,
    done: facts.hasPhoto,
  ),
  Mission(
    id: 'apply',
    title: 'Lamar satu proyek',
    hint: 'Pilih proyek yang cocok di Beranda lalu kirim lamaran.',
    xp: 20,
    icon: Icons.send_rounded,
    target: MissionTarget.feed,
    done: facts.applied,
  ),
  Mission(
    id: 'submit',
    title: 'Ajukan ide proyekmu',
    hint: 'Punya ide atau mau ikut lomba? Ajukan ke guru pendamping.',
    xp: 30,
    icon: Icons.lightbulb_outline_rounded,
    target: MissionTarget.draft,
    done: facts.submitted,
  ),
  Mission(
    id: 'team',
    title: 'Bergabung dalam tim',
    hint: 'Diterima ketua tim atau proyekmu disetujui guru.',
    xp: 30,
    icon: Icons.handshake_outlined,
    target: MissionTarget.feed,
    done: facts.joinedTeam,
  ),
  Mission(
    id: 'invite',
    title: 'Ajak teman bergabung',
    hint: 'Cari rekan di Direktori Bakat dan kirim ajakan.',
    xp: 15,
    icon: Icons.person_add_alt_1_rounded,
    target: MissionTarget.directory,
    done: facts.invitedSomeone,
  ),
  Mission(
    id: 'task',
    title: 'Selesaikan tugas pertama',
    hint: 'Pindahkan tugasmu ke kolom Selesai di Workspace.',
    xp: 25,
    icon: Icons.task_alt_rounded,
    target: MissionTarget.workspace,
    done: facts.finishedTask,
  ),
  Mission(
    id: 'work',
    title: 'Pajang karya',
    hint: 'Tambahkan hasil kerjamu ke Portofolio.',
    xp: 20,
    icon: Icons.palette_outlined,
    target: MissionTarget.portfolio,
    done: facts.addedWork,
  ),
  Mission(
    id: 'result',
    title: 'Ikuti lomba sampai selesai',
    hint: 'Catat hasil lomba timmu, apa pun hasilnya.',
    xp: 50,
    icon: Icons.military_tech_rounded,
    target: MissionTarget.submissions,
    done: facts.recordedResult,
  ),
  Mission(
    id: 'win',
    title: 'Raih juara',
    hint: 'Juara 1, 2, atau 3 bersama timmu.',
    xp: 100,
    icon: Icons.emoji_events_rounded,
    target: MissionTarget.submissions,
    done: facts.won,
  ),
]);
