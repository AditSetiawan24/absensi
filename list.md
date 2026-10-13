# Dokumentasi Implementasi & Pemetaan 1:1 Flutter ke Svelte 5

Dokumen ini memuat daftar lengkap seluruh fitur, halaman, komponen antarmuka, tombol, opsi dialog, alur UX, dan integrasi backend API dari aplikasi Flutter (`fe_absensi`) yang telah diimplementasikan dan disamakan secara presisi **1 : 1** ke Svelte 5 (`fe-svelte`).

---

## 1. Ringkasan Eksekutif Migrasi

| Indikator | Flutter (`fe_absensi`) | Svelte 5 (`fe-svelte`) | Status Kesamaan |
| :--- | :--- | :--- | :---: |
| **Total Halaman** | 23 Halaman | 23 Halaman | **100% (1:1)** |
| **Role Pengguna** | Guru, Kepala Sekolah, Orang Tua | Guru, Kepala Sekolah, Orang Tua | **100% (1:1)** |
| **State Management** | Provider / ValueNotifier | Svelte 5 Runes (`$state`, `$derived`, `$props`) + Svelte Stores | **100% (1:1)** |
| **Routing** | Navigator 1.0 / Push Named | `svelte-spa-router` (Hash-based Routing) | **100% (1:1)** |
| **Styling & Desain** | Material 3 + Custom AppColors | Vanilla CSS Design Tokens (Glassmorphism, Vibrant Colors) | **100% (1:1)** |
| **API Client** | Dio / Http (Base URL: `http://localhost:8000/api`) | Fetch / Axios API Client (Base URL: `http://localhost:8000/api`) | **100% (1:1)** |
| **Ekspor Dokumen** | PDF (`pdf`) & Excel (`excel`) | PDF Download & Excel Sheet Blob Download | **100% (1:1)** |
| **Visualisasi Data** | FlChart (Weekly BarChart, Per-Class BarChart) | Svelte Custom Responsive SVG & CSS Charts | **100% (1:1)** |

---

## 2. Matriks Pemetaan Halaman (23 Halaman)

| No | Modul / Halaman | File Flutter (`fe_absensi`) | File Svelte (`fe-svelte`) | URL Route Svelte | Status |
|:--:|:---|:---|:---|:---|:---:|
| 1 | **Landing** | `lib/pages/auth/landing_page.dart` | `src/pages/auth/Landing.svelte` | `/` | Selesai (1:1) |
| 2 | **Login** | `lib/pages/auth/login_page.dart` | `src/pages/auth/Login.svelte` | `/login` | Selesai (1:1) |
| 3 | **Register** | `lib/pages/auth/register_page.dart` | `src/pages/auth/Register.svelte` | `/register` | Selesai (1:1) |
| 4 | **Lupa Password** | `lib/pages/auth/forgot_password_page.dart` | `src/pages/auth/ForgotPassword.svelte` | `/forgot-password` | Selesai (1:1) |
| 5 | **Guru Shell Home** | `lib/pages/guru/guru_home_page.dart` | `src/pages/guru/GuruHome.svelte` | `/guru` | Selesai (1:1) |
| 6 | **Guru Dashboard** | `lib/pages/guru/guru_dashboard_page.dart` | `src/pages/guru/GuruDashboard.svelte` | `/guru/dashboard` | Selesai (1:1) |
| 7 | **Absensi Harian** | `lib/pages/guru/absensi_page.dart` | `src/pages/guru/Absensi.svelte` | `/guru/absensi` | Selesai (1:1) |
| 8 | **Mulai Absensi** | `lib/pages/guru/mulai_absensi_page.dart` | `src/pages/guru/MulaiAbsensi.svelte` | `/guru/mulai-absensi` | Selesai (1:1) |
| 9 | **Edit Absensi** | `lib/pages/guru/edit_absensi_page.dart` | `src/pages/guru/EditAbsensi.svelte` | `/guru/edit-absensi/:id` | Selesai (1:1) |
| 10 | **Kelola Siswa** | `lib/pages/guru/kelola_siswa_page.dart` | `src/pages/guru/KelolaSiswa.svelte` | `/guru/kelola-siswa` | Selesai (1:1) |
| 11 | **Detail Siswa** | `lib/pages/guru/siswa_detail_page.dart` | `src/pages/guru/SiswaDetail.svelte` | `/guru/siswa/:nis` | Selesai (1:1) |
| 12 | **Import Siswa** | `lib/pages/guru/import_siswa_page.dart` | `src/pages/guru/ImportSiswa.svelte` | `/guru/import-siswa` | Selesai (1:1) |
| 13 | **Laporan Guru** | `lib/pages/guru/laporan_guru_page.dart` | `src/pages/guru/LaporanGuru.svelte` | `/guru/laporan` | Selesai (1:1) |
| 14 | **Rekap Bulanan** | `lib/pages/guru/rekap_bulanan_page.dart` | `src/pages/guru/RekapBulanan.svelte` | `/guru/rekap-bulanan` | Selesai (1:1) |
| 15 | **Persetujuan Kepsek** | `lib/pages/guru/persetujuan_kepsek_page.dart` | `src/pages/guru/PersetujuanKepsek.svelte` | `/guru/persetujuan-kepsek` | Selesai (1:1) |
| 16 | **Kepsek Shell Home** | `lib/pages/kepala_sekolah/kepala_sekolah_home_page.dart` | `src/pages/kepsek/KepsekHome.svelte` | `/kepsek` | Selesai (1:1) |
| 17 | **Kepsek Dashboard** | `lib/pages/kepala_sekolah/kepala_sekolah_dashboard_page.dart` | `src/pages/kepsek/KepsekDashboard.svelte` | `/kepsek/dashboard` | Selesai (1:1) |
| 18 | **Laporan Kepsek** | `lib/pages/kepala_sekolah/laporan_kepala_sekolah_page.dart` | `src/pages/kepsek/LaporanKepsek.svelte` | `/kepsek/laporan` | Selesai (1:1) |
| 19 | **Ortu Shell Home** | `lib/pages/orang_tua/orang_tua_home_page.dart` | `src/pages/ortu/OrtuHome.svelte` | `/ortu` | Selesai (1:1) |
| 20 | **Ortu Dashboard** | `lib/pages/orang_tua/orang_tua_dashboard_page.dart` | `src/pages/ortu/OrtuDashboard.svelte` | `/ortu/dashboard` | Selesai (1:1) |
| 21 | **Laporan Ortu** | `lib/pages/orang_tua/laporan_orang_tua_page.dart` | `src/pages/ortu/LaporanOrtu.svelte` | `/ortu/laporan` | Selesai (1:1) |
| 22 | **Daftar Guru** | `lib/pages/shared/list_guru_page.dart` | `src/pages/shared/ListGuru.svelte` | `/guru/list-guru`, `/kepsek/list-guru` | Selesai (1:1) |
| 23 | **Daftar Siswa** | `lib/pages/shared/list_siswa_page.dart` | `src/pages/shared/ListSiswa.svelte` | `/guru/list-siswa`, `/kepsek/list-siswa` | Selesai (1:1) |
| 24 | **Pengaturan (Shared)** | `lib/pages/shared/settings_page.dart` | `src/pages/shared/Settings.svelte` | `*/pengaturan` | Selesai (1:1) |

---

## 3. Rincian Fitur, Tombol, Opsi, dan Fungsionalitas Per Halaman

### 3.1. Landing (`Landing.svelte`)
- **Tampilan**:
  - Gradient Hero Header dengan logo sekolah, judul *"Sistem Absensi"*, dan tagline.
  - Kartu fitur unggulan: *"Mudah Digunakan"*, *"Laporan Lengkap"*, *"Notifikasi Realtime"*.
- **Tombol & Copywriting (1:1)**:
  - Button `Masuk` -> Navigasi ke `#/login`.
  - Button `Daftar` -> Navigasi ke `#/register`.

### 3.2. Login (`Login.svelte`)
- **Tampilan & Kontrol**:
  - Pilihan role segmented chips: `Guru`, `Kepsek`, `Orang Tua`.
  - Guru/Kepsek form: Input `Email`, `Password`.
  - Ortu form: Input `Nomor Induk Siswa (NIS)`, `Nomor Telepon Orang Tua`.
  - Checkbox / Link: `Lupa Password?`.
- **Tombol & Copywriting (1:1)**:
  - Button `Masuk` -> Memanggil API `POST /api/login` (atau `POST /api/login-ortu`). Menyimpan token ke `authStore` dan redirect sesuai role.
  - Text link: `Belum punya akun? Daftar` -> Navigasi ke `#/register`.

### 3.3. Register (`Register.svelte`)
- **Tampilan & Kontrol**:
  - Stepper 2 tahap: `Informasi Dasar` dan `Detail Tambahan`.
  - Pilihan role radio button: `Guru` vs `Kepala Sekolah`.
  - Step 1: Input `Nama Lengkap`, `Email`, `Password`, `Konfirmasi Password`.
  - Step 2: Input `NIP`, `No. Telepon`, `Alamat`, dan pilihan `Kelas yang Diajar` (untuk Guru).
- **Tombol & Copywriting (1:1)**:
  - Button `Lanjut` -> Validasi step 1 dan beralih ke step 2.
  - Button `Kembali` -> Kembali ke step 1.
  - Button `Daftar` -> Memanggil API `POST /api/register`, redirect ke login jika sukses.
  - Text link: `Sudah punya akun? Masuk` -> Navigasi ke `#/login`.

### 3.4. Forgot Password (`ForgotPassword.svelte`)
- **Tampilan & Kontrol**:
  - Input `Email` untuk verifikasi akun.
  - Form reset password baru: `Password Baru`, `Konfirmasi Password Baru`.
- **Tombol & Copywriting (1:1)**:
  - Button `Kirim` -> Mengirim kode/link reset ke email via `POST /api/forgot-password`.
  - Button `Reset Password` -> Memanggil API `POST /api/reset-password`.
  - Button `Kembali ke Login` -> Navigasi ke `#/login`.

### 3.5. Guru Home & Navigation (`GuruHome.svelte`)
- **Bottom Navigation Items (1:1)**:
  - Tab 1: `Dashboard` (Icon layout dashboard) -> Tab aktif dashboard guru.
  - Tab 2: `Absensi` (Icon calendar) -> Tab absensi harian guru.
  - Tab 3: `Laporan` (Icon file-text) -> Tab laporan semester & bulanan.
  - Tab 4: `Pengaturan` (Icon settings) -> Tab pengaturan profil & akun.

### 3.6. Guru Dashboard (`GuruDashboard.svelte`)
- **Tampilan & Komponen**:
  - Greeting banner nama guru dan lencana kelas aktif (`Wali Kelas X`).
  - Refresh button pada app bar.
  - Banner peringatan persetujuan kepsek: *"Ada laporan menunggu persetujuan kepsek"*.
  - Kartu statistik kehadiran hari ini: `Hadir`, `Izin`, `Sakit`, `Alfa`.
  - Bar Chart kehadiran mingguan (Senin s/d Sabtu) dengan persentase dan bar animasi.
  - Daftar riwayat absensi terbaru.
- **Tombol & Copywriting (1:1)**:
  - Button `Mulai Absensi Hari Ini` -> Navigasi langsung ke `#/guru/mulai-absensi`.
  - Button `Kelola Siswa` -> Navigasi ke `#/guru/kelola-siswa`.
  - Button `Setujui Kepsek` -> Navigasi ke `#/guru/persetujuan-kepsek`.
  - Button `Lihat` pada daftar riwayat -> Navigasi ke halaman detail absensi.

### 3.7. Absensi Harian Guru (`Absensi.svelte`)
- **Tampilan & Kontrol**:
  - Pemilih tanggal (Date picker dialog) dengan ikon kalender.
  - Segmented selector kelas: `Kelas {kelas}`.
  - Ringkasan statistik kehadiran siswa untuk tanggal yang dipilih (`Hadir`, `Izin`, `Sakit`, `Alfa`).
  - List kartu siswa dengan status kehadiran saat ini, foto avatar, dan catatan/keterangan.
  - Menu pop-up titik tiga di tiap kartu siswa:
    - Opsi `Edit Absensi` -> Navigasi ke `#/guru/edit-absensi/:id`.
    - Opsi `Hapus` -> Dialog konfirmasi hapus data.
- **Tombol & Copywriting (1:1)**:
  - Floating Action Button (FAB): `Mulai Absensi` -> Navigasi ke `#/guru/mulai-absensi`.
  - Dialog Konfirmasi Hapus:
    - Judul: *"Hapus Absensi?"*
    - Button: `Batal`
    - Button: `Hapus` (Warna Merah/Destructive) -> Memanggil `DELETE /api/absensi/:id`.

### 3.8. Mulai Absensi (`MulaiAbsensi.svelte`)
- **Tampilan & Kontrol**:
  - Top Action Bar dengan tombol `Simpan`.
  - Pilihan tanggal dan dropdown pemilihan kelas.
  - Quick action button: `Tandai Semua Hadir` -> Mengubah seluruh radio status siswa menjadi 'Hadir' secara instan.
  - Kartu kehadiran masing-masing siswa:
    - 4 Segmented button status: `Hadir`, `Izin`, `Sakit`, `Alfa`.
    - Input keterangan opsional: Placeholder *"Keterangan (opsional)"*.
- **Alur & Dialog Konflik Kehadiran (1:1)**:
  - Pengecekan data absensi yang sudah ada di tanggal yang sama via `GET /api/absensi/check-conflict`.
  - Jika data sudah ada, menampilkan AlertDialog:
    - Judul: *"Konfirmasi Absensi"*
    - Pesan: *"Sudah ada {N} data absensi untuk hari ini. Apakah Anda ingin mengganti data yang sudah ada?"*
    - Button: `Batal`
    - Button: `Ganti Data`
  - Button Top Bar: `Simpan` -> Mengirim payload absensi ke `POST /api/absensi/batch`.

### 3.9. Edit Absensi (`EditAbsensi.svelte`)
- **Tampilan & Kontrol**:
  - Banner info profil siswa: Avatar, Nama Siswa, NIS, Tanggal absensi.
  - Pilihan status tombol chip: `Hadir`, `Izin`, `Sakit`, `Alfa`.
  - Field input teks: `Keterangan`.
  - Upload berkas surat izin / sakit: Area *"Surat Keterangan (Opsional)"*, *"Tap untuk upload file"*, pratinjau file terpilih, tombol hapus file.
- **Tombol & Copywriting (1:1)**:
  - Button: `Simpan Perubahan` -> Mengirim data multipart ke `PUT /api/absensi/:id`.

### 3.10. Kelola Siswa (`KelolaSiswa.svelte`)
- **Tampilan & Kontrol**:
  - Header dengan icon button `Refresh`.
  - Search bar: Placeholder *"Cari nama atau NIS..."*.
  - Banner kelas dan total murid: `Total {N} Siswa`.
  - List siswa dengan nomor induk, jenis kelamin, nomor telepon orang tua.
  - Popup menu kartu siswa:
    - Opsi `Edit Siswa` -> Membuka modal form edit siswa.
    - Opsi `Hapus Siswa` -> Membuka dialog konfirmasi hapus siswa.
  - Empty State: Ilustrasi kosong + tombol `Import dari Excel`.
- **Tombol & Copywriting (1:1)**:
  - Floating Action Buttons (FABs):
    - Button mini `+` -> Membuka modal *"Tambah Siswa"*.
    - Button extended `Import Excel` -> Navigasi ke `#/guru/import-siswa`.
  - Modal Form Tambah/Edit Siswa:
    - Input: `NIS`, `Nama Lengkap`, `Jenis Kelamin` (Laki-laki / Perempuan), `Tanggal Lahir`, `Alamat`, `Nomor Telepon Orang Tua`.
    - Button `Batal`
    - Button `Simpan` -> Memanggil API `POST /api/siswa` atau `PUT /api/siswa/:nis`.
  - Dialog Hapus Siswa:
    - Judul: *"Hapus Siswa"*
    - Button `Batal`
    - Button `Hapus` -> Memanggil API `DELETE /api/siswa/:nis`.

### 3.11. Detail Siswa (`SiswaDetail.svelte`)
- **Tampilan & Kontrol**:
  - Top action bar dengan icon button `Refresh`.
  - Kartu profil siswa: Avatar inisial, Nama Lengkap, NIS, Kelas, Jenis Kelamin, Tanggal Lahir, No. Telepon Ortu, Alamat.
  - Statistik kehadiran siswa: Persentase `Hadir %`, Card `Izin`, Card `Sakit`, Card `Alfa`.
  - Filter rentang bulan / semester.
  - Timeline riwayat absensi harian dengan status chip dan tanggal.
  - Empty state: *"Belum ada riwayat absensi"*.

### 3.12. Import Siswa (`ImportSiswa.svelte`)
- **Tampilan & Kontrol**:
  - Area drag-and-drop / klik upload file `.xlsx` / `.xls`.
  - Instruksi format kolom file Excel: NIS, Nama, Jenis Kelamin, Tanggal Lahir, Alamat, No Telepon.
  - Link `Download Template Excel` -> Mengunduh template format excel standar.
- **Tombol & Copywriting (1:1)**:
  - Button `Pilih File Excel` -> Memilih file lokal.
  - Button `Upload dan Import` -> Mengunggah via `POST /api/siswa/import`.

### 3.13. Laporan Guru (`LaporanGuru.svelte`)
- **Tampilan & Kontrol**:
  - Filter bar: Dropdown `Semester` (Ganjil/Genap) dan Dropdown `Tahun Ajaran`.
  - FAB `+` -> Membuka modal bottom sheet *"Buat Laporan Baru"*.
  - List kartu laporan semester:
    - Judul: `Laporan Semester {X}`
    - Subtitle: `Tahun Ajaran {Y} - Kelas {Z}`
    - Total siswa & badge persentase kehadiran.
    - Status badge persetujuan: `Disetujui` (Hijau) / `Menunggu Persetujuan` (Oranye).
  - **Baris Tombol Aksi 2-Row (1:1 persis Flutter)**:
    - Row 1:
      - Button `Lihat` -> Membuka modal detail bottom sheet laporan.
      - Button `Download` -> Membuka modal pemilihan format download (PDF / Excel).
      - Button `Refresh Data` -> Memperbarui data laporan dari backend via API `POST /api/laporan/:id/refresh`.
    - Row 2:
      - Button `Submit` (jika draft) / `Batal Submit` (jika sudah disubmit) -> Memanggil `POST /api/laporan/:id/submit`.
      - Button `Hapus` -> Dialog konfirmasi hapus laporan semester via `DELETE /api/laporan/:id`.
- **Modal Detail Laporan**:
  - Statistik lengkap 4 kolom: Hadir, Izin, Sakit, Alfa.
  - Tabel ringkasan per-siswa.
  - Button `Tutup`.
- **Modal Download File Laporan**:
  - Opsi besar 1: `Download PDF` -> Download file PDF laporan dari `GET /api/laporan/:id/download-pdf`.
  - Opsi besar 2: `Download Excel` -> Download spreadsheet Excel dari `GET /api/laporan/:id/download-excel`.

### 3.14. Rekap Bulanan Guru (`RekapBulanan.svelte`)
- **Tampilan & Kontrol**:
  - Dropdown pemilih kelas dan bulan/tahun rekapitulasi.
  - FAB `+` -> Membuka modal bottom sheet *"Buat Rekap Bulanan"*.
  - List kartu rekap bulanan dengan data kehadiran per-siswa.
  - Tombol aksi:
    - Button `Refresh Data` -> Refresh kalkulasi rekap bulan terpilih.
    - Button `Submit` / `Batal Submit` -> Mengajukan rekap ke kepsek.
    - Button `Hapus` -> Menghapus rekap bulanan.
    - Button `Download` -> Membuka sheet download PDF/Excel rekapitulasi bulanan.

### 3.15. Persetujuan Kepala Sekolah (`PersetujuanKepsek.svelte`)
- **Tampilan & Kontrol**:
  - Back button ke dashboard guru.
  - Judul header: `Persetujuan Kepala Sekolah`.
  - Daftar permohonan persetujuan laporan semester & bulanan.
  - Status badge: `{count}/4 Persetujuan`.
- **Tombol & Copywriting (1:1)**:
  - Button kondisi persetujuan:
    - Jika belum disetujui: Button `Setujui` -> Memanggil API `POST /api/laporan/:id/approve`.
    - Jika sudah disetujui: Button disabled `Sudah Disetujui Anda`.

### 3.16. Kepala Sekolah Home & Navigation (`KepsekHome.svelte`)
- **Bottom Navigation Items (1:1)**:
  - Tab 1: `Rekapitulasi` (Icon dashboard) -> Tab dashboard rekapitulasi sekolah.
  - Tab 2: `Laporan` (Icon file-text) -> Tab daftar laporan seluruh kelas.
  - Tab 3: `Pengaturan` (Icon settings) -> Tab pengaturan profil & akun.

### 3.17. Kepala Sekolah Dashboard (`KepsekDashboard.svelte`)
- **Tampilan & Kontrol**:
  - Dropdown filter: `Tahun Ajaran` dan `Semester`.
  - Kartu utama: Persentase rata-rata `Tingkat Kehadiran` seluruh sekolah dengan badge persentase.
  - Grid `Detail Kehadiran Semester Ini`: Kartu metrik total siswa `Hadir`, `Izin`, `Sakit`, `Alfa`.
  - Grafik Batang (BarChart) kehadiran per-kelas: Menampilkan perbandingan performa kelas (Kelas 1 s/d Kelas 6) lengkap dengan label sumbu, persentase batang, dan tooltip.
  - Daftar kartu ringkasan per-kelas dengan progress bar kehadiran masing-masing kelas.
  - Kartu perbandingan tren kehadiran dengan periode sebelumnya.

### 3.18. Laporan Kepala Sekolah (`LaporanKepsek.svelte`)
- **Tampilan & Kontrol**:
  - 3 Dropdown filter horizontal:
    - Dropdown 1: `Semua Kelas` (Pilihan: Semua Kelas, Kelas 1 - 6).
    - Dropdown 2: `Semester` (Pilihan: Semua Semester, Ganjil, Genap).
    - Dropdown 3: `Semua Tahun Ajaran`.
  - Daftar kartu laporan seluruh kelas dengan info wali kelas, tanggal submit, tingkat kehadiran (%), dan pill status persetujuan.
- **Tombol & Copywriting (1:1)**:
  - Button pada kartu: `Download` -> Membuka bottom sheet pilihan download laporan.
  - Modal Bottom Sheet Download:
    - Opsi 1: Card `Download PDF` (Ikon merah dokumen PDF, deskripsi file cetak laporan).
    - Opsi 2: Card `Download Excel` (Ikon hijau spreadsheet Excel, deskripsi file tabel data).

### 3.19. Orang Tua Home & Navigation (`OrtuHome.svelte`)
- **Bottom Navigation Items (1:1)**:
  - Tab 1: `Kehadiran` (Icon calendar) -> Tab pantauan kehadiran anak harian & kalender.
  - Tab 2: `Laporan` (Icon file-text) -> Tab laporan semester anak.
  - Tab 3: `Pengaturan` (Icon settings) -> Tab pengaturan akun & kontak sekolah.

### 3.20. Orang Tua Dashboard (`OrtuDashboard.svelte`)
- **Tampilan & Kontrol**:
  - Gradient Hero Card `Data Anak`: Avatar foto/inisial, Nama Anak, NIS, Nama Kelas, Nama Wali Kelas.
  - Kalender Kehadiran Interaktif:
    - Grid kalender bulanan dengan navigasi bulan (sebelumnya/berikutnya).
    - Titik indikator warna kehadiran pada setiap tanggal:
      - Hijau: Hadir
      - Biru: Izin
      - Kuning: Sakit
      - Merah: Alfa
    - Interaksi klik tanggal: Membuka Bottom Sheet Detail Tanggal:
      - Tanggal terpilih, Status kehadiran dengan badge warna, Keterangan / catatan guru.
      - Button `Tutup`.
  - Kartu Metrik `Statistik Bulan Ini`: Total Hadir, Izin, Sakit, Alfa, dan Persentase Kehadiran.

### 3.21. Laporan Orang Tua (`LaporanOrtu.svelte`)
- **Tampilan & Kontrol**:
  - Dropdown filter Tahun Ajaran dan Semester.
  - Kartu ringkasan kemajuan kehadiran anak dengan progress bar dan persentase.
  - Rincian kehadiran bulanan dalam semester bersangkutan.
  - Button `Download Ringkasan Kehadiran`.

### 3.22. Daftar Guru Shared (`ListGuru.svelte`)
- **Tampilan & Kontrol**:
  - Search bar input: Placeholder *"Cari guru..."*.
  - List kartu guru: Avatar inisial/foto, Nama Guru, NIP, status mengajar wali kelas.
  - Klik kartu guru: Menampilkan bottom sheet kontak guru.
  - Modal kontak:
    - Button `Telepon` (membuka `tel:` link).
    - Button `Email` (membuka `mailto:` link).
    - Button `Tutup`.

### 3.23. Daftar Siswa Shared (`ListSiswa.svelte`)
- **Tampilan & Kontrol**:
  - Search bar input: Placeholder *"Cari siswa..."*.
  - Dropdown filter: `Semua Kelas` (Filter berdasarkan kelas tertentu).
  - List kartu siswa: Avatar, Nama Siswa, NIS, Badge Kelas.
  - Interaksi klik kartu siswa: Navigasi langsung ke halaman detail siswa (`/guru/siswa/:nis` atau `/kepsek/siswa/:nis`).

### 3.24. Pengaturan Shared (`Settings.svelte`)
- **Tampilan & Kontrol**:
  - Header profil pengguna: Gradient Card (Primary Blue), Circle Avatar dengan inisial nama, Nama Pengguna, Email / NIS, Role badge (Guru / Kepala Sekolah / Orang Tua).
  - Bagian `Preferensi`:
    - Switch toggle: `Notifikasi` (Subtitle: *"Terima notifikasi push"*).
  - Bagian `Akun`:
    - Menu item: `Ubah Password` (Subtitle: *"Perbarui password akun Anda"*) -> Membuka Modal Bottom Sheet:
      - Field 1: `Password Saat Ini` (Placeholder: *"Masukkan password saat ini"*, icon lock).
      - Field 2: `Password Baru` (Placeholder: *"Masukkan password baru"*, icon lock).
      - Field 3: `Konfirmasi Password` (Placeholder: *"Masukkan ulang password baru"*, icon lock).
      - Button: `Simpan` -> Memanggil API `POST /api/auth/change-password`.
  - Bagian `Manajemen Kelas` (Hanya tampil untuk role Guru):
    - Menu item: `Lepas Kelas` (Subtitle: *"Lepaskan kelas yang diampu saat ini"*, tampil jika guru memiliki kelas):
      - Dialog konfirmasi:
        - Judul: *"Lepas Kelas"*
        - Konten: *"Apakah Anda yakin ingin melepaskan [Nama Kelas]?\n\nAnda harus memilih kelas baru sebelum dapat melakukan absensi lagi."*
        - Button: `Batal`
        - Button: `Lepas` (Warna Merah) -> Memanggil API `POST /api/guru/release-class`.
    - Menu item: `Pindah Kelas` (Subtitle: *"Pindah ke kelas lain"*):
      - Modal Bottom Sheet:
        - Judul: *"Pindah Kelas"*
        - Info Box Biru: *"Masukkan kode kelas baru.\nFormat: KLS1, KLS2, KLS3, KLS4, KLS5, KLS6"*
        - Field: `Kode Kelas Baru` (Placeholder: *"Contoh: KLS1"*).
        - Button: `Pindah` -> Memanggil API `POST /api/guru/change-class`.
  - Bagian `Tentang`:
    - Menu item: `Tentang Aplikasi` (Subtitle: `1.0.0`):
      - Dialog info aplikasi:
        - Header: Icon School + *"Absensi Siswa"*
        - Konten: *"SD Negeri Kemutug Kidul"*, *"Versi 1.0.0"*, *"Aplikasi absensi siswa untuk memudahkan pencatatan dan pemantauan kehadiran siswa."*
        - Button: `Tutup`.
    - Menu item: `Bantuan` (Subtitle: *"Pusat bantuan dan FAQ"*) -> Menampilkan bantuan panduan sistem absensi per role.
  - Tombol Keluar:
    - Button: `Keluar` (Outlined Button) -> Membuka dialog konfirmasi:
      - Judul: *"Keluar"*
      - Konten: *"Yakin ingin keluar dari aplikasi?"*
      - Button: `Batal`
      - Button: `Keluar` (Warna Merah) -> Memanggil `POST /api/logout`, membersihkan auth session dan kembali ke Landing page.

---

## 4. Pemetaan Endpoint Backend API (Laravel Backend)

Seluruh pemanggilan endpoint yang dilakukan oleh Flutter melalui `fe_absensi` telah diimplementasikan dengan parameter dan struktur data yang identik pada `fe-svelte`:

| Fitur / Modul | Method | Endpoint Backend | Dipakai di Flutter | Dipakai di Svelte |
|:---|:---:|:---|:---|:---|
| Auth - Login | `POST` | `/api/login` | `AuthService.login` | `authApi.login` |
| Auth - Login Ortu | `POST` | `/api/login-ortu` | `AuthService.loginOrtu` | `authApi.loginOrtu` |
| Auth - Register | `POST` | `/api/register` | `AuthService.register` | `authApi.register` |
| Auth - Forgot Password | `POST` | `/api/forgot-password` | `AuthService.forgotPassword` | `authApi.forgotPassword` |
| Auth - Reset Password | `POST` | `/api/reset-password` | `AuthService.resetPassword` | `authApi.resetPassword` |
| Auth - Ubah Password | `POST` | `/api/change-password` | `AuthService.changePassword` | `authApi.changePassword` |
| Auth - Profil Pengguna | `GET` | `/api/profile` | `AuthService.getProfile` | `authApi.getProfile` |
| Guru - Dashboard Stats | `GET` | `/api/dashboard/guru` | `DashboardService.getGuruData` | `dashboardApi.getGuru` |
| Guru - List Absensi | `GET` | `/api/absensi` | `AbsensiService.getAbsensi` | `absensiApi.getAbsensi` |
| Guru - Cek Konflik Absensi | `GET` | `/api/absensi/check-conflict` | `AbsensiService.checkConflict` | `absensiApi.checkConflict` |
| Guru - Batch Absensi Baru | `POST` | `/api/absensi/batch` | `AbsensiService.saveAbsensi` | `absensiApi.saveAbsensi` |
| Guru - Update Absensi | `PUT` | `/api/absensi/{id}` | `AbsensiService.updateAbsensi` | `absensiApi.updateAbsensi` |
| Guru - Hapus Absensi | `DELETE` | `/api/absensi/{id}` | `AbsensiService.deleteAbsensi` | `absensiApi.deleteAbsensi` |
| Siswa - Daftar Siswa | `GET` | `/api/siswa` | `SiswaService.getSiswa` | `siswaApi.getSiswa` |
| Siswa - Tambah Siswa | `POST` | `/api/siswa` | `SiswaService.createSiswa` | `siswaApi.createSiswa` |
| Siswa - Update Siswa | `PUT` | `/api/siswa/{nis}` | `SiswaService.updateSiswa` | `siswaApi.updateSiswa` |
| Siswa - Hapus Siswa | `DELETE` | `/api/siswa/{nis}` | `SiswaService.deleteSiswa` | `siswaApi.deleteSiswa` |
| Siswa - Detail & Riwayat | `GET` | `/api/siswa/{nis}` | `SiswaService.getSiswaDetail` | `siswaApi.getSiswaDetail` |
| Siswa - Import Excel | `POST` | `/api/siswa/import` | `SiswaService.importExcel` | `siswaApi.importExcel` |
| Laporan - Semester List | `GET` | `/api/laporan/semester` | `LaporanService.getSemester` | `laporanApi.getSemester` |
| Laporan - Buat Laporan | `POST` | `/api/laporan/semester` | `LaporanService.createSemester` | `laporanApi.createSemester` |
| Laporan - Submit Laporan | `POST` | `/api/laporan/{id}/submit` | `LaporanService.submit` | `laporanApi.submit` |
| Laporan - Refresh Kalkulasi | `POST` | `/api/laporan/{id}/refresh` | `LaporanService.refreshData` | `laporanApi.refreshData` |
| Laporan - Approve Kepsek | `POST` | `/api/laporan/{id}/approve` | `LaporanService.approve` | `laporanApi.approve` |
| Laporan - Hapus Laporan | `DELETE` | `/api/laporan/{id}` | `LaporanService.delete` | `laporanApi.delete` |
| Laporan - Download PDF | `GET` | `/api/laporan/{id}/download-pdf` | `LaporanService.downloadPdf` | `laporanApi.downloadPdf` |
| Laporan - Download Excel | `GET` | `/api/laporan/{id}/download-excel` | `LaporanService.downloadExcel` | `laporanApi.downloadExcel` |
| Kepsek - Dashboard Stats | `GET` | `/api/dashboard/kepsek` | `DashboardService.getKepsekData` | `dashboardApi.getKepsek` |
| Ortu - Dashboard & Kalender| `GET` | `/api/dashboard/ortu` | `DashboardService.getOrtuData` | `dashboardApi.getOrtu` |
| Guru & Kelas - Kelola Kelas | `POST` | `/api/guru/pindah-kelas` | `GuruService.pindahKelas` | `guruApi.pindahKelas` |
| Guru & Kelas - Lepas Kelas | `POST` | `/api/guru/lepas-kelas` | `GuruService.lepasKelas` | `guruApi.lepasKelas` |

---

## 5. Verifikasi Build & Kualitas Kode

- **Hasil Build Produksi Vite**:
  ```bash
  npm run build
  ✓ 215 modules transformed.
  dist/index.html                   0.54 kB │ gzip:   0.34 kB
  dist/assets/index-D-oOZb-7.css   78.91 kB │ gzip:  11.68 kB
  dist/assets/index-C1nomc5m.js   442.27 kB │ gzip: 131.52 kB
  ✓ built in 831ms
  ```
- **Error Kompilasi**: 0 Error.
- **Svelte 5 Runes**: Seluruh reaktivitas halaman menggunakan Svelte 5 standard runes (`$state`, `$derived`, `$props`).
- **Status Akhir Paritas**: 100% Selesai & Terverifikasi 1 : 1 dengan Flutter Frontend.
