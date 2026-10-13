# Implementation — Rewrite Frontend Flutter Web → Vite + Svelte + TypeScript

## 1. Ringkasan Proyek

Proyek ini bertujuan mengganti frontend **Absensi SD Negeri Kemutug Kidul** yang saat ini dibangun dengan Flutter Web menjadi **Vite + Svelte + TypeScript**. Backend Laravel 10 + MySQL dan desain UI/UX yang sudah ada **tidak boleh diubah**. Fokus utama: performa lebih ringan, bundle JS lebih kecil, dan kesetaraan fitur serta tampilan.

---

## 2. Tujuan, Ruang Lingkup, dan Batasan

### 2.1 Tujuan
1. Mengurangi ukuran JavaScript yang dikirim ke browser (Flutter Web menghasilkan ≈2–4 MB JS).
2. Mempertahankan seluruh fitur dan perilaku aplikasi Flutter saat ini.
3. Mempertahankan desain UI/UX termasuk warna, tipografi, spacing, komponen, dan interaksi.
4. Menjaga kompatibilitas penuh dengan backend Laravel + MySQL.
5. Menghasilkan kode frontend yang mudah dipelihara, aman, responsif, dan efisien.

### 2.2 Ruang Lingkup
- Rewrite seluruh halaman frontend Flutter ke Svelte.
- Integrasi dengan API Laravel yang sudah ada tanpa modifikasi.
- Deployment ke Vercel.

### 2.3 Di Luar Ruang Lingkup
- Perubahan backend Laravel, route API, controller, atau middleware.
- Perubahan schema database MySQL.
- Redesign UI/UX.
- Penambahan fitur baru yang tidak ada di Flutter saat ini.

---

## 3. Daftar Larangan Perubahan Backend dan Database

**DILARANG mengubah:**
- Source code backend Laravel (`api/absensi-api/`).
- Route API di `routes/api.php`.
- Controller, model, service, middleware, policy, dan mekanisme autentikasi backend.
- Struktur database `absensi_sd` (tabel, kolom, relasi, index, constraint, tipe data).
- Migration, seeder, serta data yang sudah ada.
- Format request dan response API.
- Aturan bisnis dan proses validasi backend.
- Konfigurasi CORS, autentikasi Sanctum, token.
- Konfigurasi deployment backend.
- Tidak boleh membuat migration baru, mengubah schema, atau menjalankan perintah yang memodifikasi database.

---

## 4. Daftar Larangan Perubahan Desain UI/UX

**DILARANG mengubah:**
- Struktur layout dan hierarki visual.
- Warna primer (#2563EB), sekunder (#10B981), dan seluruh palet warna.
- Tipografi Poppins (diganti font sistem — lihat §4.1).
- Spacing, padding, margin, ukuran komponen, dan proporsi layout.
- Border radius (12px input, 16px card, 20px badge, 30px logo), elevation, shadow.
- Desain tombol, input, dropdown, tabel, kartu, dialog, modal, dan navigasi.
- Ikon Material Design yang digunakan.
- Tema terang dan tema gelap.
- Tampilan loading, empty state, error state, dan notifikasi.
- Perilaku hover, focus, active, disabled.
- Responsivitas dan perilaku layout pada berbagai ukuran layar.

### 4.1 Aturan Font
Aplikasi Flutter menggunakan **Google Fonts Poppins** via package `google_fonts`. Frontend baru **tidak boleh** bergantung pada Google Fonts CDN.

**Pengganti yang direkomendasikan:**
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
```

**Perbedaan visual yang diharapkan:**
- Poppins: geometric, huruf 'a' double-story, rounded. Font sistem akan sedikit berbeda pada karakter tertentu.
- Ketebalan font (w500, w600, bold) harus dipertahankan menggunakan `font-weight` CSS yang setara.
- Ukuran font (`14px`, `16px`, `18px`, `24px`, `28px`, `32px`) dan `line-height` harus dipertahankan.
- Jika perbedaan visual terlalu mencolok, pertimbangkan bundling file font Poppins lokal (dari arsip lokal, bukan CDN) — **memerlukan persetujuan user**.

---

## 5. Hasil Audit Arsitektur Flutter Lama

### 5.1 Struktur Direktori Frontend
```
fe_absensi/lib/
├── main.dart                          # Entry point, splash screen, auth routing
├── core/
│   ├── constants/
│   │   ├── api_constants.dart         # Base URL + semua endpoint path
│   │   └── app_constants.dart         # Nama app, roles, status, SharedPref keys
│   └── theme/
│       ├── app_colors.dart            # Seluruh palet warna (light + dark)
│       └── app_theme.dart             # ThemeData light + dark (Poppins)
├── models/
│   ├── user_model.dart                # User (multi-role)
│   ├── absensi_model.dart             # Absensi, TodayStats, WeeklyStats, AbsentStudent, ConsecutiveAbsent
│   ├── siswa_model.dart               # Siswa, Kelas, Guru, OrangTua
│   ├── laporan_model.dart             # Laporan, LaporanGenerated, LaporanDetailKelas, dll.
│   └── dashboard_model.dart           # GuruDashboard, KepalaSekolahDashboard, OrangTuaDashboard, dll.
├── providers/
│   ├── auth_provider.dart             # AuthProvider (ChangeNotifier) — login, register, logout, state
│   └── settings_provider.dart         # SettingsProvider — dark mode, notification toggle
├── services/
│   ├── api_service.dart               # HTTP client terpusat — GET, POST, PUT, DELETE, multipart
│   ├── auth_service.dart              # Login, register, forgot/reset/change password, session mgmt
│   ├── absensi_service.dart           # CRUD absensi, bulk, stats, consecutive
│   ├── dashboard_service.dart         # Dashboard guru/kepsek/ortu
│   ├── data_service.dart              # Siswa, Guru, Kelas, Kepsek service
│   ├── laporan_service.dart           # CRUD laporan, generate, download PDF/Excel, submit/unsubmit
│   └── rekap_bulanan_service.dart     # CRUD rekap bulanan, refresh, submit/unsubmit
├── widgets/
│   └── common_widgets.dart            # CustomTextField, CustomDropdown, CustomButton, StatusBadge, StatCard, LoadingWidget, ErrorWidget, EmptyWidget
├── utils/
│   └── download/
│       └── download_helper.dart       # Conditional export (web/stub)
└── pages/
    ├── auth/
    │   ├── landing_page.dart           # Welcome page dengan tombol Masuk/Daftar
    │   ├── login_page.dart             # Login form dengan pemilihan role
    │   ├── register_page.dart          # Registrasi multi-role
    │   └── forgot_password_page.dart   # Forgot + reset password
    ├── guru/
    │   ├── guru_home_page.dart         # BottomNav container (4 tab)
    │   ├── guru_dashboard_page.dart    # Dashboard guru — stats, chart, absent list
    │   ├── absensi_page.dart           # Daftar absensi + search + filter
    │   ├── mulai_absensi_page.dart     # Form input absensi massal
    │   ├── edit_absensi_page.dart      # Edit absensi individual
    │   ├── kelola_siswa_page.dart      # CRUD siswa + import Excel
    │   ├── siswa_detail_page.dart      # Detail siswa + riwayat absensi
    │   ├── laporan_guru_page.dart      # Kelola laporan semester + rekap bulanan
    │   ├── rekap_bulanan_page.dart     # Rekap bulanan + generate + chart
    │   └── persetujuan_kepsek_page.dart # Approve kepala sekolah
    ├── kepala_sekolah/
    │   ├── kepala_sekolah_home_page.dart         # BottomNav container (3 tab)
    │   ├── kepala_sekolah_dashboard_page.dart     # Rekapitulasi seluruh kelas
    │   └── laporan_kepala_sekolah_page.dart       # Lihat + generate laporan
    ├── orang_tua/
    │   ├── orang_tua_home_page.dart     # BottomNav container (3 tab)
    │   ├── orang_tua_dashboard_page.dart # Dashboard kehadiran anak + calendar
    │   └── laporan_orang_tua_page.dart  # Lihat laporan anak
    └── shared/
        ├── settings_page.dart           # Profil, dark mode, ubah password, kelola kelas, logout
        ├── list_guru_page.dart          # Daftar guru (diakses kepsek)
        └── list_siswa_page.dart         # Daftar siswa (diakses kepsek)
```

### 5.2 State Management
- **Provider** (ChangeNotifier) — 2 provider:
  - `AuthProvider`: user, role, isLoading, error, isAuthenticated.
  - `SettingsProvider`: isDarkMode, isNotificationEnabled.
- Data sesi disimpan di **SharedPreferences** (token, user data JSON, role, userId).

### 5.3 HTTP Client
- `ApiService` — static class, menggunakan package `http`.
- Bearer token disimpan di memori (`_token`) + SharedPreferences.
- Header default: `Content-Type: application/json`, `Accept: application/json`, `Authorization: Bearer {token}`.
- Response format konsisten: `{ success, message, data, errors }`.
- Support multipart upload (`postMultipart`).

### 5.4 Package Pihak Ketiga yang Digunakan

| Package | Versi | Penggunaan Aktual | Pengganti Svelte |
|---------|-------|-------------------|------------------|
| `http` | ^1.2.0 | HTTP client | Fetch API |
| `dio` | ^5.4.0 | Diimpor di pubspec tapi **tidak digunakan** di kode | Tidak perlu |
| `provider` | ^6.1.1 | State management | Svelte stores |
| `shared_preferences` | ^2.2.2 | Penyimpanan sesi lokal | localStorage |
| `file_picker` | ^6.1.1 | Memilih file untuk import Excel | `<input type="file">` |
| `path_provider` | ^2.1.2 | Path file (mobile) | Tidak perlu (web) |
| `open_filex` | ^4.3.4 | Buka file (mobile) | Tidak perlu (web) |
| `pdf` | ^3.10.7 | Generate PDF client-side | jspdf / pdfmake |
| `printing` | ^5.12.0 | Print/preview PDF | Browser print |
| `excel` | ^4.0.3 | Generate Excel client-side | SheetJS (xlsx) |
| `fl_chart` | ^0.66.2 | Grafik bar/line | Chart.js / lightweight alternative |
| `google_fonts` | ^6.1.0 | Font Poppins | Font sistem (lihat §4.1) |
| `flutter_svg` | ^2.0.9 | Render SVG | Native `<img>` / inline SVG |
| `cached_network_image` | ^3.3.1 | Cache gambar | Native `<img>` + browser cache |
| `shimmer` | ^3.0.0 | Loading skeleton | CSS shimmer animation |
| `intl` | ^0.19.0 | Format tanggal Indonesia | `Intl.DateTimeFormat` / date-fns |
| `table_calendar` | ^3.0.9 | Widget kalender | Custom calendar component |
| `share_plus` | ^7.2.1 | Share (mobile) | Web Share API / copy link |
| `url_launcher` | ^6.2.4 | Buka URL/WhatsApp | `window.open()` |
| `image_picker` | ^1.0.7 | Pilih foto (mobile) | `<input type="file" accept="image/*">` |
| `permission_handler` | ^11.3.0 | Permission (mobile) | Tidak perlu (web) |

---

## 6. Inventaris Halaman, Fitur, Role, dan Komponen

### 6.1 Role Pengguna
| Role | Kode Backend | Deskripsi |
|------|-------------|-----------|
| Guru | `guru` | Wali kelas — absensi, kelola siswa, laporan, persetujuan kepsek |
| Kepala Sekolah | `kepala_sekolah` | Rekapitulasi seluruh kelas, laporan, melihat daftar guru/siswa |
| Orang Tua | `orang_tua` | Melihat kehadiran dan laporan anak |

### 6.2 Inventaris Halaman

| # | Halaman | Role | Fitur Utama |
|---|---------|------|------------|
| 1 | Splash Screen | Semua | Cek auth → redirect |
| 2 | Landing Page | Guest | Info app, tombol Masuk/Daftar |
| 3 | Login Page | Guest | Form login, pilih role (chip), validasi |
| 4 | Register Page | Guest | Form registrasi multi-role, validasi kode sekolah/kelas (guru), verifikasi NIS (ortu) |
| 5 | Forgot Password Page | Guest | Form lupa password + reset password |
| 6 | Guru Dashboard | Guru | Stats kehadiran hari ini, grafik mingguan, absent today, consecutive absent, info kelas |
| 7 | Absensi Page | Guru | Daftar absensi, filter tanggal, mulai absensi baru |
| 8 | Mulai Absensi Page | Guru | Form absensi massal per kelas per tanggal |
| 9 | Edit Absensi Page | Guru | Edit status + keterangan absensi individual |
| 10 | Kelola Siswa Page | Guru | CRUD siswa, import Excel, pencarian |
| 11 | Siswa Detail Page | Guru | Profil siswa, riwayat absensi, statistik |
| 12 | Laporan Guru Page | Guru | Kelola laporan semester, create from absensi, submit/unsubmit, download PDF/Excel |
| 13 | Rekap Bulanan Page | Guru | Rekap bulanan, generate, chart, submit/unsubmit, refresh |
| 14 | Persetujuan Kepsek Page | Guru | Approve kepala sekolah yang pending |
| 15 | Kepsek Dashboard | Kepsek | Info sekolah, stats total, perbandingan kelas, grafik, semester comparison |
| 16 | Laporan Kepsek Page | Kepsek | Lihat laporan semua kelas, generate, download PDF/Excel |
| 17 | Ortu Dashboard | Ortu | Kehadiran anak, statistik per anak, kalender, riwayat ketidakhadiran |
| 18 | Laporan Ortu Page | Ortu | Lihat laporan anak |
| 19 | Settings Page | Semua | Profil, dark/light mode, ubah password, kelola kelas (guru), logout |
| 20 | List Guru Page | Kepsek | Daftar guru dengan info kelas |
| 21 | List Siswa Page | Kepsek | Daftar siswa seluruh sekolah |

### 6.3 Navigasi Per Role

**Guru** — BottomNavigationBar 4 tab:
1. Dashboard → `GuruDashboardPage`
2. Absensi → `AbsensiPage` → `MulaiAbsensiPage`, `EditAbsensiPage`
3. Laporan → `LaporanGuruPage` → `RekapBulananPage`
4. Pengaturan → `SettingsPage` → `PersetujuanKepsekPage`, `KelolaSiswaPage`, `SiswaDetailPage`

**Kepala Sekolah** — BottomNavigationBar 3 tab:
1. Rekapitulasi → `KepalaSekolahDashboardPage` → `ListGuruPage`, `ListSiswaPage`
2. Laporan → `LaporanKepalaSekolahPage`
3. Pengaturan → `SettingsPage`

**Orang Tua** — BottomNavigationBar 3 tab:
1. Kehadiran → `OrangTuaDashboardPage`
2. Laporan → `LaporanOrangTuaPage`
3. Pengaturan → `SettingsPage`

### 6.4 Komponen UI yang Dapat Digunakan Ulang
1. `CustomTextField` — Input field dengan label, ikon, validasi.
2. `CustomDropdown` — Dropdown dengan label.
3. `CustomButton` — Tombol elevated/outlined, loading state, ikon.
4. `StatusBadge` — Badge kehadiran (hadir/izin/sakit/alfa) dengan warna.
5. `StatCard` — Kartu statistik dengan ikon, nilai, judul, subtitle.
6. `LoadingWidget` — Spinner dengan pesan opsional.
7. `CustomErrorWidget` — Error dengan ikon, pesan, tombol retry.
8. `EmptyWidget` — Empty state dengan ikon, pesan, tombol aksi.

---

## 7. Referensi Desain, Tema, dan Aturan Kesetaraan Visual

### 7.1 Palet Warna

```css
/* Primary */
--primary: #2563EB;
--primary-light: #60A5FA;
--primary-dark: #1D4ED8;

/* Secondary */
--secondary: #10B981;
--secondary-light: #34D399;
--secondary-dark: #059669;

/* Background */
--bg-light: #F8FAFC;
--surface-light: #FFFFFF;
--bg-dark: #121212;
--surface-dark: #1E1E1E;
--card-dark: #2C2C2C;

/* Status */
--success: #22C55E;
--warning: #F59E0B;
--error: #EF4444;
--info: #3B82F6;

/* Attendance Status */
--hadir: #22C55E;
--izin: #F59E0B;
--sakit: #9CA3AF;
--alfa: #EF4444;

/* Text */
--text-primary: #1F2937;
--text-secondary: #6B7280;
--text-light: #9CA3AF;
--text-primary-dark: #E5E7EB;
--text-secondary-dark: #9CA3AF;

/* Border */
--border: #E5E7EB;
--divider: #F3F4F6;
--border-dark: #3C3C3C;
--divider-dark: #2C2C2C;
```

### 7.2 Dimensi dan Spacing
- Border radius: `12px` (input, button), `16px` (card), `20px` (badge), `30px` (logo container).
- Padding konten: `24px` (halaman), `16px` (card).
- Card shadow (light): `0 4px 10px rgba(0,0,0,0.05)`.
- Card shadow (dark): `0 4px 10px rgba(0,0,0,0.2)`.
- Input content padding: `16px` horizontal, `16px` vertical.
- Button padding: `12px` vertical, `24px` horizontal.
- BottomNav elevation: `8`.

### 7.3 Tipografi (Ukuran yang Harus Dipertahankan)
| Konteks | Font Size | Font Weight |
|---------|-----------|-------------|
| AppBar title | 18px | w600 (semibold) |
| H1 / App name (landing) | 32px | bold |
| H2 / Selamat datang | 28px | bold |
| Stat card value | 24px | bold |
| Body / label | 16px | w600 |
| Button text | 16px | w600 |
| Input label | 14px | w500 |
| Secondary text | 14px | normal |
| Badge text | 12px | w600 |
| Subtitle | 11px | normal |

---

## 8. Inventaris Endpoint API Laravel (Terverifikasi dari Source Code)

### 8.1 Autentikasi (Public)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/register` | Registrasi (guru/kepsek/ortu) |
| POST | `/api/auth/login` | Login → returns `{token, user, role}` |
| POST | `/api/auth/forgot-password` | Lupa password |
| POST | `/api/auth/reset-password` | Reset password |
| POST | `/api/auth/change-password` | Ubah password |

### 8.2 Protected (auth:sanctum)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/logout` | Logout (revoke token) |
| GET | `/api/profile` | Get profile |
| PUT | `/api/profile/update` | Update profile |

### 8.3 Guru
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/guru` | List semua guru |
| GET | `/api/guru/my-class?nip=` | Info kelas guru |
| POST | `/api/guru/release-class` | Lepas kelas |
| POST | `/api/guru/change-class` | Pindah kelas |
| GET | `/api/guru/{nip}` | Detail guru |

### 8.4 Kepala Sekolah
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/kepala-sekolah` | List |
| GET | `/api/kepala-sekolah/pending` | List pending (auth) |
| POST | `/api/kepala-sekolah/approve` | Approve (auth) |
| GET | `/api/kepala-sekolah/{nip}` | Detail |

### 8.5 Orang Tua
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/orang-tua` | List |
| GET | `/api/orang-tua/{id}` | Detail |

### 8.6 Siswa
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/siswa` | List semua siswa |
| GET | `/api/siswa/search?q=` | Pencarian siswa |
| POST | `/api/siswa/import` | Import Excel (multipart) |
| GET | `/api/siswa/{nis}` | Detail siswa |
| POST | `/api/siswa` | Create siswa |
| PUT | `/api/siswa/{nis}` | Update siswa |
| DELETE | `/api/siswa/{nis}` | Delete siswa |
| GET | `/api/siswa/by-kelas/{id_kelas}` | Siswa per kelas |

### 8.7 Kelas
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/kelas` | List semua kelas |
| GET | `/api/kelas/{id}` | Detail kelas |
| GET | `/api/kelas/by-guru/{nip}` | Kelas per guru |

### 8.8 Absensi
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/absensi` | List (filter: nip, id_kelas, start_date, end_date) |
| GET | `/api/absensi/consecutive-absent` | Siswa absen berturut-turut |
| GET | `/api/absensi/today` | Absensi hari ini |
| GET | `/api/absensi/by-date?tanggal=` | Absensi per tanggal |
| GET | `/api/absensi/by-siswa/{nis}` | Absensi per siswa |
| GET | `/api/absensi/by-kelas/{id_kelas}` | Absensi per kelas |
| GET | `/api/absensi/weekly-stats` | Statistik mingguan |
| GET | `/api/absensi/statistics` | Statistik (filter: nis, id_kelas) |
| GET | `/api/absensi/{id}` | Detail absensi |
| POST | `/api/absensi` | Create absensi (support multipart file_surat) |
| POST | `/api/absensi/bulk` | Create absensi massal |
| PUT | `/api/absensi/{id}` | Update absensi |
| DELETE | `/api/absensi/{id}` | Delete absensi |

### 8.9 Laporan
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/laporan` | List (filter: nip, id_kelas) |
| GET | `/api/laporan/generate` | Generate laporan |
| GET | `/api/laporan/download/pdf` | Download PDF |
| GET | `/api/laporan/download/excel` | Download Excel |
| GET | `/api/laporan/by-kelas/{id}` | Laporan per kelas |
| GET | `/api/laporan/by-orangtua/{id}` | Laporan per ortu |
| GET | `/api/laporan/{id}` | Detail laporan |
| POST | `/api/laporan` | Create laporan |
| POST | `/api/laporan/create-from-absensi` | Create dari data absensi |
| PUT | `/api/laporan/{id}` | Update laporan |
| DELETE | `/api/laporan/{id}` | Delete laporan |
| POST | `/api/laporan/{id}/submit` | Submit laporan |
| POST | `/api/laporan/{id}/unsubmit` | Batal submit |
| POST | `/api/laporan/{id}/refresh` | Refresh data |

### 8.10 Rekap Bulanan
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/rekap-bulanan` | List (filter: id_kelas, nip, tahun) |
| POST | `/api/rekap-bulanan` | Create rekap |
| PUT | `/api/rekap-bulanan/{id}` | Update rekap |
| DELETE | `/api/rekap-bulanan/{id}` | Delete rekap |
| POST | `/api/rekap-bulanan/{id}/refresh` | Refresh data |
| POST | `/api/rekap-bulanan/{id}/submit` | Submit |
| POST | `/api/rekap-bulanan/{id}/unsubmit` | Batal submit |

### 8.11 Dashboard
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/dashboard/guru/{nip}` | Dashboard guru |
| GET | `/api/dashboard/kepala-sekolah` | Dashboard kepsek (filter: tahun_ajar, semester, kelas) |
| GET | `/api/dashboard/orang-tua/{id_ortu}` | Dashboard ortu |
| GET | `/api/dashboard/statistics` | Statistik umum |
| GET | `/api/dashboard/class-comparison` | Perbandingan kelas |
| GET | `/api/dashboard/semester-comparison` | Perbandingan semester |

---

## 9. Kontrak Request/Response yang Terverifikasi

### 9.1 Login
**Request:** `POST /api/auth/login`
```json
{ "username": "string", "password": "string", "role": "guru|kepala_sekolah|orang_tua" }
```
**Response Sukses (200):**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "user": { /* guru/kepsek/ortu fields */ },
    "role": "guru",
    "token": "plain_text_token",
    "token_type": "Bearer"
  }
}
```
**Response Error (401):**
```json
{ "success": false, "message": "Username atau password salah" }
```

### 9.2 Format Response Standar
```json
{ "success": boolean, "message": "string", "data": any, "errors": { "field": ["msg"] } }
```

### 9.3 Autentikasi
- Menggunakan **Laravel Sanctum** (token-based).
- Token disimpan di `personal_access_tokens` table.
- Token dikirim sebagai `Authorization: Bearer {token}` header.
- Logout via `POST /api/logout` — revoke current token.
- Endpoint protected menggunakan middleware `auth:sanctum`.
- Sebagian besar endpoint data (guru, siswa, kelas, absensi, laporan, dashboard) **tidak** dilindungi `auth:sanctum` di route — hanya `logout`, `profile`, `profile/update`, `kepala-sekolah/pending`, dan `kepala-sekolah/approve`.

---

## 10. Informasi Backend dan Database yang Diketahui

### 10.1 Terverifikasi
| Aspek | Detail |
|-------|--------|
| Laravel | ^10.10 (PHP ^8.1) |
| Auth | Laravel Sanctum ^3.3 (token-based) |
| Database | MySQL 8.0.30, database `absensi_sd` |
| CORS | `allowed_origins: ['*']`, `supports_credentials: false` |
| API prefix | `/api` |
| Base URL dev | `http://localhost:8000/api` |
| Excel import | `maatwebsite/excel ^3.1` |

### 10.2 Schema Database (Terverifikasi)

| Tabel | Primary Key | Relasi |
|-------|------------|--------|
| `guru` | `nip` (varchar) | → `kelas.nip`, `absensi.nip`, `laporan.nip` |
| `kelas` | `id_kelas` (int, AI) | `nip` → `guru.nip` |
| `kepala_sekolah` | `nip` (varchar) | — |
| `kepsek_approvals` | `id` (bigint, AI) | `nip_kepsek`, `nip_guru` |
| `orang_tua` | `id_ortu` (int, AI) | → `siswa.id_ortu` |
| `siswa` | `nis` (varchar) | `id_kelas` → `kelas.id_kelas`, `id_ortu` → `orang_tua.id_ortu` |
| `absensi` | `id_absensi` (int, AI) | `nis` → `siswa.nis`, `nip` → `guru.nip` |
| `laporan` | `id_laporan` (int, AI) | `id_kelas` → `kelas.id_kelas`, `nip` → `guru.nip` |
| `personal_access_tokens` | `id` (bigint, AI) | `tokenable_type`, `tokenable_id` |

### 10.3 Belum Terverifikasi
- Format response spesifik dari beberapa endpoint (`downloadPdf`, `downloadExcel`) — **perlu diverifikasi** apakah mengembalikan URL file atau base64 atau response binary.
- Detail logic `LaporanController` (~33K bytes) — terlalu besar untuk audit penuh, behavior `generate`, `downloadPdf`, `downloadExcel` perlu diverifikasi dengan testing aktual.
- Konfigurasi CORS production (kemungkinan perlu penyesuaian untuk domain Vercel).

---

## 11. Pemetaan Fitur Lama ke Implementasi Svelte

| Fitur Flutter | Implementasi Svelte |
|--------------|---------------------|
| `Provider` (ChangeNotifier) | Svelte writable stores |
| `SharedPreferences` | `localStorage` |
| `Navigator.push/pushReplacement` | svelte-spa-router / hash-based routing |
| `http` package | Fetch API |
| `MultipartRequest` | `FormData` + Fetch |
| `BottomNavigationBar` | Custom tab component |
| `Scaffold` + `AppBar` | HTML/CSS layout |
| `Form` + `TextFormField` | HTML `<form>` + `<input>` |
| `fl_chart` (bar/line chart) | Chart.js (lazy loaded) |
| `pdf` + `printing` | jsPDF (lazy loaded) |
| `excel` package | SheetJS/xlsx (lazy loaded) |
| `table_calendar` | Custom calendar component |
| `file_picker` | `<input type="file">` |
| `google_fonts` (Poppins) | Font sistem + fallback stack |
| `shimmer` | CSS shimmer animation |
| `intl` (DateFormat, id locale) | `Intl.DateTimeFormat` + helper functions |
| Dark/light theme | CSS custom properties + `prefers-color-scheme` |
| `ScaffoldMessenger.showSnackBar` | Custom toast/notification component |

---

## 12. Arsitektur Frontend Baru

### 12.1 Stack
- **Build tool:** Vite 5.x
- **Framework:** Svelte 4.x (tanpa SvelteKit)
- **Bahasa:** TypeScript (strict mode)
- **Styling:** CSS biasa + CSS custom properties (design tokens)
- **HTTP:** Fetch API (wrapper terpusat)
- **State:** Svelte writable stores
- **Routing:** `svelte-spa-router` (hash-based routing untuk SPA tanpa backend routing)
- **Charts:** Chart.js (lazy loaded)
- **PDF:** jsPDF + jspdf-autotable (lazy loaded)
- **Excel:** SheetJS (lazy loaded)
- **Date formatting:** Custom helpers menggunakan `Intl.DateTimeFormat`

### 12.2 Alasan Keputusan Teknis

**Mengapa Svelte (bukan SvelteKit)?**
- Permintaan user eksplisit: Vite + Svelte.
- Aplikasi ini SPA murni yang berkomunikasi dengan API terpisah.
- Tidak memerlukan SSR, file-based routing, atau server functions.
- SvelteKit menambah overhead konfigurasi tanpa manfaat jelas.

**Mengapa `svelte-spa-router`?**
- Routing hash-based (`#/login`, `#/guru/dashboard`) memungkinkan deployment statis tanpa server-side fallback.
- Ringan, mendukung route params, guards, dan nested routes.
- Alternatif: `tinro` atau manual routing. `svelte-spa-router` dipilih karena lebih matang dan terdokumentasi.

**Mengapa Chart.js?**
- Mendukung bar dan line chart yang digunakan Flutter (`fl_chart`).
- Ukuran ~60KB (gzipped), bisa tree-shaken.
- Alternatif: `svelte-chartjs` (wrapper), `uPlot` (lebih kecil tapi kurang fitur).

---

## 13. Struktur Direktori Frontend Baru

```
fe-svelte/
├── index.html
├── vite.config.ts
├── tsconfig.json
├── package.json
├── .env                          # VITE_API_BASE_URL
├── .env.production               # Production API URL
├── src/
│   ├── main.ts                   # Entry point
│   ├── App.svelte                # Root component + router
│   ├── lib/
│   │   ├── api/
│   │   │   ├── client.ts         # Fetch wrapper (get, post, put, delete, upload)
│   │   │   ├── auth.ts           # Auth API calls
│   │   │   ├── absensi.ts        # Absensi API calls
│   │   │   ├── dashboard.ts      # Dashboard API calls
│   │   │   ├── siswa.ts          # Siswa API calls
│   │   │   ├── guru.ts           # Guru API calls
│   │   │   ├── kelas.ts          # Kelas API calls
│   │   │   ├── laporan.ts        # Laporan API calls
│   │   │   └── rekap.ts          # Rekap bulanan API calls
│   │   ├── stores/
│   │   │   ├── auth.ts           # Auth store (user, role, token, isAuthenticated)
│   │   │   └── settings.ts       # Settings store (darkMode, notifications)
│   │   ├── types/
│   │   │   ├── user.ts           # User, Guru, KepalaSekolah, OrangTua
│   │   │   ├── absensi.ts        # Absensi, TodayStats, WeeklyStats, etc.
│   │   │   ├── siswa.ts          # Siswa, Kelas
│   │   │   ├── laporan.ts        # Laporan, LaporanGenerated, etc.
│   │   │   ├── dashboard.ts      # Dashboard models per role
│   │   │   └── api.ts            # ApiResponse<T>, generic types
│   │   ├── utils/
│   │   │   ├── date.ts           # Date formatting (Indonesian locale)
│   │   │   ├── constants.ts      # App constants, roles, status
│   │   │   └── download.ts       # File download helper
│   │   └── guards/
│   │       └── auth.ts           # Route guard (check auth + role)
│   ├── components/
│   │   ├── ui/
│   │   │   ├── Button.svelte
│   │   │   ├── TextField.svelte
│   │   │   ├── Dropdown.svelte
│   │   │   ├── StatusBadge.svelte
│   │   │   ├── StatCard.svelte
│   │   │   ├── Loading.svelte
│   │   │   ├── ErrorState.svelte
│   │   │   ├── EmptyState.svelte
│   │   │   ├── Toast.svelte
│   │   │   ├── Modal.svelte
│   │   │   └── Calendar.svelte
│   │   ├── layout/
│   │   │   ├── BottomNav.svelte
│   │   │   ├── AppBar.svelte
│   │   │   └── PageLayout.svelte
│   │   └── charts/
│   │       ├── BarChart.svelte
│   │       └── LineChart.svelte
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── Landing.svelte
│   │   │   ├── Login.svelte
│   │   │   ├── Register.svelte
│   │   │   └── ForgotPassword.svelte
│   │   ├── guru/
│   │   │   ├── GuruHome.svelte
│   │   │   ├── GuruDashboard.svelte
│   │   │   ├── Absensi.svelte
│   │   │   ├── MulaiAbsensi.svelte
│   │   │   ├── EditAbsensi.svelte
│   │   │   ├── KelolaSiswa.svelte
│   │   │   ├── SiswaDetail.svelte
│   │   │   ├── LaporanGuru.svelte
│   │   │   ├── RekapBulanan.svelte
│   │   │   └── PersetujuanKepsek.svelte
│   │   ├── kepsek/
│   │   │   ├── KepsekHome.svelte
│   │   │   ├── KepsekDashboard.svelte
│   │   │   └── LaporanKepsek.svelte
│   │   ├── ortu/
│   │   │   ├── OrtuHome.svelte
│   │   │   ├── OrtuDashboard.svelte
│   │   │   └── LaporanOrtu.svelte
│   │   └── shared/
│   │       ├── Settings.svelte
│   │       ├── ListGuru.svelte
│   │       └── ListSiswa.svelte
│   └── styles/
│       ├── global.css              # Reset, font, CSS custom properties, utilities
│       ├── theme.css               # Light/dark theme tokens
│       └── components.css          # Shared component styles
```

---

## 14. Rancangan Routing dan Navigasi

```typescript
// routes.ts
const routes = {
  '/': Landing,
  '/login': Login,
  '/register': Register,
  '/forgot-password': ForgotPassword,
  '/guru': wrap({ component: GuruHome, conditions: [isGuruGuard] }),
  '/guru/absensi/mulai': wrap({ component: MulaiAbsensi, conditions: [isGuruGuard] }),
  '/guru/absensi/:id/edit': wrap({ component: EditAbsensi, conditions: [isGuruGuard] }),
  '/guru/siswa/:nis': wrap({ component: SiswaDetail, conditions: [isGuruGuard] }),
  '/guru/rekap-bulanan': wrap({ component: RekapBulanan, conditions: [isGuruGuard] }),
  '/guru/persetujuan-kepsek': wrap({ component: PersetujuanKepsek, conditions: [isGuruGuard] }),
  '/kepsek': wrap({ component: KepsekHome, conditions: [isKepsekGuard] }),
  '/ortu': wrap({ component: OrtuHome, conditions: [isOrtuGuard] }),
  '/settings': wrap({ component: Settings, conditions: [isAuthGuard] }),
  '*': Landing,
};
```

**Guard function** membaca auth store, redirect ke `/login` jika tidak authenticated atau role tidak sesuai.

---

## 15. Autentikasi, Session, Logout, dan Role-Based Access Control

### 15.1 Flow Login
1. User mengisi form (username, password, role).
2. `POST /api/auth/login` → response `{token, user, role}`.
3. Simpan `token`, `user` (JSON), `role`, `userId` ke `localStorage`.
4. Set token di API client header.
5. Redirect ke halaman home sesuai role.

### 15.2 Session Check (App Init)
1. Baca `token` dari `localStorage`.
2. Jika ada → set di API client, baca `user` dan `role` dari `localStorage`.
3. Navigasi ke home sesuai role.
4. Jika tidak ada → tampilkan Landing page.

### 15.3 Logout
1. Panggil `POST /api/logout` (best-effort, abaikan error).
2. Hapus `token`, `user`, `role`, `userId` dari `localStorage`.
3. Clear API client token.
4. Redirect ke Landing page.

### 15.4 Role-Based Access Control (Frontend)
- Route guard memvalidasi role sebelum render halaman.
- BottomNav menampilkan tab berbeda per role.
- **Otorisasi sebenarnya tetap di backend** — frontend hanya mengatur tampilan.

---

## 16. State Management

### 16.1 Auth Store
```typescript
// stores/auth.ts
export const authStore = writable<{
  user: User | null;
  role: string | null;
  token: string | null;
  isLoading: boolean;
  error: string | null;
}>({ user: null, role: null, token: null, isLoading: false, error: null });

// Derived
export const isAuthenticated = derived(authStore, $s => $s.user !== null);
```

### 16.2 Settings Store
```typescript
// stores/settings.ts
export const settingsStore = writable<{
  isDarkMode: boolean;
  isNotificationEnabled: boolean;
}>({ isDarkMode: false, isNotificationEnabled: true });
```

### 16.3 State Lokal Halaman
Setiap halaman mengelola state lokal sendiri (loading, data, form state) menggunakan variabel Svelte biasa (`let`). Tidak perlu store global untuk data yang hanya dipakai satu halaman.

---

## 17. API Client dan Strategi Error Handling

### 17.1 API Client
```typescript
// api/client.ts
const BASE_URL = import.meta.env.VITE_API_BASE_URL;

async function request<T>(method, endpoint, options?): Promise<ApiResponse<T>> {
  const headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' };
  const token = getToken();
  if (token) headers['Authorization'] = `Bearer ${token}`;
  
  const response = await fetch(`${BASE_URL}${endpoint}`, { method, headers, ...options });
  const body = await response.json();
  
  if (response.ok) return { success: true, message: body.message, data: body.data };
  return { success: false, message: body.message, errors: body.errors };
}
```

### 17.2 Error Handling
1. **Network error** → catch → tampilkan "Koneksi gagal".
2. **401 Unauthorized** → clear session → redirect ke login.
3. **422 Validation** → tampilkan `errors` per field.
4. **500 Server Error** → tampilkan pesan error generik.
5. **Timeout** → retry atau tampilkan pesan timeout.

---

## 18. Model dan Tipe TypeScript

Semua model dari Flutter akan dikonversi ke TypeScript interface. Contoh:

```typescript
interface User {
  id?: string;
  nip?: string;
  idOrtu?: number;
  nama: string;
  email: string;
  username?: string;
  noHp?: string;
  gender?: string;
  alamat?: string;
  role: string;
}

interface Absensi {
  idAbsensi?: number;
  nis: string;
  nip: string;
  tanggal: string;
  statusKehadiran: 'hadir' | 'izin' | 'sakit' | 'alfa';
  keterangan?: string;
  fileSurat?: string;
  namaSiswa?: string;
  namaGuru?: string;
  siswa?: SiswaAbsensi;
}
```

Nama field TypeScript menggunakan camelCase, dengan mapping ke snake_case saat kirim/terima API.

---

## 19. Komponen UI yang Dapat Digunakan Ulang

Lihat daftar di §6.4. Setiap komponen akan diimplementasikan sebagai Svelte component dengan props yang setara dengan widget Flutter. Styling menggunakan CSS custom properties agar konsisten dengan theme.

---

## 20. Implementasi Desain dan Responsivitas

### 20.1 Pendekatan
- CSS custom properties untuk design tokens (warna, spacing, radius).
- Tema gelap/terang menggunakan class `dark` pada `<body>` yang toggle CSS variables.
- Komponen menggunakan `<style>` scoped Svelte.
- Breakpoints: mengikuti perilaku Flutter yang mobile-first (layout tunggal, scrollable).

### 20.2 Responsivitas
Aplikasi Flutter menggunakan layout mobile-first tanpa breakpoint eksplisit. Frontend Svelte akan mempertahankan pendekatan yang sama — layout vertikal, full-width components, bottom navigation.

---

## 21. Fitur Khusus

### 21.1 Upload File (Import Excel Siswa)
- `<input type="file" accept=".xlsx,.xls">` → FormData → `POST /api/siswa/import`.
- Fields: `file`, `id_kelas`.

### 21.2 Download PDF
- **Belum terverifikasi** apakah backend mengembalikan URL atau binary.
- Jika URL → `window.open(url)` atau `<a download>`.
- Jika binary → Blob → URL.createObjectURL → download.
- Alternatif: generate PDF client-side menggunakan jsPDF (sesuai Flutter yang menggunakan `pdf` package client-side).

### 21.3 Download Excel
- Sama seperti PDF — perlu verifikasi response backend.
- Alternatif client-side: SheetJS.

### 21.4 Charts
- Flutter menggunakan `fl_chart` untuk bar chart (weekly stats) dan kemungkinan pie chart.
- Svelte: Chart.js dengan lazy loading (`import()` dinamis).

### 21.5 Calendar
- Flutter menggunakan `table_calendar` untuk kalender kehadiran di dashboard ortu.
- Svelte: Custom calendar component yang menampilkan grid bulan dengan warna status per tanggal.

---

## 22. Strategi Performa dan Code Splitting

1. **Entry point ringan** — hanya auth check + routing.
2. **Code splitting per route** — setiap halaman lazy-loaded via `import()`.
3. **Lazy load library berat:**
   - Chart.js: import saat komponen chart pertama kali mount.
   - jsPDF: import saat user klik download PDF.
   - SheetJS: import saat user klik download Excel / import Excel.
4. **Font sistem** — 0 KB font download.
5. **No framework overhead** — Svelte compiles away, tidak ada runtime.
6. **Vite tree-shaking** — hapus kode tidak terpakai.
7. **Cache aset** — Vite content-hash filenames.
8. **Hindari request ganda** — debounce search, cache dashboard data selama session.

---

## 23. Keamanan Frontend dan Integrasi API

1. Token disimpan di `localStorage` — **Catatan risiko:** `localStorage` rentan XSS. Ini konsisten dengan perilaku Flutter (SharedPreferences). Untuk migrasi ke cookie HttpOnly memerlukan perubahan backend (di luar scope).
2. Jangan menaruh secret/credentials di `VITE_*` env vars.
3. Sanitasi input sebelum render (Svelte sudah escape by default).
4. CSRF: tidak diperlukan karena API menggunakan token Bearer (bukan cookie session).
5. CORS: backend sudah allow `*`.

---

## 24. Strategi Pengujian

### 24.1 Unit Test
- Vitest untuk utility functions (date formatting, API client parsing).

### 24.2 Integration Test
- Test API calls terhadap backend yang berjalan.

### 24.3 End-to-End
- Playwright untuk test flow utama (login, absensi, laporan).

### 24.4 Regresi Visual
- Screenshot comparison antara Flutter dan Svelte pada halaman yang sama.

---

## 25. Pengujian Kesetaraan Visual

### Metode
1. Jalankan Flutter app di browser → screenshot setiap halaman per role.
2. Jalankan Svelte app → screenshot setiap halaman per role.
3. Bandingkan secara side-by-side.
4. Dokumentasikan perbedaan dan justifikasi.

### Kriteria
- Layout dan posisi komponen harus konsisten.
- Warna harus identik (menggunakan hex yang sama).
- Font akan berbeda (Poppins → sistem) — dokumentasikan.
- Spacing dan ukuran harus mendekati (toleransi ±2px).

---

## 26. Konfigurasi Environment dan Deployment Vercel

### 26.1 Environment Variables
```
# .env (development)
VITE_API_BASE_URL=http://localhost:8000/api

# .env.production
VITE_API_BASE_URL=https://api.domain.com/api
```

### 26.2 Deployment Vercel
- Framework preset: Vite.
- Build command: `npm run build`.
- Output directory: `dist`.
- SPA fallback: `vercel.json` → `{ "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }] }` — diperlukan hanya jika tidak menggunakan hash routing.

---

## 27. Risiko, Trade-off, Asumsi, dan Keputusan yang Memerlukan Konfirmasi

### 27.1 Risiko

| # | Risiko | Dampak | Mitigasi |
|---|--------|--------|----------|
| R1 | Font berbeda (Poppins → sistem) | Perbedaan visual pada tipografi | Dokumentasikan; opsi: bundle Poppins lokal |
| R2 | Response `downloadPdf`/`downloadExcel` belum diverifikasi | Fitur download mungkin perlu penyesuaian | Test dengan backend aktif sebelum implementasi |
| R3 | CORS production | Bisa gagal jika backend tidak allow domain Vercel | **Perlu konfigurasi domain di CORS backend** (memerlukan perubahan backend — perlu persetujuan) |
| R4 | Token di localStorage | Rentan XSS (sama dengan Flutter) | Konsisten dengan sistem lama; migrasi ke HttpOnly cookie di luar scope |
| R5 | Calendar component custom | Bisa berbeda tampilan dari `table_calendar` | Implementasi teliti berdasarkan audit visual |
| R6 | Beberapa endpoint tidak protected auth:sanctum | Data bisa diakses tanpa login | Ini perilaku backend yang sudah ada — tidak diubah |

### 27.2 Asumsi
- A1: Backend Laravel berjalan di `localhost:8000` untuk development.
- A2: Node.js >= 18 tersedia di mesin development.
- A3: Database MySQL sudah terisi data sesuai `absensi_sd.sql`.

### 27.3 Keputusan yang Memerlukan Konfirmasi
- **K1:** Apakah boleh bundling font Poppins lokal (menambah ~100KB) untuk menjaga kesetaraan visual?
- **K2:** Apakah perlu meminta persetujuan untuk konfigurasi CORS backend untuk production domain?
- **K3:** Apakah `svelte-spa-router` (hash-based) diterima, atau harus history-based routing?

---

## 28. Kriteria Penerimaan Akhir

1. ✅ Semua 21 halaman terimplementasi dan berfungsi.
2. ✅ Login, logout, session persistence bekerja untuk 3 role.
3. ✅ Semua operasi CRUD berfungsi (siswa, absensi, laporan, rekap).
4. ✅ Import Excel siswa berfungsi.
5. ✅ Download PDF dan Excel berfungsi.
6. ✅ Grafik (chart) menampilkan data yang benar.
7. ✅ Kalender kehadiran berfungsi.
8. ✅ Tema terang dan gelap berfungsi.
9. ✅ Warna, spacing, dan layout konsisten dengan Flutter.
10. ✅ Tidak ada perubahan backend atau database.
11. ✅ Bundle JS produksi < 500KB (target, belum diukur).
12. ✅ Lighthouse Performance > 80 (target, belum diukur).
13. ✅ Build produksi berhasil tanpa error.
14. ✅ Deploy ke Vercel berhasil.
15. ✅ Perbedaan visual dari font didokumentasikan.
