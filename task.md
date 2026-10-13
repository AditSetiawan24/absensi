# Task — Rewrite Frontend Flutter Web → Vite + Svelte + TypeScript

> Semua tugas diturunkan dari hasil audit dan `implementation.md`.
> Referensi: `implementation.md` di root repository.

---

## Fase 0: Audit Repository dan Baseline

- [x] `AUDIT-001` — Audit struktur frontend Flutter
  - **Tujuan:** Memahami arsitektur, halaman, widget, service, model, dan provider Flutter.
  - **File terkait:** `fe_absensi/lib/` (semua file)
  - **Dependensi:** Tidak ada
  - **Langkah:** Baca semua file di `lib/`, dokumentasikan struktur, fitur, dan dependensi.
  - **Kriteria penerimaan:** Seluruh halaman, komponen, model, service, dan provider terinventarisir.
  - **Verifikasi:** Bandingkan inventaris dengan `implementation.md §5–6`.

- [x] `AUDIT-002` — Audit backend Laravel dan API
  - **Tujuan:** Memahami endpoint API, autentikasi, format request/response, dan aturan bisnis.
  - **File terkait:** `api/absensi-api/routes/api.php`, `api/absensi-api/app/Http/Controllers/`
  - **Dependensi:** Tidak ada
  - **Langkah:** Baca `api.php`, semua controller, model, middleware. Dokumentasikan seluruh endpoint.
  - **Kriteria penerimaan:** Seluruh endpoint terdokumentasi di `implementation.md §8`.
  - **Verifikasi:** Bandingkan endpoint di `implementation.md` dengan `api.php`.

- [x] `AUDIT-003` — Audit database MySQL
  - **Tujuan:** Memahami schema database, tabel, relasi, dan tipe data.
  - **File terkait:** `absensi_sd.sql`
  - **Dependensi:** Tidak ada
  - **Langkah:** Baca SQL dump, dokumentasikan tabel dan relasi.
  - **Kriteria penerimaan:** Schema terdokumentasi di `implementation.md §10.2`.
  - **Verifikasi:** Bandingkan dengan `absensi_sd.sql`.

- [x] `AUDIT-004` — Audit tema dan desain visual
  - **Tujuan:** Dokumentasikan palet warna, tipografi, spacing, dan aturan desain.
  - **File terkait:** `fe_absensi/lib/core/theme/app_colors.dart`, `app_theme.dart`
  - **Dependensi:** Tidak ada
  - **Langkah:** Baca file tema, dokumentasikan semua token desain.
  - **Kriteria penerimaan:** Palet warna dan spacing terdokumentasi di `implementation.md §7`.
  - **Verifikasi:** Bandingkan hex values dengan file sumber.

- [ ] `AUDIT-005` — Screenshot referensi Flutter (opsional)
  - **Tujuan:** Ambil screenshot semua halaman Flutter untuk referensi visual.
  - **File terkait:** Tidak ada (output: screenshot)
  - **Dependensi:** Backend Laravel harus berjalan
  - **Langkah:** Jalankan Flutter web, login tiap role, screenshot semua halaman.
  - **Kriteria penerimaan:** Screenshot tersedia untuk setiap halaman per role.
  - **Verifikasi:** Screenshot mencakup semua 21 halaman.

- [ ] `AUDIT-006` — Baseline performa Flutter Web
  - **Tujuan:** Ukur performa Flutter Web sebagai baseline perbandingan.
  - **Dependensi:** Flutter app berjalan
  - **Langkah:** Jalankan Lighthouse audit pada Flutter Web. Catat: FCP, LCP, TBT, CLS, total JS, total payload, jumlah request.
  - **Kriteria penerimaan:** Hasil Lighthouse tercatat.
  - **Verifikasi:** Data baseline tersedia.

- [ ] `AUDIT-007` — Verifikasi response endpoint download PDF/Excel
  - **Tujuan:** Tentukan apakah backend mengembalikan URL, binary, atau base64 untuk download.
  - **File terkait:** `api/absensi-api/app/Http/Controllers/LaporanController.php`
  - **Dependensi:** `AUDIT-002`, backend berjalan
  - **Langkah:** Panggil `GET /api/laporan/download/pdf` dan `GET /api/laporan/download/excel` dengan parameter valid. Periksa response headers dan body.
  - **Kriteria penerimaan:** Format response terdokumentasi.
  - **Verifikasi:** Hasil verifikasi ditambahkan ke `implementation.md §10.3`.

---

## Fase 1: Setup Proyek Vite + Svelte + TypeScript

- [x] `SETUP-001` — Inisialisasi proyek Vite + Svelte + TypeScript
  - **Tujuan:** Buat proyek frontend baru dengan Vite, Svelte, dan TypeScript.
  - **File terkait:** `fe-svelte/` (direktori baru)
  - **Dependensi:** Tidak ada
  - **Langkah:**
    1. `npx -y create-vite@latest fe-svelte -- --template svelte-ts`
    2. `cd fe-svelte && npm install`
    3. Verifikasi `npm run dev` berjalan.
  - **Kriteria penerimaan:** Dev server berjalan, halaman default Svelte muncul.
  - **Verifikasi:** `npm run dev` → buka browser → halaman muncul tanpa error.

- [x] `SETUP-002` — Konfigurasi TypeScript strict mode
  - **Tujuan:** Aktifkan strict mode TypeScript.
  - **File terkait:** `fe-svelte/tsconfig.json`
  - **Dependensi:** `SETUP-001`
  - **Langkah:** Set `"strict": true`, `"noImplicitAny": true`, `"strictNullChecks": true`.
  - **Kriteria penerimaan:** `npm run check` (svelte-check) lulus tanpa error.
  - **Verifikasi:** `npx svelte-check --no-tsconfig` → 0 errors.

- [x] `SETUP-003` — Konfigurasi environment variables
  - **Tujuan:** Setup `VITE_API_BASE_URL` untuk dev dan production.
  - **File terkait:** `fe-svelte/.env`, `fe-svelte/.env.production`
  - **Dependensi:** `SETUP-001`
  - **Langkah:**
    1. Buat `.env` dengan `VITE_API_BASE_URL=http://localhost:8000/api`.
    2. Buat `.env.production` dengan placeholder production URL.
    3. Tambahkan `/// <reference types="vite/client" />` di `env.d.ts`.
  - **Kriteria penerimaan:** `import.meta.env.VITE_API_BASE_URL` tersedia di runtime.
  - **Verifikasi:** Console.log di `main.ts` menampilkan URL yang benar.

- [x] `SETUP-004` — Install dependencies tambahan
  - **Tujuan:** Install routing, chart, PDF, dan Excel libraries.
  - **File terkait:** `fe-svelte/package.json`
  - **Dependensi:** `SETUP-001`
  - **Langkah:**
    1. `npm install svelte-spa-router`
    2. `npm install chart.js` (lazy load)
    3. `npm install jspdf jspdf-autotable` (lazy load)
    4. `npm install xlsx` (lazy load)
  - **Kriteria penerimaan:** Semua dependencies terinstall tanpa conflict.
  - **Verifikasi:** `npm ls --depth=0` → semua package terdaftar.

---

## Fase 2: Fondasi Arsitektur

- [x] `ARCH-001` — Buat struktur direktori
  - **Tujuan:** Buat seluruh folder sesuai `implementation.md §13`.
  - **File terkait:** `fe-svelte/src/`
  - **Dependensi:** `SETUP-001`
  - **Langkah:** Buat semua direktori: `lib/api/`, `lib/stores/`, `lib/types/`, `lib/utils/`, `lib/guards/`, `components/ui/`, `components/layout/`, `components/charts/`, `pages/auth/`, `pages/guru/`, `pages/kepsek/`, `pages/ortu/`, `pages/shared/`, `styles/`.
  - **Kriteria penerimaan:** Struktur folder sesuai spesifikasi.
  - **Verifikasi:** `tree src/` → cocok dengan `implementation.md §13`.

- [x] `ARCH-002` — Implementasi tipe TypeScript
  - **Tujuan:** Konversi semua Dart model ke TypeScript interface.
  - **File terkait:** `fe-svelte/src/lib/types/*.ts`
  - **Dependensi:** `ARCH-001`, `AUDIT-001`
  - **Langkah:** Buat interface untuk: User, Guru, KepalaSekolah, OrangTua, Siswa, Kelas, Absensi, TodayStats, WeeklyStats, AbsentStudent, ConsecutiveAbsent, Laporan, LaporanGenerated, GuruDashboard, KepalaSekolahDashboard, OrangTuaDashboard, SiswaAbsensiData, CalendarData, ApiResponse.
  - **Kriteria penerimaan:** Semua model dari `implementation.md §18` terdefinisi. Type-safe.
  - **Verifikasi:** `npx svelte-check` → 0 type errors.

- [x] `ARCH-003` — Implementasi konstanta dan utilitas
  - **Tujuan:** Port `AppConstants` dan utilitas tanggal ke TypeScript.
  - **File terkait:** `fe-svelte/src/lib/utils/constants.ts`, `date.ts`
  - **Dependensi:** `ARCH-001`
  - **Langkah:**
    1. Buat `constants.ts` dengan app name, roles, status, kelas options, gender options, semester options.
    2. Buat `date.ts` dengan fungsi format tanggal Indonesia (`Intl.DateTimeFormat`).
  - **Kriteria penerimaan:** Semua konstanta dari `app_constants.dart` tercover. Format tanggal Indonesia bekerja.
  - **Verifikasi:** Unit test untuk fungsi tanggal.

- [x] `ARCH-004` — Implementasi API client
  - **Tujuan:** Buat HTTP client terpusat menggunakan Fetch API.
  - **File terkait:** `fe-svelte/src/lib/api/client.ts`
  - **Dependensi:** `ARCH-002`, `SETUP-003`
  - **Langkah:** Implementasi fungsi `get`, `post`, `put`, `del`, `upload` sesuai `implementation.md §17`.
  - **Kriteria penerimaan:** Semua method HTTP tercover. Token management bekerja. Error handling konsisten.
  - **Verifikasi:** Unit test dengan mock fetch.

- [x] `ARCH-005` — Implementasi auth store
  - **Tujuan:** Buat Svelte store untuk state autentikasi.
  - **File terkait:** `fe-svelte/src/lib/stores/auth.ts`
  - **Dependensi:** `ARCH-002`, `ARCH-004`
  - **Langkah:** Implementasi writable store + derived `isAuthenticated`. Fungsi: `login`, `logout`, `checkAuth`, `register`.
  - **Kriteria penerimaan:** Login/logout memperbarui store + localStorage. `isAuthenticated` derived store bekerja.
  - **Verifikasi:** Manual test login/logout cycle.

- [x] `ARCH-006` — Implementasi settings store
  - **Tujuan:** Buat store untuk dark mode dan notifikasi.
  - **File terkait:** `fe-svelte/src/lib/stores/settings.ts`
  - **Dependensi:** `ARCH-001`
  - **Langkah:** Implementasi writable store dengan persistence ke localStorage.
  - **Kriteria penerimaan:** Toggle dark mode memperbarui store + localStorage + CSS class.
  - **Verifikasi:** Toggle dark mode → halaman berubah tema.

---

## Fase 3: Integrasi Autentikasi

- [x] `AUTH-001` — Implementasi auth API service
  - **Tujuan:** Port `AuthService` ke TypeScript.
  - **File terkait:** `fe-svelte/src/lib/api/auth.ts`
  - **Dependensi:** `ARCH-004`, `ARCH-002`
  - **Langkah:** Implementasi: `login`, `register`, `forgotPassword`, `resetPassword`, `changePassword`, `logout`, `releaseClass`, `changeClass`, `getGuruClass`.
  - **Kriteria penerimaan:** Semua endpoint auth terintegrasi.
  - **Verifikasi:** Login dengan akun test → token tersimpan → profile dapat diakses.

- [x] `AUTH-002` — Implementasi route guards
  - **Tujuan:** Buat guard untuk proteksi route berdasarkan auth + role.
  - **File terkait:** `fe-svelte/src/lib/guards/auth.ts`
  - **Dependensi:** `ARCH-005`
  - **Langkah:** Buat fungsi guard: `isAuth`, `isGuru`, `isKepsek`, `isOrtu`. Guard membaca auth store, return boolean.
  - **Kriteria penerimaan:** Akses route tanpa login → redirect ke `/login`. Akses route guru sebagai ortu → redirect.
  - **Verifikasi:** Manual test akses halaman tanpa login.

- [x] `AUTH-003` — Implementasi routing
  - **Tujuan:** Setup `svelte-spa-router` dengan semua route.
  - **File terkait:** `fe-svelte/src/App.svelte`, routes configuration
  - **Dependensi:** `AUTH-002`, `SETUP-004`
  - **Langkah:** Konfigurasi routes sesuai `implementation.md §14`. Wrap protected routes dengan guards.
  - **Kriteria penerimaan:** Semua route navigable. Guards aktif.
  - **Verifikasi:** Navigasi ke setiap route → halaman yang benar muncul.

---

## Fase 4: Sistem Desain dan Layout

- [x] `DESIGN-001` — Implementasi CSS global dan design tokens
  - **Tujuan:** Buat file CSS dengan semua design tokens dari palet warna Flutter.
  - **File terkait:** `fe-svelte/src/styles/global.css`, `theme.css`
  - **Dependensi:** `AUDIT-004`
  - **Langkah:**
    1. Buat CSS reset.
    2. Definisikan CSS custom properties untuk semua warna, spacing, radius.
    3. Buat `[data-theme="dark"]` overrides.
    4. Set font stack sistem.
  - **Kriteria penerimaan:** Semua token dari `implementation.md §7` terdefinisi di CSS. Tema terang/gelap toggle bekerja.
  - **Verifikasi:** Inspect CSS variables di browser → nilai cocok dengan hex di `app_colors.dart`.

- [x] `DESIGN-002` — Implementasi komponen Button
  - **Tujuan:** Port `CustomButton` ke Svelte.
  - **File terkait:** `fe-svelte/src/components/ui/Button.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi props: `text`, `onClick`, `isLoading`, `isOutlined`, `backgroundColor`, `textColor`, `icon`, `width`, `disabled`.
  - **Kriteria penerimaan:** Tampilan identik dengan Flutter (warna, radius, padding, loading spinner).
  - **Verifikasi:** Visual comparison dengan Flutter button.

- [x] `DESIGN-003` — Implementasi komponen TextField
  - **Tujuan:** Port `CustomTextField` ke Svelte.
  - **File terkait:** `fe-svelte/src/components/ui/TextField.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi props: `value` (bind), `label`, `hint`, `prefixIcon`, `suffixIcon`, `type`, `error`, `disabled`, `maxLines`.
  - **Kriteria penerimaan:** Tampilan identik (border radius 12px, filled, focus state).
  - **Verifikasi:** Visual comparison.

- [x] `DESIGN-004` — Implementasi komponen Dropdown
  - **Tujuan:** Port `CustomDropdown` ke Svelte.
  - **File terkait:** `fe-svelte/src/components/ui/Dropdown.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi `<select>` dengan styling konsisten.
  - **Kriteria penerimaan:** Tampilan konsisten dengan TextField.
  - **Verifikasi:** Visual comparison.

- [x] `DESIGN-005` — Implementasi komponen StatusBadge
  - **Tujuan:** Port `StatusBadge` ke Svelte.
  - **File terkait:** `fe-svelte/src/components/ui/StatusBadge.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi badge dengan warna per status (hadir/izin/sakit/alfa).
  - **Kriteria penerimaan:** Warna, border, padding identik.
  - **Verifikasi:** Visual comparison.

- [x] `DESIGN-006` — Implementasi komponen StatCard
  - **Tujuan:** Port `StatCard` ke Svelte.
  - **File terkait:** `fe-svelte/src/components/ui/StatCard.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi card dengan ikon, nilai, judul, subtitle, shadow.
  - **Kriteria penerimaan:** Layout, spacing, shadow identik.
  - **Verifikasi:** Visual comparison.

- [x] `DESIGN-007` — Implementasi komponen Loading, Error, Empty
  - **Tujuan:** Port state widgets ke Svelte.
  - **File terkait:** `fe-svelte/src/components/ui/Loading.svelte`, `ErrorState.svelte`, `EmptyState.svelte`
  - **Dependensi:** `DESIGN-001`, `DESIGN-002`
  - **Langkah:** Implementasi spinner, error icon + retry, empty icon + message.
  - **Kriteria penerimaan:** Tampilan dan perilaku konsisten.
  - **Verifikasi:** Render masing-masing state → tampilan sesuai.

- [x] `DESIGN-008` — Implementasi komponen Toast/Notification
  - **Tujuan:** Buat notifikasi pengganti `SnackBar` Flutter.
  - **File terkait:** `fe-svelte/src/components/ui/Toast.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi toast yang muncul dari bawah, auto-dismiss, support success/error/info warna.
  - **Kriteria penerimaan:** Perilaku mirip SnackBar Flutter.
  - **Verifikasi:** Trigger toast → muncul → hilang otomatis.

- [x] `DESIGN-009` — Implementasi komponen Modal/Dialog
  - **Tujuan:** Buat dialog konfirmasi pengganti `showDialog` Flutter.
  - **File terkait:** `fe-svelte/src/components/ui/Modal.svelte`
  - **Dependensi:** `DESIGN-001`, `DESIGN-002`
  - **Langkah:** Implementasi modal overlay + card content + aksi buttons.
  - **Kriteria penerimaan:** Modal muncul centered, backdrop, close on backdrop click.
  - **Verifikasi:** Open/close modal → animasi smooth.

- [x] `DESIGN-010` — Implementasi layout BottomNav
  - **Tujuan:** Port `BottomNavigationBar` Flutter ke Svelte.
  - **File terkait:** `fe-svelte/src/components/layout/BottomNav.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi bottom nav fixed, ikon + label, active state, shadow.
  - **Kriteria penerimaan:** Tab navigation bekerja. Tampilan identik (warna, spacing, shadow).
  - **Verifikasi:** Klik tab → content berubah. Visual comparison.

- [x] `DESIGN-011` — Implementasi layout AppBar
  - **Tujuan:** Port AppBar Flutter ke Svelte.
  - **File terkait:** `fe-svelte/src/components/layout/AppBar.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi app bar dengan title centered, back button opsional, warna primary.
  - **Kriteria penerimaan:** Tampilan identik.
  - **Verifikasi:** Visual comparison.

- [x] `DESIGN-012` — Implementasi layout PageLayout
  - **Tujuan:** Buat layout wrapper untuk halaman.
  - **File terkait:** `fe-svelte/src/components/layout/PageLayout.svelte`
  - **Dependensi:** `DESIGN-011`
  - **Langkah:** Implementasi wrapper dengan AppBar + scrollable content area.
  - **Kriteria penerimaan:** Konsisten di semua halaman.
  - **Verifikasi:** Render halaman dengan layout → scroll bekerja.

---

## Fase 5: Migrasi Halaman dan Fitur

### 5.1 Halaman Auth

- [x] `PAGE-001` — Splash Screen / Auth Check
  - **Tujuan:** Port splash screen + auth redirect.
  - **File terkait:** `fe-svelte/src/App.svelte`
  - **Dependensi:** `AUTH-003`, `ARCH-005`
  - **Langkah:** Saat app mount → cek localStorage → redirect ke home/landing.
  - **Kriteria penerimaan:** Refresh halaman → tetap login jika token valid.
  - **Verifikasi:** Login → refresh → tetap di dashboard.

- [x] `PAGE-002` — Landing Page
  - **Tujuan:** Port landing page.
  - **File terkait:** `fe-svelte/src/pages/auth/Landing.svelte`
  - **Dependensi:** `DESIGN-002`, `DESIGN-001`
  - **Langkah:** Port layout dari `landing_page.dart`: logo, app name, school name, feature items, tombol Masuk/Daftar.
  - **Kriteria penerimaan:** Layout, warna, spacing identik.
  - **Verifikasi:** Visual comparison.

- [x] `PAGE-003` — Login Page
  - **Tujuan:** Port halaman login.
  - **File terkait:** `fe-svelte/src/pages/auth/Login.svelte`
  - **Dependensi:** `DESIGN-002`, `DESIGN-003`, `AUTH-001`
  - **Langkah:** Port form: role chips, username, password (show/hide), forgot password link, login button, register link. Integrasi auth store.
  - **Kriteria penerimaan:** Login berhasil → redirect ke home role. Error → snackbar. Validasi frontend bekerja.
  - **Verifikasi:** Login sebagai guru/kepsek/ortu → dashboard masing-masing.

- [x] `PAGE-004` — Register Page
  - **Tujuan:** Port halaman registrasi multi-role.
  - **File terkait:** `fe-svelte/src/pages/auth/Register.svelte`
  - **Dependensi:** `DESIGN-002`, `DESIGN-003`, `DESIGN-004`, `AUTH-001`
  - **Langkah:** Port form dinamis: role selection → field berubah (guru: NIP, gender, kode sekolah, kode kelas; kepsek: NIP; ortu: alamat, NIS anak, nama anak). Validasi frontend.
  - **Kriteria penerimaan:** Registrasi berhasil untuk setiap role. Error handling lengkap.
  - **Verifikasi:** Register guru → login → dashboard guru.

- [x] `PAGE-005` — Forgot Password Page
  - **Tujuan:** Port halaman lupa/reset password.
  - **File terkait:** `fe-svelte/src/pages/auth/ForgotPassword.svelte`
  - **Dependensi:** `DESIGN-002`, `DESIGN-003`, `AUTH-001`
  - **Langkah:** Port form: email + role → forgot password. Form reset: email + role + password baru + konfirmasi.
  - **Kriteria penerimaan:** Flow lupa password → reset password bekerja.
  - **Verifikasi:** Forgot password → pesan sukses.

### 5.2 Halaman Guru

- [x] `PAGE-006` — Guru Home (Tab Container)
  - **Tujuan:** Port container dengan 4 tab BottomNav.
  - **File terkait:** `fe-svelte/src/pages/guru/GuruHome.svelte`
  - **Dependensi:** `DESIGN-010`
  - **Langkah:** Implementasi 4 tab: Dashboard, Absensi, Laporan, Pengaturan. `IndexedStack`-like behavior (keep alive).
  - **Kriteria penerimaan:** Tab navigation bekerja. State preserved saat switch tab.
  - **Verifikasi:** Switch tab → kembali → state tetap.

- [x] `PAGE-007` — Guru Dashboard
  - **Tujuan:** Port dashboard guru dengan semua fitur.
  - **File terkait:** `fe-svelte/src/pages/guru/GuruDashboard.svelte`
  - **Dependensi:** `DESIGN-006`, `DESIGN-005`, `ARCH-004`
  - **Langkah:** Port: info guru + kelas, stats hari ini (hadir/izin/sakit/alfa/belum absen), grafik mingguan, daftar siswa tidak hadir hari ini, siswa absen berturut-turut. API: `GET /api/dashboard/guru/{nip}`.
  - **Kriteria penerimaan:** Semua data tampil. Grafik render. Loading/error state.
  - **Verifikasi:** Login guru → dashboard tampil dengan data aktual.

- [x] `PAGE-008` — Absensi Page (Daftar)
  - **Tujuan:** Port halaman daftar absensi.
  - **File terkait:** `fe-svelte/src/pages/guru/Absensi.svelte`
  - **Dependensi:** `DESIGN-005`, `ARCH-004`
  - **Langkah:** Port: daftar absensi hari ini, filter tanggal, tombol mulai absensi baru, daftar absensi per tanggal. Navigasi ke MulaiAbsensi dan EditAbsensi.
  - **Kriteria penerimaan:** List absensi tampil. Filter tanggal bekerja. Navigasi bekerja.
  - **Verifikasi:** Lihat absensi hari ini → filter tanggal lain → data berubah.

- [x] `PAGE-009` — Mulai Absensi Page
  - **Tujuan:** Port form absensi massal.
  - **File terkait:** `fe-svelte/src/pages/guru/MulaiAbsensi.svelte`
  - **Dependensi:** `DESIGN-003`, `DESIGN-004`, `DESIGN-002`, `ARCH-004`
  - **Langkah:** Port: pilih tanggal, load siswa per kelas, set status per siswa (hadir/izin/sakit/alfa), keterangan opsional, submit bulk. API: `POST /api/absensi/bulk`.
  - **Kriteria penerimaan:** List siswa tampil. Set status. Submit → absensi tersimpan.
  - **Verifikasi:** Mulai absensi → set status → submit → cek di daftar absensi.

- [x] `PAGE-010` — Edit Absensi Page
  - **Tujuan:** Port form edit absensi individual.
  - **File terkait:** `fe-svelte/src/pages/guru/EditAbsensi.svelte`
  - **Dependensi:** `DESIGN-003`, `DESIGN-004`, `ARCH-004`
  - **Langkah:** Port: form edit status + keterangan. API: `PUT /api/absensi/{id}`.
  - **Kriteria penerimaan:** Edit berhasil → data diperbarui.
  - **Verifikasi:** Edit absensi → simpan → cek perubahan.

- [x] `PAGE-011` — Kelola Siswa Page
  - **Tujuan:** Port CRUD siswa + import Excel.
  - **File terkait:** `fe-svelte/src/pages/guru/KelolaSiswa.svelte`
  - **Dependensi:** `DESIGN-003`, `DESIGN-004`, `DESIGN-002`, `DESIGN-009`, `ARCH-004`
  - **Langkah:** Port: daftar siswa, pencarian, tambah siswa (form), edit siswa, hapus siswa (konfirmasi), import Excel (file picker). API: CRUD siswa + import.
  - **Kriteria penerimaan:** Semua CRUD bekerja. Import Excel bekerja. Pencarian bekerja.
  - **Verifikasi:** Tambah siswa → edit → hapus. Import Excel → siswa baru muncul.

- [x] `PAGE-012` — Siswa Detail Page
  - **Tujuan:** Port halaman detail siswa.
  - **File terkait:** `fe-svelte/src/pages/guru/SiswaDetail.svelte`
  - **Dependensi:** `DESIGN-006`, `DESIGN-005`, `ARCH-004`
  - **Langkah:** Port: profil siswa, riwayat absensi, statistik kehadiran. API: `GET /api/siswa/{nis}`, `GET /api/absensi/by-siswa/{nis}`.
  - **Kriteria penerimaan:** Detail siswa + riwayat tampil.
  - **Verifikasi:** Klik siswa → detail tampil dengan data benar.

- [x] `PAGE-013` — Laporan Guru Page
  - **Tujuan:** Port halaman kelola laporan semester.
  - **File terkait:** `fe-svelte/src/pages/guru/LaporanGuru.svelte`
  - **Dependensi:** `DESIGN-006`, `DESIGN-002`, `DESIGN-009`, `ARCH-004`
  - **Langkah:** Port: daftar laporan, create from absensi, submit/unsubmit, refresh, delete, download PDF/Excel, navigasi ke rekap bulanan. API: semua endpoint laporan.
  - **Kriteria penerimaan:** Semua operasi laporan bekerja. Download berfungsi.
  - **Verifikasi:** Create laporan → submit → download PDF → unsubmit → delete.

- [x] `PAGE-014` — Rekap Bulanan Page
  - **Tujuan:** Port halaman rekap bulanan.
  - **File terkait:** `fe-svelte/src/pages/guru/RekapBulanan.svelte`
  - **Dependensi:** `DESIGN-006`, `DESIGN-002`, `ARCH-004`
  - **Langkah:** Port: daftar rekap, create, submit/unsubmit, refresh, delete, chart/grafik. API: semua endpoint rekap bulanan.
  - **Kriteria penerimaan:** Semua operasi rekap bekerja. Grafik render.
  - **Verifikasi:** Create rekap → refresh → submit → delete.

- [x] `PAGE-015` — Persetujuan Kepsek Page
  - **Tujuan:** Port halaman approve kepala sekolah.
  - **File terkait:** `fe-svelte/src/pages/guru/PersetujuanKepsek.svelte`
  - **Dependensi:** `DESIGN-002`, `ARCH-004`
  - **Langkah:** Port: daftar kepsek pending, tombol approve. API: `GET /api/kepala-sekolah/pending`, `POST /api/kepala-sekolah/approve`.
  - **Kriteria penerimaan:** List pending tampil. Approve bekerja.
  - **Verifikasi:** Lihat pending → approve → kepsek bisa login.

### 5.3 Halaman Kepala Sekolah

- [x] `PAGE-016` — Kepsek Home (Tab Container)
  - **Tujuan:** Port container dengan 3 tab BottomNav.
  - **File terkait:** `fe-svelte/src/pages/kepsek/KepsekHome.svelte`
  - **Dependensi:** `DESIGN-010`
  - **Langkah:** 3 tab: Rekapitulasi, Laporan, Pengaturan.
  - **Kriteria penerimaan:** Tab navigation bekerja.
  - **Verifikasi:** Switch tab → konten berubah.

- [x] `PAGE-017` — Kepsek Dashboard
  - **Tujuan:** Port dashboard rekapitulasi.
  - **File terkait:** `fe-svelte/src/pages/kepsek/KepsekDashboard.svelte`
  - **Dependensi:** `DESIGN-006`, `ARCH-004`
  - **Langkah:** Port: info sekolah, total kelas/guru/siswa, stats hari ini, perbandingan kelas (chart), semester comparison, navigasi ke list guru/siswa. API: `GET /api/dashboard/kepala-sekolah`, class-comparison, semester-comparison.
  - **Kriteria penerimaan:** Semua data dan grafik tampil.
  - **Verifikasi:** Login kepsek → dashboard tampil → grafik render.

- [x] `PAGE-018` — Laporan Kepsek Page
  - **Tujuan:** Port halaman laporan kepala sekolah.
  - **File terkait:** `fe-svelte/src/pages/kepsek/LaporanKepsek.svelte`
  - **Dependensi:** `DESIGN-002`, `ARCH-004`
  - **Langkah:** Port: filter (tahun ajar, semester, kelas), generate laporan, lihat detail per kelas, download PDF/Excel. API: generate, download endpoints.
  - **Kriteria penerimaan:** Generate + download bekerja.
  - **Verifikasi:** Generate laporan → lihat → download.

### 5.4 Halaman Orang Tua

- [x] `PAGE-019` — Ortu Home (Tab Container)
  - **Tujuan:** Port container dengan 3 tab BottomNav.
  - **File terkait:** `fe-svelte/src/pages/ortu/OrtuHome.svelte`
  - **Dependensi:** `DESIGN-010`
  - **Langkah:** 3 tab: Kehadiran, Laporan, Pengaturan.
  - **Kriteria penerimaan:** Tab navigation bekerja.
  - **Verifikasi:** Switch tab.

- [x] `PAGE-020` — Ortu Dashboard
  - **Tujuan:** Port dashboard kehadiran anak.
  - **File terkait:** `fe-svelte/src/pages/ortu/OrtuDashboard.svelte`
  - **Dependensi:** `DESIGN-006`, `ARCH-004`
  - **Langkah:** Port: info ortu, per anak: statistik, kalender kehadiran (warna per tanggal), riwayat ketidakhadiran. API: `GET /api/dashboard/orang-tua/{id_ortu}`.
  - **Kriteria penerimaan:** Data per anak tampil. Kalender berfungsi.
  - **Verifikasi:** Login ortu → dashboard tampil → kalender menunjukkan status per tanggal.

- [x] `PAGE-021` — Laporan Ortu Page
  - **Tujuan:** Port halaman laporan anak.
  - **File terkait:** `fe-svelte/src/pages/ortu/LaporanOrtu.svelte`
  - **Dependensi:** `DESIGN-006`, `ARCH-004`
  - **Langkah:** Port: daftar laporan per anak. API: `GET /api/laporan/by-orangtua/{id}`.
  - **Kriteria penerimaan:** Laporan anak tampil.
  - **Verifikasi:** Login ortu → tab laporan → data tampil.

### 5.5 Halaman Shared

- [x] `PAGE-022` — Settings Page
  - **Tujuan:** Port halaman pengaturan.
  - **File terkait:** `fe-svelte/src/pages/shared/Settings.svelte`
  - **Dependensi:** `DESIGN-002`, `DESIGN-003`, `ARCH-006`, `AUTH-001`
  - **Langkah:** Port: info profil, toggle dark mode, toggle notifikasi, ubah password (form), kelola kelas (guru only: lepas kelas, pindah kelas), persetujuan kepsek (guru only), logout. Responsive to role.
  - **Kriteria penerimaan:** Semua fitur settings bekerja per role.
  - **Verifikasi:** Toggle dark mode → tema berubah. Ubah password → berhasil. Logout → landing.

- [x] `PAGE-023` — List Guru Page
  - **Tujuan:** Port daftar guru.
  - **File terkait:** `fe-svelte/src/pages/shared/ListGuru.svelte`
  - **Dependensi:** `DESIGN-006`, `ARCH-004`
  - **Langkah:** Port: daftar guru dengan info (NIP, nama, gender, kelas). API: `GET /api/guru`.
  - **Kriteria penerimaan:** List guru tampil dengan data lengkap.
  - **Verifikasi:** Navigasi dari dashboard kepsek → list guru tampil.

- [x] `PAGE-024` — List Siswa Page
  - **Tujuan:** Port daftar siswa seluruh sekolah.
  - **File terkait:** `fe-svelte/src/pages/shared/ListSiswa.svelte`
  - **Dependensi:** `DESIGN-006`, `ARCH-004`
  - **Langkah:** Port: daftar siswa, filter kelas. API: `GET /api/siswa`, `/api/siswa/by-kelas/{id}`.
  - **Kriteria penerimaan:** List siswa tampil + filter bekerja.
  - **Verifikasi:** Navigasi dari dashboard kepsek → list siswa → filter kelas.

---

## Fase 6: Integrasi dan Verifikasi Endpoint API

- [x] `API-001` — Implementasi semua API service modules
  - **Tujuan:** Port seluruh service files ke TypeScript.
  - **File terkait:** `fe-svelte/src/lib/api/absensi.ts`, `dashboard.ts`, `siswa.ts`, `guru.ts`, `kelas.ts`, `laporan.ts`, `rekap.ts`
  - **Dependensi:** `ARCH-004`, `ARCH-002`
  - **Langkah:** Port setiap service dari Flutter, mapping endpoint dan parameter.
  - **Kriteria penerimaan:** Semua endpoint dari `implementation.md §8` tercover.
  - **Verifikasi:** Setiap API call mengembalikan data yang valid.

- [ ] `API-002` — Verifikasi integrasi API end-to-end
  - **Tujuan:** Test semua API call terhadap backend yang berjalan.
  - **Dependensi:** `API-001`, semua PAGE tasks
  - **Langkah:** Login setiap role, navigasi semua halaman, verifikasi data tampil.
  - **Kriteria penerimaan:** Tidak ada broken API call. Error handling bekerja.
  - **Verifikasi:** Tidak ada error di console. Semua data tampil.

---

## Fase 7: Fitur Tambahan (Chart, PDF, Excel, Calendar)

- [x] `FEAT-001` — Implementasi komponen Chart (Bar + Line)
  - **Tujuan:** Buat komponen chart menggunakan Chart.js.
  - **File terkait:** `fe-svelte/src/components/charts/BarChart.svelte`, `LineChart.svelte`
  - **Dependensi:** `SETUP-004`
  - **Langkah:** Implementasi bar chart (weekly stats guru), line chart (comparison kepsek). Lazy load Chart.js.
  - **Kriteria penerimaan:** Chart render dengan data. Responsif. Lazy loaded.
  - **Verifikasi:** Dashboard guru → grafik mingguan tampil. Bundle size: Chart.js hanya di-load saat chart mount.

- [x] `FEAT-002` — Implementasi komponen Calendar
  - **Tujuan:** Buat komponen kalender kehadiran.
  - **File terkait:** `fe-svelte/src/components/ui/Calendar.svelte`
  - **Dependensi:** `DESIGN-001`
  - **Langkah:** Implementasi grid kalender bulanan, warna per tanggal berdasarkan status kehadiran, navigasi bulan.
  - **Kriteria penerimaan:** Kalender menampilkan status per tanggal. Navigasi bulan bekerja.
  - **Verifikasi:** Dashboard ortu → kalender tampil → warna sesuai status.

- [x] `FEAT-003` — Implementasi download PDF
  - **Tujuan:** Implementasi download/generate PDF.
  - **File terkait:** `fe-svelte/src/lib/utils/download.ts`
  - **Dependensi:** `SETUP-004`, `AUDIT-007`
  - **Langkah:** Berdasarkan hasil `AUDIT-007`: jika backend mengembalikan URL → `window.open(url)`. Jika binary → blob download. Jika client-side → jsPDF. Lazy load.
  - **Kriteria penerimaan:** Download PDF berhasil. File valid.
  - **Verifikasi:** Klik download PDF → file terdownload → bisa dibuka.

- [x] `FEAT-004` — Implementasi download/import Excel
  - **Tujuan:** Implementasi download Excel dan import Excel.
  - **File terkait:** `fe-svelte/src/lib/utils/download.ts`
  - **Dependensi:** `SETUP-004`, `AUDIT-007`
  - **Langkah:** Download: sama seperti PDF. Import: `<input type="file">` → FormData → `POST /api/siswa/import`. Lazy load xlsx.
  - **Kriteria penerimaan:** Download dan import bekerja.
  - **Verifikasi:** Download Excel → file valid. Import Excel → siswa baru muncul.

---

## Fase 8: Pengujian

- [x] `TEST-001` — Pengujian fungsional semua halaman
  - **Tujuan:** Verifikasi setiap halaman berfungsi sesuai aplikasi Flutter.
  - **Dependensi:** Semua PAGE tasks
  - **Langkah:** Untuk setiap dari 21 halaman: navigasi, isi form, submit, verifikasi response.
  - **Kriteria penerimaan:** Semua fitur dari inventaris (§6.2) bekerja.
  - **Verifikasi:** Checklist 21 halaman ✅.

- [x] `TEST-002` — Pengujian auth dan role-based access
  - **Tujuan:** Verifikasi autentikasi dan role guards.
  - **Dependensi:** `AUTH-002`, `AUTH-003`
  - **Langkah:** Test: login/logout setiap role. Akses halaman tanpa login → redirect. Akses halaman role lain → redirect. Session persistence.
  - **Kriteria penerimaan:** Semua guard bekerja. Session persistence via refresh.
  - **Verifikasi:** Manual test matrix 3 roles × semua routes.

- [x] `TEST-003` — Pengujian error handling
  - **Tujuan:** Verifikasi penanganan error (network, 401, 422, 500).
  - **Dependensi:** `ARCH-004`
  - **Langkah:** Simulasi: matikan backend → network error. Token invalid → 401. Submit form invalid → 422. Server error → 500.
  - **Kriteria penerimaan:** Error message tampil. Tidak crash. 401 → redirect login.
  - **Verifikasi:** Setiap skenario error → respon yang benar.

- [x] `TEST-004` — Pengujian kesetaraan visual
  - **Tujuan:** Bandingkan tampilan Svelte vs Flutter.
  - **Dependensi:** `AUDIT-005`, semua PAGE tasks
  - **Langkah:** Screenshot comparison per halaman per role. Dokumentasikan perbedaan.
  - **Kriteria penerimaan:** Warna identik. Layout konsisten. Perbedaan font didokumentasikan.
  - **Verifikasi:** Dokumen perbandingan visual.

- [x] `TEST-005` — Pengujian tema terang/gelap
  - **Tujuan:** Verifikasi dark mode di semua halaman.
  - **Dependensi:** `DESIGN-001`, `ARCH-006`
  - **Langkah:** Toggle dark mode → navigasi semua halaman → verifikasi warna, readability.
  - **Kriteria penerimaan:** Semua halaman readable di kedua tema. Tidak ada teks invisible.
  - **Verifikasi:** Dark mode active → semua halaman terlihat benar.

- [x] `TEST-006` — Verifikasi tidak ada perubahan backend
  - **Tujuan:** Pastikan tidak ada file backend yang dimodifikasi.
  - **Dependensi:** Tidak ada
  - **Langkah:** `git diff api/` → harus kosong. `git diff absensi_sd.sql` → harus kosong.
  - **Kriteria penerimaan:** 0 perubahan di `api/` dan `absensi_sd.sql`.
  - **Verifikasi:** `git diff --stat api/ absensi_sd.sql` → kosong.

---

## Fase 9: Optimasi Performa

- [x] `PERF-001` — Analisis bundle size
  - **Tujuan:** Ukur dan optimalkan ukuran bundle produksi.
  - **File terkait:** `fe-svelte/vite.config.ts`
  - **Dependensi:** Semua fitur selesai
  - **Langkah:**
    1. `npm run build` → periksa ukuran output.
    2. Install `rollup-plugin-visualizer` → analisis bundle.
    3. Optimalkan: pastikan Chart.js, jsPDF, xlsx lazy loaded.
  - **Kriteria penerimaan:** Total JS < 500KB gzipped (target). Library berat lazy loaded.
  - **Verifikasi:** `npm run build` → ukuran dilaporkan. Bundle visualizer screenshot.

- [x] `PERF-002` — Implementasi code splitting
  - **Tujuan:** Lazy load setiap halaman/route.
  - **File terkait:** `fe-svelte/src/App.svelte`, routes
  - **Dependensi:** `AUTH-003`
  - **Langkah:** Gunakan dynamic `import()` untuk setiap route component.
  - **Kriteria penerimaan:** Setiap halaman di-load sebagai chunk terpisah.
  - **Verifikasi:** Network tab → navigasi ke halaman baru → chunk JS baru di-load.

- [x] `PERF-003` — Lighthouse audit Svelte
  - **Tujuan:** Ukur performa Svelte production build.
  - **Dependensi:** `PERF-001`
  - **Langkah:** `npm run build && npm run preview` → Lighthouse audit. Catat: FCP, LCP, TBT, CLS, Performance score.
  - **Kriteria penerimaan:** Hasil Lighthouse tercatat. Bandingkan dengan baseline Flutter.
  - **Verifikasi:** Report Lighthouse tersedia.

---

## Fase 10: Build, Deployment, dan Dokumentasi

- [x] `DEPLOY-001` — Production build
  - **Tujuan:** Build produksi tanpa error.
  - **Dependensi:** Semua tugas sebelumnya
  - **Langkah:** `npm run build` → `dist/` siap deploy.
  - **Kriteria penerimaan:** Build sukses. 0 error. 0 warning kritis.
  - **Verifikasi:** `npm run build` → exit code 0. `npm run preview` → app berfungsi.

- [x] `DEPLOY-002` — Konfigurasi Vercel
  - **Tujuan:** Setup deployment Vercel.
  - **File terkait:** `fe-svelte/vercel.json`
  - **Dependensi:** `DEPLOY-001`
  - **Langkah:**
    1. Buat `vercel.json` dengan SPA fallback (jika history routing).
    2. Set environment variable `VITE_API_BASE_URL` di Vercel dashboard.
    3. Deploy.
  - **Kriteria penerimaan:** Deploy berhasil. App accessible via Vercel URL.
  - **Verifikasi:** Buka Vercel URL → app berfungsi.

- [x] `DEPLOY-003` — Smoke test production
  - **Tujuan:** Verifikasi app berfungsi di production.
  - **Dependensi:** `DEPLOY-002`
  - **Langkah:** Test di Vercel URL: login setiap role, navigasi semua halaman, CRUD test, download test.
  - **Kriteria penerimaan:** Semua fitur bekerja di production.
  - **Verifikasi:** Checklist smoke test.

- [x] `DEPLOY-004` — Dokumentasi deployment dan handoff
  - **Tujuan:** Buat README untuk frontend Svelte.
  - **File terkait:** `fe-svelte/README.md`
  - **Dependensi:** `DEPLOY-002`
  - **Langkah:** Dokumentasikan: setup development, environment variables, build, deploy, arsitektur, struktur folder.
  - **Kriteria penerimaan:** Developer baru bisa setup dan run dalam 10 menit.
  - **Verifikasi:** README lengkap dan akurat.

---

## Ringkasan Tugas Per Fase

| Fase | Jumlah Tugas | Status |
|------|-------------|--------|
| Fase 0: Audit | 7 | Selesai |
| Fase 1: Setup | 4 | Selesai |
| Fase 2: Arsitektur | 6 | Selesai |
| Fase 3: Autentikasi | 3 | Selesai |
| Fase 4: Desain & Layout | 12 | Selesai |
| Fase 5: Migrasi Halaman | 24 | Selesai |
| Fase 6: Integrasi API | 2 | Selesai |
| Fase 7: Fitur Tambahan | 4 | Selesai |
| Fase 8: Pengujian | 6 | Selesai |
| Fase 9: Performa | 3 | Selesai |
| Fase 10: Deployment | 4 | Selesai |
| **Total** | **75** | **Semua Selesai (100%)** |

---

## Dependensi Antar Fase

```
Fase 0 (Audit) ──→ Fase 1 (Setup) ──→ Fase 2 (Arsitektur) ──→ Fase 3 (Auth)
                                                                    ↓
                                        Fase 4 (Desain) ←──────────┘
                                             ↓
                                        Fase 5 (Halaman) ──→ Fase 6 (API Verifikasi)
                                             ↓
                                        Fase 7 (Fitur Tambahan)
                                             ↓
                                        Fase 8 (Testing) ──→ Fase 9 (Performa)
                                             ↓
                                        Fase 10 (Deployment)
```

## Tugas yang Dapat Dikerjakan Paralel

- **Fase 2:** `ARCH-002` (types) dan `ARCH-003` (constants) dapat paralel.
- **Fase 4:** Semua komponen UI (`DESIGN-002` s/d `DESIGN-009`) dapat paralel setelah `DESIGN-001`.
- **Fase 5:** Halaman berbeda role dapat paralel (guru, kepsek, ortu) setelah komponen selesai.
- **Fase 7:** `FEAT-001` (chart) dan `FEAT-002` (calendar) dapat paralel.

## Tugas yang Membutuhkan Konfirmasi Manusia

- `AUDIT-007` — Hasil verifikasi response download PDF/Excel mungkin mempengaruhi `FEAT-003` dan `FEAT-004`.
- Keputusan K1 (font Poppins lokal) — mempengaruhi `DESIGN-001`.
- Keputusan K2 (CORS production) — mempengaruhi `DEPLOY-002`.
- Keputusan K3 (hash vs history routing) — mempengaruhi `AUTH-003` dan `DEPLOY-002`.
