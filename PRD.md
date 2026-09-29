PRODUCT REQUIREMENTS DOCUMENT (PRD) 
”ProjectNexus: Platform Team-Matching & Inkubator Proyek Kolaborasi Lintas Keahlian Siswa” 
 
Disusun untuk memenuhi tugas mata kuliah Mobile Programing Dosen Pengampu: Ghea Candra Surawan, M.Pd.  
 
 
 
 
 
  
Disusun oleh:
Nama  : Ryan Anggara Deki
NPM   : 2413025074
Kelas   : PTI 2024B


  
PROGRAM STUDI PENDIDIKAN TEKNOLOGI INFORMASI 
JURUSAN PENDIDIKAN MATEMATIKA DAN ILMU PENGETAHUAN ALAM 
FAKULTAS KEGURUAN ILMU PENDIDIKAN 
UNIVERSITAS LAMPUNG 
2026
A. Ringkasan Proyek
1.	Apa masalah yang ingin diselesaikan?
Dalam lingkungan sekolah, siswa yang memiliki minat untuk mengikuti perlombaan (seperti kompetisi teknologi, riset, atau desain) maupun mengembangkan proyek karya mandiri sering kali kesulitan menemukan rekan tim dengan keahlian yang saling melengkapi. Pembentukan tim secara informal yang berpatokan pada pertemanan dekat cenderung menghasilkan komposisi anggota yang homogen. Akibatnya, ide proyek perlombaan atau pengembangan produk tidak dapat dieksekusi secara maksimal karena kurangnya variasi keahlian serta ketiadaan pendampingan terstruktur dari guru pembimbing.
2.	Apa solusi yang ditawarkan?
ProjectNexus hadir sebagai platform mobile team-matching dan inkubator proyek terstruktur yang dirancang khusus untuk memfasilitasi pembentukan tim perlombaan dan pengembangan karya berbasis kebutuhan keahlian nyata. Melalui aplikasi ini, siswa dapat mempublikasikan rancangan proyek lomba, menentukan kuota role berbasis skill tags, mengonsultasikan rancangan ke Guru Pendamping untuk mendapatkan persetujuan (ACC), serta menyeleksi pelamar berdasarkan portofolio digital demi membangun tim yang solid dan siap berkompetisi.
3.	Siapa target pengguna aplikasi ini?
Target utama pengguna aplikasi ini mencakup:
1.	Peserta Didik (Siswa): Berperan sebagai pencetus proyek (Project Leader) yang membutuhkan rekrutmen anggota tim, maupun sebagai pelamar (Applicant) yang mencari tim sesuai minat keahliannya.
2.	Pendidik (Guru Pendamping): Berperan sebagai mentor dan verifikator yang bertugas meninjau, memberi catatan, serta menyetujui draf pengajuan proyek sebelum lowongan dipublikasikan.
B. Spesifikasi Teknis
Komponen Teknis	Spesifikasi / Teknologi
Framework	Flutter
Bahasa Pemrograman	Dart
Backend & Database	Firebase (Firebase Auth, Cloud Firestore, Firebase Storage)
Target Platform	Android 

C. Fitur Utama (Minimum Viable Product)
1.	Autentikasi & Manajemen Peran (Multi-Role Auth): Sistem pendaftaran dan masuk akun yang memisahkan hak akses antarmuka serta wewenang fitur antara peran Siswa dan Guru Pendamping.
2.	Alur Konsultasi & Persetujuan Guru (Approval Workflow): Modul khusus yang menahan publikasi proyek pada kondisi pending. Guru Pendamping dapat memeriksa rancangan lomba/proyek siswa dan memberikan persetujuan (ACC) agar fitur rekrutmen terbuka.
3.	Modul Rekrutmen & Matchmaking Tim (Open Recruitment): Fitur penayangan lowongan proyek terverifikasi di beranda utama. Ketua proyek dapat memposting kebutuhan spesifik (roles needed) berbasis tag keahlian (seperti UI/UX, Mobile Dev, Content Writer).
4.	Manajemen Portofolio Digital Siswa (Student Portfolio): Modul pada profil siswa yang berfungsi menyimpan dan menampilkan riwayat karya (gambar/sertifikat, deskripsi proyek, dan tautan luar) sebagai bahan evaluasi bagi ketua proyek saat menyeleksi pelamar.
5.	Katalog Prestasi Sekolah (School Achievement Showcase): Etalase galeri publik yang menampilkan daftar piala, sertifikat, nama siswa pemenang, dan kategori kejuaraan yang berhasil diraih sekolah.
6.	Papan Manajemen Tugas Kelompok (Workspace Milestone): Ruang kerja internal tim yang telah terbentuk untuk mendistribusikan dan memantau progres pengerjaan tugas (To-Do, In-Progress, Done).

D. Alur Pengguna (User Flow) & Navigasi
1.	Splash Screen: Menampilkan branding dan logo ProjectNexus saat aplikasi diinisialisasi.
2.	Halaman Autentikasi (Login/Register): Pengguna memilih peran (Siswa/Guru Pendamping) dan melakukan otentikasi akun.
3.	Beranda Utama (Dashboard):
a.	Tab Feed Proyek: Menampilkan daftar lowongan tim berstatus Open yang dapat difilter sesuai keahlian siswa.
b.	Tab Katalog Prestasi: Menampilkan etalase pencapaian perlombaan sekolah.
4.	Alur Pengajuan & Verifikasi Proyek:
a.	Siswa membuat Draf Proyek → Memilih Guru Pendamping → Mengirim Pengajuan (Status: Pending Approval).
b.	Guru Pendamping menerima notifikasi antrean → Meninjau draf → Menekan tombol ACC (Approved).
c.	Status proyek berubah menjadi Open dan otomatis muncul pada Feed Rekrutmen publik.
5.	Alur Pendaftaran & Seleksi Anggota:
a.	Siswa melengkapi berkas karya di Halaman Portofolio.
b.	Pelamar menekan tombol Apply pada posisi yang diminati dalam detail proyek.
c.	Ketua Proyek memeriksa Portofolio Digital pelamar → Memilih tombol Accept atau Reject.
6.	Ruang Kerja Tim (Workspace): Anggota yang diterima secara otomatis mendapatkan akses ke papan Task Board proyek untuk membagi tugas pengerjaan.
Navigasi antar-halaman utama menggunakan Bottom Navigation Bar, serta dilengkapi Floating Action Button (FAB) pada antarmuka siswa untuk memicu pembuatan draf proyek baru secara cepat.

Tampilan Guru
   	    	  

Tampilan Siswa
 	 	 

E. Jadwal Pengerjaan (Timeline)
Minggu Ke-	Target Pekerjaan
Minggu 1	Penyusunan dokumen PRD & SRD lengkap, dilanjutkan dengan pembuatan perancangan UI/UX (Wireframing & Prototyping Figma) untuk seluruh alur pengguna.
Minggu 2	Pengaturan repositori proyek Flutter, pembuatan struktur komponen UI (Slicing), serta perancangan tata letak Halaman Beranda, Form Konsultasi Guru, dan Portofolio.
Minggu 3	Integrasi logika pemrosesan data (Dart), konfigurasi Firebase Authentication multi-role, struktur koleksi Cloud Firestore untuk status ACC, dan Firebase Storage.
Minggu 4	Pengujian menyeluruh (End-to-End Testing) pada alur persetujuan guru dan pengunggahan berkas, perbaikan kendala (debugging), serta finalisasi dokumen.

F. Kriteria Keberhasilan
1.	Aplikasi dapat dijalankan dengan lancar (build & run) pada emulator maupun perangkat Android fisik tanpa mengalami kecacatan sistem (crash atau force close).
2.	Mekanisme pembatasan hak akses berfungsi 100%, di mana draf proyek tidak akan tampil di feed publik sebelum disetujui (ACC) oleh Guru Pendamping yang dipilih.
3.	Fitur portofolio digital berhasil mengunggah berkas gambar ke Firebase Storage dan menampilkan tautannya secara presisi pada profil siswa.
4.	Integrasi navigasi antarmuka utama menggunakan Bottom Navigation Bar dan Floating Action Button responsif serta bebas kendala teknis.
5.	Seluruh fungsi manipulasi data (Create, Read, Update) pada alur rekrutmen dan papan tugas berjalan sesuai spesifikasi kebutuhan.
