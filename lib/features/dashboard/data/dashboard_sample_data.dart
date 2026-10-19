import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';

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
