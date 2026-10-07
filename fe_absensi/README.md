# Absensi SD

Proyek ini adalah aplikasi absensi sekolah dasar yang terdiri dari dua bagian utama:

- Frontend mobile: Flutter di folder `fe_absensi`
- Backend API: Laravel di folder `api/absensi-api`
- Database: file SQL `absensi_sd.sql`

Secara umum, aplikasi ini digunakan untuk mencatat kehadiran siswa, membagi akses per peran (guru, kepala sekolah, dan orang tua), serta menampilkan laporan dan statistik kehadiran secara real-time.

## Apa yang sebenarnya dibuat?

Ini bukan hanya aplikasi sederhana untuk menandai hadir/izin/sakit. Proyek ini adalah sistem manajemen absensi sekolah berbasis web API + mobile app, dengan alur kerja seperti:

1. Guru login ke aplikasi.
2. Guru memilih kelas dan siswa yang diajarnya.
3. Guru mencatat absensi harian siswa dengan status seperti hadir, izin, sakit, atau alfa.
4. Sistem menyimpan data absensi ke database MySQL.
5. Kepala sekolah dapat melihat statistik per kelas dan performa sekolah secara keseluruhan.
6. Orang tua dapat memantau status kehadiran anaknya.

## Peran pengguna

### 1. Guru
- Login menggunakan akun guru
- Mengelola kelas yang diampu
- Mencatat absensi harian siswa
- Melihat laporan kelas dan rekap siswa
- Mengakses dashboard statistik kehadiran

### 2. Kepala Sekolah
- Mengetahui kondisi sekolah secara umum
- Melihat performa masing-masing kelas
- Menilai tingkat kedisiplinan siswa berdasarkan data absensi
- Mengakses dashboard sekolah dan perbandingan kelas

### 3. Orang Tua
- Melihat data kehadiran anak
- Memantau status hadir/izin/sakit/alfa
- Mengetahui laporan perkembangan kehadiran anak

## Fitur utama

- Autentikasi login dan registrasi
- Validasi akun berdasarkan role: guru, kepala sekolah, orang tua
- Register dengan validasi khusus, misalnya:
  - Guru harus memasukkan kode sekolah dan kode kelas
  - Orang tua harus memasukkan NIS dan nama anak yang valid
- Dashboard per role
- CRUD data siswa, guru, kelas, dan orang tua
- Absensi harian berbasis tanggal
- Laporan absensi per kelas dan per siswa
- Rekap bulanan dan statistik kehadiran
- API backend berbasis Laravel untuk komunikasi antar aplikasi dan database

## Struktur proyek

```text
absensi/
├── absensi_sd.sql               # Dump database MySQL
├── api/
│   └── absensi-api/            # Laravel backend API
│       ├── app/
│       ├── config/
│       ├── database/
│       ├── routes/
│       └── ...
├── fe_absensi/                  # Flutter frontend
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── pubspec.yaml
└── README.md                   # Dokumentasi proyek
```

## Teknologi yang digunakan

### Frontend
- Flutter
- Dart
- Provider untuk state management
- Material Design UI

### Backend
- PHP
- Laravel 10
- REST API
- Sanctum untuk autentikasi

### Database
- MySQL
- File dump: `absensi_sd.sql`

## Database utama

Tabel yang terlihat dalam proyek antara lain:

- `guru`
- `kepala_sekolah`
- `orang_tua`
- `siswa`
- `kelas`
- `absensi`
- `laporan`
- `rekap_bulanan` (disebut dalam route API)

Data di dalam `absensi` mencatat:
- `nis` siswa
- `nip` guru yang mencatat
- `tanggal`
- `status_kehadiran` (hadir, izin, sakit, alfa)
- `keterangan`
- `time_input`

## Alur kerja aplikasi

### Untuk guru
- Login
- Pilih kelas
- Input absensi siswa per hari
- Simpan data absensi
- Lihat statistik dan rekap

### Untuk kepala sekolah
- Login
- Buka dashboard sekolah
- Cek laporan kelas
- Mencari kualitas kehadiran tiap kelas

### Untuk orang tua
- Login
- Lihat daftar siswa yang terdaftar
- Cek apakah anak hadir, sakit, izin, atau alfa

## Kesimpulan singkat

Proyek ini adalah sistem akademik dan operasional sekolah yang fokus pada pencatatan kehadiran siswa. Tujuan utamanya adalah:

- mempercepat proses absensi
- meminimalkan pencatatan manual
- menampilkan laporan dan statistik dengan lebih rapi
- membuat data kehadiran lebih mudah dipantau oleh guru, kepala sekolah, dan orang tua

Ini adalah proyek full-stack yang siap dikembangkan lebih lanjut untuk kebutuhan sekolah yang lebih besar, misalnya dengan fitur export PDF/Excel, notifikasi otomatis, atau integrasi presensi berbasis QR code.

## Setup cepat

### 1. Setup backend Laravel
```bash
cd api/absensi-api
composer install
cp .env.example .env
php artisan key:generate
```

Sesuaikan konfigurasi database di `.env` lalu jalankan:

```bash
php artisan migrate
php artisan serve
```

### 2. Setup frontend Flutter
```bash
cd fe_absensi
flutter pub get
flutter run
```

### 3. Import database
Gunakan file `absensi_sd.sql` untuk database MySQL yang sudah disiapkan.

## Catatan penting

- Proyek ini sudah memiliki struktur yang cukup lengkap untuk sistem absensi sekolah.
- Frontend dan backend dipisah dengan jelas, sehingga mudah dikembangkan dan dipelihara.
- API Laravel berfungsi sebagai layer utama untuk autentikasi, transaksi absensi, dan laporan.
- Flutter berperan sebagai antarmuka pengguna yang dapat dijalankan di perangkat mobile.

Dengan kata lain, program ini adalah aplikasi absensi sekolah digital yang menghubungkan data siswa, guru, kelas, dan orang tua dalam satu ekosistem.
