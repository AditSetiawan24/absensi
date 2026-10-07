# Absensi API - SD Negeri Kemutung Kidul

REST API untuk aplikasi absensi siswa SD Negeri Kemutung Kidul. Dibangun menggunakan Laravel 10.

## Fitur

- **Autentikasi**: Login, Register, Ganti Password untuk Guru, Kepala Sekolah, dan Orang Tua
- **Manajemen Guru**: CRUD data guru dengan fitur lepas/pindah kelas
- **Manajemen Siswa**: CRUD data siswa
- **Manajemen Kelas**: CRUD data kelas
- **Absensi**: Pencatatan absensi harian siswa (Hadir, Izin, Sakit, Alpha)
- **Laporan**: Generate laporan absensi per kelas/siswa
- **Dashboard**: Statistik kehadiran untuk Guru, Kepala Sekolah, dan Orang Tua

## Requirements

- PHP >= 8.1
- Composer
- MySQL >= 5.7
- Laravel 10.x

## Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/username/absensi-api.git
cd absensi-api
```

### 2. Install Dependencies

```bash
composer install
```

### 3. Setup Environment

```bash
cp .env.example .env
php artisan key:generate
```

### 4. Konfigurasi Database

Edit file `.env` dan sesuaikan konfigurasi database:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=absensi_db
DB_USERNAME=root
DB_PASSWORD=your_password
```

### 5. Import Database

Import file SQL database yang disediakan atau jalankan migration:

```bash
php artisan migrate
php artisan db:seed
```

### 6. Jalankan Server

```bash
php artisan serve
```

API akan berjalan di `http://localhost:8000`

## API Endpoints

### Authentication

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/register` | Registrasi user baru |
| POST | `/api/auth/login` | Login user |
| POST | `/api/auth/change-password` | Ganti password |
| POST | `/api/logout` | Logout (auth required) |

### Guru

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/guru` | List semua guru |
| GET | `/api/guru/{nip}` | Detail guru |
| GET | `/api/guru/my-class` | Info kelas yang diampu |
| POST | `/api/guru/release-class` | Lepas kelas |
| POST | `/api/guru/change-class` | Pindah kelas |

### Siswa

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/siswa` | List semua siswa |
| GET | `/api/siswa/{nis}` | Detail siswa |
| GET | `/api/siswa/by-kelas/{id_kelas}` | Siswa per kelas |

### Kelas

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/kelas` | List semua kelas |
| GET | `/api/kelas/{id}` | Detail kelas |
| GET | `/api/kelas/by-guru/{nip}` | Kelas per guru |

### Absensi

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/absensi` | List absensi |
| GET | `/api/absensi/today` | Absensi hari ini |
| GET | `/api/absensi/by-date` | Absensi per tanggal |
| GET | `/api/absensi/by-siswa/{nis}` | Absensi per siswa |
| GET | `/api/absensi/by-kelas/{id_kelas}` | Absensi per kelas |
| POST | `/api/absensi` | Tambah absensi |
| POST | `/api/absensi/bulk` | Tambah absensi bulk |

### Laporan

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/laporan` | List laporan |
| GET | `/api/laporan/generate` | Generate laporan |
| GET | `/api/laporan/by-kelas/{id}` | Laporan per kelas |
| GET | `/api/laporan/by-orangtua/{id}` | Laporan per orang tua |

### Dashboard

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/dashboard/guru/{nip}` | Dashboard guru |
| GET | `/api/dashboard/kepala-sekolah` | Dashboard kepala sekolah |
| GET | `/api/dashboard/orang-tua/{id_ortu}` | Dashboard orang tua |

## Kode Registrasi

- **Kode Sekolah (Guru)**: `SDN1KK`
- **Kode Kelas**: `KLS1`, `KLS2`, `KLS3`, `KLS4`, `KLS5`, `KLS6`

## Struktur Database

### Tabel Utama
- `guru` - Data guru
- `kepala_sekolah` - Data kepala sekolah
- `orang_tua` - Data orang tua
- `siswa` - Data siswa
- `kelas` - Data kelas
- `absensi` - Data absensi harian
- `laporan` - Data laporan

## Timezone

API menggunakan timezone `Asia/Jakarta` untuk memastikan pencatatan waktu yang akurat.

## License

MIT License
