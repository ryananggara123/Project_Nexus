# Deklarasi Penggunaan AI

| | |
|---|---|
| Nama | Ryan Anggara Deki |
| NPM | 2413025074 |
| Kelas | PTI 2024B |
| Mata kuliah | Mobile Programming |
| Proyek | ProjectNexus |

Dokumen ini menjelaskan secara terbuka bagaimana asisten kecerdasan buatan (AI) digunakan selama pengembangan ProjectNexus hingga pekan UTS. Isinya disusun berdasarkan riwayat sesi chat dan riwayat commit proyek.

## 1. Daftar alat

| Alat | Bentuk penggunaan | Periode | Dipakai untuk |
|---|---|---|---|
| GitHub Copilot Chat (mode agent di VS Code) | Chat di editor | 27–28 September 2026 | Membuat struktur awal folder `lib/` berdasarkan PRD dan SRD, halaman login dua peran, serta panduan menjalankan aplikasi di Chrome dan melakukan commit ke GitHub. |
| GitHub Copilot CLI (agent) | Agent di terminal VS Code | 29 September – 15 Oktober 2026 | Implementasi sebagian besar fitur: pengajuan dan persetujuan proyek, lamaran dan seleksi anggota, Workspace, portofolio, profil, fitur ramah pemula dan rekomendasi, pengujian, serta pembuatan commit per fitur. |
| Claude Code (model Claude Opus 5.5) di VS Code | Agent di editor | 19–21 Oktober 2026 | Desain ulang tata letak seluruh layar, perbaikan bug pesan notifikasi dan tampilan yang meluap, penyusunan laporan, README, dan draf dokumen ini. |

## 2. Pembagian peran

Kode program Dart pada folder `lib/` dan `test/` dihasilkan oleh agen AI berdasarkan instruksi saya. Peran saya adalah menentukan kebutuhan dan aturan aplikasi, memberi arahan, menolak atau mengoreksi usulan AI yang tidak sesuai, serta memeriksa hasilnya dengan menjalankan aplikasi di Chrome dan menjalankan pengujian.

| Bagian | Kode ditulis oleh | Keputusan dan kontribusi saya |
|---|---|---|
| Dokumen kebutuhan (`PRD.md`, PRD dan SRD dalam PDF) | Saya | Merumuskan masalah, target pengguna, fitur MVP, alur pengguna, dan kriteria keberhasilan yang menjadi acuan seluruh pengembangan. |
| Autentikasi (`lib/features/auth/`) | Copilot, dirapikan Claude | Meminta siswa dan guru langsung diarahkan ke beranda masing-masing setelah login; meminta login siswa dengan NIM atau username serta menu registrasi; meminta splash menampilkan logo; meminta tulisan "Mode demo" dihapus. |
| Alur pengajuan dan persetujuan guru (`project_workflow_store.dart`, `draft_project_sheet.dart`, `approval_request_card.dart`) | Copilot | Menetapkan aturan dari PRD: draf tidak tampil sebelum disetujui guru pendamping yang dipilih; meminta alur pengajuan siswa sampai peninjauan guru diperiksa ulang. |
| Lamaran, seleksi anggota, hak akses Workspace | Copilot | Menolak usulan kuota tetap 5 anggota; menetapkan bahwa jumlah anggota tidak dibatasi dan ketua menutup rekrutmen sendiri (lihat Studi Kasus 1). |
| Workspace, portofolio, profil | Copilot | Meminta data contoh untuk akun siswa dan guru agar tampilan dapat diperiksa; meminta setiap fitur di-commit terpisah. |
| Ramah pemula, rekomendasi, lencana (`project_recommender.dart`, `contribution_recognition.dart`) | Copilot | Membawa masukan dosen agar aplikasi mendorong siswa yang belum berani ikut lomba; memilih untuk memulai dari fitur proyek pemula. |
| Tema dan tata letak (`core/theme/`, `dashboard_header.dart`) | Copilot, kemudian Claude | Menilai tampilan awal belum rapi; menetapkan arah desain formal, minimalis, dan tetap bernuansa teal; meminta header dan kartu hero tetap ada di setiap menu (lihat Studi Kasus 2). |
| Pengujian (`test/`) | Copilot dan Claude | Menjalankan pengujian dan memeriksa hasilnya sebelum perubahan di-commit. |
| Riwayat commit | Agen AI atas perintah saya | Meminta commit dibuat bertahap dan terpisah per fitur, serta meminta agar tidak melakukan push tanpa izin. |

## 3. Studi kasus prompting

### Studi Kasus 1: Aturan jumlah anggota tim (GitHub Copilot CLI, 9 Oktober 2026)

**Prompt saya:**

> nah saya ingin kita lanjutkan pengembangan yang benar" perlu logika, alur serta algoritma nya seperti apa (...) jadi tanyakan kepada saya apakah saran ini bagus dan berikan saya apa saja yang kurang dan saran perbaikannya seperti apa oke

**Hasil awal AI:** Copilot menyusun alur lamaran dan seleksi anggota. Salah satu aturannya: *"Ketua melihat daftar pelamar dan portofolionya, lalu menerima atau menolak. Sistem tidak boleh menerima anggota melebihi kuota"*, dengan kuota tetap 5 anggota per tim.

**Masalah:** Kebutuhan anggota setiap proyek berbeda. Proyek riset kecil mungkin cukup tiga orang, sedangkan proyek IoT bisa membutuhkan lebih banyak keahlian. Kuota tetap membuat ketua tidak bisa menerima anggota yang sebenarnya dibutuhkan.

**Penyesuaian saya:**

> eh sabar untuk anggota kelompok jangam diberi batrasan , nanti jumlah anggot nya menyesuaikan dengan project yang dikerjakan apa

**Hasil akhir:** Aturan kuota dihapus. Sebagai gantinya, ketua proyek dapat membuka atau menutup rekrutmen sendiri melalui `setRecruitmentOpen()`. Fungsi ini tetap memeriksa bahwa pengubahnya adalah ketua proyek dan proyeknya sudah disetujui guru:

```dart
if (project.leader.toLowerCase() != leaderName.trim().toLowerCase()) {
  return WorkflowActionResult.notProjectLeader;
}
if (project.statusAcc != 'approved') {
  return WorkflowActionResult.projectNotApproved;
}
_projects[index] = project.copyWith(recruitmentOpen: isOpen);
```

Aturan ini dibuktikan oleh unit test `team size is not capped and leader can close recruitment`, yang menerima 12 anggota lalu menutup rekrutmen.

### Studi Kasus 2: Desain ulang tampilan (Claude Code, 19 Oktober 2026)

**Prompt saya:**

> saya ingin yang pertama kamu perbaiki layout untuk aplikasi saya ini mulai dari halaman login, dan sterusnya karna sbelumnya yang dibuat oleh copilot saya gak rapi dan tidak sesuai dengan kemauan saya

**Hasil awal AI:** Claude merapikan halaman login, registrasi, dan beranda dengan gaya bersih dan minimalis. Namun, kartu hero bergradien dan header aplikasi di beranda ikut dihapus dan diganti sapaan teks biasa.

**Masalah:** Header dan kartu hero adalah identitas visual aplikasi yang ingin saya pertahankan. Tanpa keduanya, setiap menu terlihat polos dan tidak seragam.

**Penyesuaian saya** (disertai tangkapan layar tampilan yang dimaksud):

> saya ingin tetap ada itu nya di dashboard dan menu lainnya, dan saya ingin kamu kerjakan dulu semuanya baru abis itu laporan ke saya dan saya akan cek

**Hasil akhir:** Dibuat komponen bersama `AppHeader`, `HeroBanner`, dan `MenuPage` di `lib/features/dashboard/widgets/dashboard_header.dart`. Komponen ini dipakai di Beranda, Workspace, Portofolio, dan Profil, sehingga semua menu memiliki header dan hero yang sama, sementara bagian lainnya tetap minimalis.

## 4. Kesalahan AI yang ditemukan

| Kesalahan | Cara terdeteksi | Perbaikan |
|---|---|---|
| AI menampilkan tulisan "Mode demo" di halaman login dan registrasi. | Terlihat saat aplikasi dijalankan di Chrome. | Diminta dihapus; diganti petunjuk cara masuk. |
| Kuota tetap 5 anggota per tim. | Ditinjau saat AI menjelaskan rencana alur sebelum implementasi. | Diganti aturan tanpa batas dengan sakelar buka/tutup rekrutmen (Studi Kasus 1). |
| Pesan notifikasi (snackbar) menumpuk dan terbawa ke akun lain, sehingga pesan "Proyek disetujui" tertahan dan satu widget test selalu gagal. | `flutter test` menunjukkan tes `accepted applicant gets access to project workspace` gagal. | Pesan baru kini menggantikan pesan lama dan semua pesan dibersihkan saat keluar akun. Seluruh 33 tes lulus. |
| Kartu "Proyek aktif" di Workspace selalu menampilkan judul yang sama karena judulnya ditulis tetap di kode. | Ditemukan saat meninjau kode Workspace pada proses desain ulang. | Kartu dihapus; judul proyek yang dipilih ditampilkan pada hero Workspace. |
| Tombol Tolak/Terima pada dialog kelola pelamar meluap di layar kecil. | Widget test melaporkan galat overflow pada lebar layar 390 piksel. | Baris tombol diganti `Wrap` agar tombol dapat turun baris. |

## 5. Pernyataan

Saya menyatakan bahwa informasi dalam dokumen ini sesuai dengan cara saya mengembangkan ProjectNexus. Asisten AI saya gunakan sebagai alat bantu, sedangkan kebutuhan aplikasi, keputusan fitur dan aturan bisnis, serta pemeriksaan hasil adalah tanggung jawab saya. Saya bertanggung jawab penuh atas kebenaran, pemahaman, dan keamanan seluruh kode dalam repositori ini.
