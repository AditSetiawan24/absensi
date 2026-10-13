# E-Absensi Siswa (Svelte Frontend)

Aplikasi frontend untuk sistem manajemen presensi E-Absensi Siswa SD Negeri Kemutung Kidul.
Aplikasi ini di-rewrite menggunakan Svelte 5 + Vite + TypeScript dari basis kode Flutter Web sebelumnya, tanpa mengubah dependensi backend.

## Teknologi

- **Framework:** Svelte 5
- **Build Tool:** Vite
- **Bahasa:** TypeScript
- **Routing:** svelte-spa-router (hash-based routing)
- **Styling:** Vanilla CSS dengan CSS Variables (`src/styles/theme.css`)
- **Chart:** Chart.js

## Struktur Direktori

```text
src/
├── components/
│   ├── charts/        # Komponen Chart (BarChart, LineChart)
│   ├── layout/        # Komponen Layout (PageLayout, AppBar, BottomNav)
│   └── ui/            # Komponen Dasar (Button, TextField, Modal, dll)
├── lib/
│   ├── api/           # API Services (Client, Auth, Dashboard, Siswa, dll)
│   ├── stores/        # Global Stores (Auth Store, Toast Store, Router Store)
│   └── utils/         # Fungsi Helper (Date formatter, download)
├── pages/
│   ├── guru/          # Halaman Role Guru
│   ├── kepsek/        # Halaman Role Kepala Sekolah
│   ├── ortu/          # Halaman Role Orang Tua
│   └── shared/        # Halaman Global/Shared (Login, About, Settings)
├── styles/            # Gaya global & theme
├── App.svelte         # Root Component & Routes Configuration
└── main.ts            # Entry Point
```

## Setup & Development

### 1. Install Dependencies
```bash
npm install
```

### 2. Environment Variables
Buat file `.env` berdasarkan `.env.example`:
```
VITE_API_BASE_URL=http://localhost:8000
```
*(Ganti sesuai URL backend Laravel lokal Anda)*

### 3. Jalankan Development Server
```bash
npm run dev
```
Aplikasi akan tersedia di `http://localhost:5173`.

## Build & Deployment

Untuk mendeploy aplikasi ke production:

1. Jalankan build command:
```bash
npm run build
```
2. Hasil build akan berada di dalam folder `dist/`. Anda dapat menghosting folder `dist/` ke Vercel, Netlify, atau layanan web hosting static lainnya.
3. Karena menggunakan Hash-based routing, konfigurasi fallback SPA (seperti `rewrites` di Vercel atau `_redirects` di Netlify) bersifat opsional namun direkomendasikan.

## Penjelasan Role

- **Guru:** Mengisi kehadiran harian (bulk insert), mengedit kehadiran, manajemen data siswa, generate rekap.
- **Kepala Sekolah:** Melihat rekapitulasi sekolah, membandingkan persentase absensi antar kelas, menyetujui akun kepsek, melihat seluruh laporan.
- **Orang Tua / Wali Murid:** Melihat ringkasan kehadiran anak (kalender/chart), dan mendownload histori absensi.

---
*Developed by Tim Pengembang E-Absensi SD Negeri Kemutung Kidul (2026).*
