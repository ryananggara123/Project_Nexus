import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';
import '../models/portfolio_item.dart';
import '../models/project_application.dart';
import '../models/workspace_task.dart';

const dashboardSkillFilters = ['Semua', 'UI/UX', 'Flutter', 'Riset', 'Penulis'];

const dashboardProjects = [
  ProjectListing(
    id: 'sample-garden',
    title: 'Draf Sistem Kebun Sekolah',
    leader: 'Nadia Putri',
    event: 'Proyek Inovasi Sekolah',
    description:
        'Rancangan kebun sekolah dengan pemantauan kelembapan tanah sederhana.',
    skills: ['Riset', 'Flutter'],
    teacherName: 'Budi Santoso',
    statusAcc: 'pending',
    recruitmentOpen: false,
    difficulty: ProjectDifficulty.beginner,
    weeklyHours: 2,
    firstStep: 'Amati kondisi kebun sekolah dan catat masalah yang ditemukan.',
  ),
  ProjectListing(
    id: 'sample-water-iot',
    title: 'Aplikasi Pemantau Kualitas Air IoT',
    leader: 'Nadia Putri',
    event: 'Olimpiade Sains Nasional',
    description: 'Membangun perangkat IoT dan aplikasi untuk memantau kualitas air secara real-time.',
    skills: ['Flutter', 'IoT', 'UI/UX'],
    teacherName: 'Budi Santoso',
    statusAcc: 'approved',
    recruitmentOpen: true,
    difficulty: ProjectDifficulty.intermediate,
    weeklyHours: 5,
    firstStep: 'Petakan sumber air dan tentukan titik pengukuran.',
  ),
  ProjectListing(
    id: 'sample-library',
    title: 'Sistem Informasi Perpustakaan',
    leader: 'Siti Aminah',
    event: 'Lomba Inovasi Digital',
    description: 'Merancang pengalaman peminjaman buku yang lebih mudah untuk warga sekolah.',
    skills: ['Flutter', 'UI/UX', 'Basis Data'],
    teacherName: 'Siti Rahmawati',
    statusAcc: 'approved',
    recruitmentOpen: true,
    difficulty: ProjectDifficulty.beginner,
    weeklyHours: 3,
    firstStep: 'Wawancarai satu pengguna tentang pengalaman meminjam buku.',
  ),
  ProjectListing(
    id: 'sample-local-history',
    title: 'Peta Cerita Sejarah Lokal',
    leader: 'Rizky Ramadhan',
    event: 'Kompetisi Riset Pelajar',
    description: 'Mengumpulkan cerita sejarah sekitar sekolah dalam peta digital interaktif.',
    skills: ['Riset', 'Penulis', 'Desain'],
    teacherName: 'Budi Santoso',
    statusAcc: 'approved',
    recruitmentOpen: true,
    difficulty: ProjectDifficulty.beginner,
    weeklyHours: 2,
    firstStep: 'Kumpulkan satu cerita sejarah dari warga sekitar sekolah.',
  ),
];

const schoolAchievements = [
  SchoolAchievement(
    title: 'Inovasi Teknologi Lingkungan',
    category: 'Kompetisi Sains · Tingkat Provinsi',
    team: 'Tim Karya Ilmiah Remaja',
    year: '2025',
    icon: Icons.eco_outlined,
    color: Color(0xFF087E8B),
  ),
  SchoolAchievement(
    title: 'Desain Produk Digital',
    category: 'Festival Kreativitas Pelajar',
    team: 'Tim Desain Digital',
    year: '2025',
    icon: Icons.auto_awesome_outlined,
    color: Color(0xFFC46A3A),
  ),
  SchoolAchievement(
    title: 'Riset Pangan Lokal',
    category: 'Lomba Karya Tulis · Tingkat Nasional',
    team: 'Tim Riset Siswa',
    year: '2024',
    icon: Icons.science_outlined,
    color: Color(0xFF536B45),
  ),
];

/// Data awal yang dimasukkan ke database lokal saat aplikasi pertama kali dibuka.
const sampleApplications = [
  ProjectApplication(
    id: 'sample-water-iot__ryan-anggara-deki',
    projectId: 'sample-water-iot',
    applicantName: 'Ryan Anggara Deki',
    status: ProjectApplicationStatus.accepted,
    skills: ['Flutter', 'UI/UX', 'Prototyping', 'Kolaborasi'],
  ),
  ProjectApplication(
    id: 'sample-water-iot__rizky-ramadhan',
    projectId: 'sample-water-iot',
    applicantName: 'Rizky Ramadhan',
    status: ProjectApplicationStatus.accepted,
    skills: ['Riset', 'Penulis', 'Desain'],
  ),
];

const sampleWorkspaceTasks = {
  'sample-water-iot': [
    WorkspaceTask(
      title: 'Riset parameter kualitas air',
      assignee: 'Rizky Ramadhan',
      dueLabel: 'Hari ini',
      status: WorkspaceTaskStatus.done,
    ),
    WorkspaceTask(
      title: 'Menyusun rancangan sensor IoT',
      assignee: 'Nadia Putri',
      dueLabel: 'Besok',
      status: WorkspaceTaskStatus.inProgress,
    ),
    WorkspaceTask(
      title: 'Membuat tampilan dashboard aplikasi',
      assignee: 'Ryan Anggara Deki',
      dueLabel: '12 Okt 2026',
      status: WorkspaceTaskStatus.inProgress,
    ),
    WorkspaceTask(
      title: 'Menghubungkan data sensor ke aplikasi',
      assignee: 'Ryan Anggara Deki',
      dueLabel: '15 Okt 2026',
      status: WorkspaceTaskStatus.todo,
    ),
    WorkspaceTask(
      title: 'Menyiapkan bahan presentasi proyek',
      assignee: 'Nadia Putri',
      dueLabel: '18 Okt 2026',
      status: WorkspaceTaskStatus.todo,
    ),
  ],
};

const samplePortfolioItems = [
  PortfolioItem(
    owner: 'Ryan Anggara Deki',
    title: 'Aplikasi Jadwal Kelas',
    category: 'Mobile Development',
    description: 'Aplikasi Flutter untuk membantu siswa melihat jadwal dan pengingat kelas.',
    year: '2026',
    icon: Icons.phone_android_rounded,
    color: Color(0xFF087E8B),
  ),
  PortfolioItem(
    owner: 'Ryan Anggara Deki',
    title: 'Desain Ulang Perpustakaan Digital',
    category: 'UI/UX',
    description:
        'Membuat prototipe antarmuka peminjaman buku yang mudah digunakan.',
    year: '2025',
    icon: Icons.design_services_outlined,
    color: Color(0xFFC46A3A),
  ),
  PortfolioItem(
    owner: 'Nadia Putri',
    title: 'Inovasi Teknologi Lingkungan',
    category: 'Prestasi · Tingkat Provinsi',
    description:
        'Merancang sistem pemantauan lingkungan untuk kompetisi sains pelajar.',
    year: '2025',
    icon: Icons.emoji_events_outlined,
    color: Color(0xFF536B45),
  ),
  PortfolioItem(
    owner: 'Rizky Ramadhan',
    title: 'Peta Cerita Sejarah Lokal',
    category: 'Riset & Data',
    description: 'Mengumpulkan cerita sejarah lokal dan menyajikannya dalam peta interaktif.',
    year: '2025',
    icon: Icons.map_outlined,
    color: Color(0xFF6657A5),
  ),
];
