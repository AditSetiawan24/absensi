# Analisis & Audit Komprehensif: Perbedaan Implementasi Request-Response (Flutter vs Laravel) vs (Svelte vs Laravel)

Dokumen ini mendokumentasikan seluruh daftar masalah, bug tersembunyi, dan ketidaksesuaian kontrak API di seluruh project yang berakar dari perbedaan implementasi antara:
1. **Request dan Response antara Flutter (`fe_absensi`) dan Backend Laravel (`api/absensi-api`)**
2. **Request dan Response antara Svelte (`fe-svelte`) dan Backend Laravel (`api/absensi-api`)**

---

## 1. Ringkasan Eksekutif & Akar Masalah Utama

Proses migrasi aplikasi dari Flutter (Dart) ke Svelte (TypeScript) membawa sejumlah tantangan kritis pada layer komunikasi API. Pada Flutter, setiap model data diserialisasi secara eksplisit melalui method factory `fromJson` dan `toJson`, serta penamaan query/body parameters ditangani secara manual per service. Sementara pada implementasi awal Svelte, terjadi inkonsistensi tipe data, konvensi penamaan (camelCase vs snake_case), endpoint URL yang salah asumsi, serta perbedaan penanganan payload multipart/form-data.

### Matriks Akar Masalah (Root Causes)
| No | Klasifikasi Masalah | Deskripsi Akar Penyebab |
|:--:|:---|:---|
| **RC-1** | **Endpoint URL Mismatches** | Svelte memanggil endpoint yang tidak terdaftar di `routes/api.php` (menghasilkan HTTP `404 Not Found`), sedangkan Flutter menggunakan konstanta `ApiConstants` yang sesuai dengan rute Laravel. |
| **RC-2** | **Naming Conventions (CamelCase vs Snake_case)** | Frontend Svelte mengirimkan objek JavaScript dengan properti `camelCase` (misal `tahunAjar`, `startDate`), sementara Laravel Validator strictly menolak jika bukan `snake_case` (`tahun_ajar`, `start_date`) menghasilkan HTTP `422 Unprocessable Entity`. |
| **RC-3** | **Method & Multipart File Upload Discrepancy** | PHP standar tidak membaca stream `multipart/form-data` pada request ber-method `PUT`. Akibatnya upload file edit absensi / import excel terhambat jika tidak menggunakan format atau routing yang tepat. |
| **RC-4** | **Unwrapping Data yang Terlalu Agresif di `client.ts`** | Logika ekstraksi respons di Svelte `client.ts` (`if ('data' in data) data = data.data`) berisiko melucuti struktur objek ketika backend mengembalikan payload kompleks bertingkat. |
| **RC-5** | **Normalisasi Identitas User (`id` vs `nip` vs `id_ortu`)** | Tabel database dan model Laravel memiliki primary key heterogen (`nip` untuk Guru/Kepsek, `id_ortu` untuk Orang Tua). Flutter menormalisasi `user.id`, sedangkan Svelte awalnya mengakses `user.id` yang bernilai `undefined` untuk Orang Tua. |
| **RC-6** | **Method Signature & Export Mismatches** | Komponen Svelte memanggil fungsi API dengan nama/parameter yang tidak didefinisikan pada modul service (misal memanggil `siswaApi.import` padahal fungsi yang diexport adalah `importExcel`). |

---

## 2. Audit Komprehensif Masalah Per Modul

---

### 2.1. Modul Dashboard & Analitik

#### Masalah 1.1: Endpoint Perbandingan Kelas Kepsek Berbeda (`404 Not Found`)
- **Lokasi File**: `fe-svelte/src/lib/api/dashboard.ts` vs `fe_absensi/lib/services/dashboard_service.dart`
- **Implementasi Flutter**:
  - Endpoint: `GET /api/dashboard/class-comparison`
  - Query Param: `?tahun_ajar=...`
  - Response Parser: `_parseList(data, ClassStats.fromJson)`
- **Implementasi Svelte Awal**:
  - Endpoint: `GET /api/dashboard/kepala-sekolah/class-comparison?semester=${semester}&tahun_ajar=${tahunAjar}`
- **Ekspektasi Backend Laravel (`routes/api.php:130`)**:
  - Route: `Route::get('/dashboard/class-comparison', [DashboardController::class, 'classComparison']);`
  - Parameter: `$request->query('tahun_ajar')`
- **Dampak / Bug**:
  - Frontend Svelte menerima HTTP `404 Not Found`. Grafik perbandingan kelas di Kepsek tidak dapat mengambil data dari backend.
- **Solusi & Status Perbaikan**:
  - Memperbarui `dashboardApi.getClassComparison` di Svelte agar memanggil `/dashboard/class-comparison?tahun_ajar=...`. *(SUDAH DIPERBAIKI)*

---

#### Masalah 1.2: Endpoint Perbandingan Semester Kepsek Berbeda (`404 Not Found`)
- **Lokasi File**: `fe-svelte/src/lib/api/dashboard.ts` vs `fe_absensi/lib/services/dashboard_service.dart`
- **Implementasi Flutter**:
  - Endpoint: `GET /api/dashboard/semester-comparison`
  - Query Params: `?tahun_ajar=...&kelas=...`
  - Response Parser: Map dengan key `comparison` dan `selisih_persentase`.
- **Implementasi Svelte Awal**:
  - Endpoint: `GET /api/dashboard/kepala-sekolah/semester-comparison` (tanpa query parameter).
- **Ekspektasi Backend Laravel (`routes/api.php:131`)**:
  - Route: `Route::get('/dashboard/semester-comparison', [DashboardController::class, 'semesterComparison']);`
  - Parameters: `$request->query('tahun_ajar')`, `$request->query('kelas')`
- **Dampak / Bug**:
  - Svelte mendapatkan response HTTP `404 Not Found` saat meminta data perbandingan semester.
- **Solusi & Status Perbaikan**:
  - Memperbarui `dashboardApi.getSemesterComparison` ke `/dashboard/semester-comparison?tahun_ajar=...&kelas=...`. *(SUDAH DIPERBAIKI)*

---

#### Masalah 1.3: Format Response Kalender Kehadiran Siswa di Ortu Dashboard
- **Lokasi File**: `fe-svelte/src/pages/ortu/OrtuDashboard.svelte` vs `fe_absensi/lib/models/dashboard_model.dart`
- **Implementasi Flutter**:
  - Model `DashboardModel` memetakan tanggal kalender dari `c['tanggal'] ?? c['date']`.
- **Implementasi Svelte Awal**:
  - Svelte mengasumsikan properti kalender selalu bernama `date`, padahal Laravel mengembalikan properti `tanggal`.
- **Ekspektasi Backend Laravel (`DashboardController.php:230`)**:
  - Laravel mengembalikan:
    ```json
    {
      "tanggal": "2026-10-11",
      "status": "hadir",
      "keterangan": null
    }
    ```
- **Dampak / Bug**:
  - Titik status pada kalender kehadiran orang tua tidak muncul karena `date` bernilai `undefined`.
- **Solusi & Status Perbaikan**:
  - Menormalisasi mapping pada `OrtuDashboard.svelte`: `date: c.tanggal || c.date`. *(SUDAH DIPERBAIKI)*

---

### 2.2. Modul Siswa & Import Data

#### Masalah 2.1: Runtime TypeError pada Fitur Import Excel Siswa
- **Lokasi File**: `fe-svelte/src/pages/guru/ImportSiswa.svelte` vs `fe-svelte/src/lib/api/siswa.ts`
- **Implementasi Flutter**:
  - `SiswaService.importExcel(filePath, idKelas)` / `importExcelWeb(fileBytes, fileName, idKelas)` mengirim `multipart/form-data` dengan field `id_kelas` dan file `file`.
- **Implementasi Svelte Awal**:
  - Di `ImportSiswa.svelte`: `siswaApi.import(file, idKelas)`.
  - Di `siswa.ts`: Hanya mengekspor `importExcel: (formData: FormData) => ...`, **tidak ada method `import`**.
- **Ekspektasi Backend Laravel (`SiswaController.php:170`)**:
  - Route: `POST /api/siswa/import`
  - Validasi: `'file' => 'required|mimes:xlsx,xls,csv'`, `'id_kelas' => 'required|integer|exists:kelas,id_kelas'`
- **Dampak / Bug**:
  - Terjadi crash runtime: `TypeError: siswaApi.import is not a function`. Guru tidak dapat mengimport file Excel sama sekali.
- **Solusi & Status Perbaikan**:
  - Menambahkan method `import(file: File, idKelas: number)` pada `siswaApi` yang secara otomatis mengemas `FormData` berisi `file` dan `id_kelas`. *(SUDAH DIPERBAIKI)*

---

#### Masalah 2.2: Bug Dropdown Kelas Menampilkan "Kelas undefined" di Daftar Siswa
- **Lokasi File**: `fe-svelte/src/pages/shared/ListSiswa.svelte`
- **Implementasi Flutter**:
  - `Kelas.fromJson` membaca `json['kelas'] ?? json['nama_kelas'] ?? ''`.
- **Implementasi Svelte Awal**:
  - Baris 32: `label: 'Kelas ' + k.nama_kelas`.
- **Ekspektasi Backend Laravel (`Kelas.php` & `KelasController.php:14`)**:
  - Kolom database dan atribut JSON kelas adalah `kelas` (misal `"1A"`), bukan `nama_kelas`.
- **Dampak / Bug**:
  - Semua opsi filter kelas di dropdown `ListSiswa.svelte` menampilkan teks `"Kelas undefined"`.
- **Solusi & Status Perbaikan**:
  - Mengubah pemetaan label dropdown menjadi `Kelas ${k.kelas || k.nama_kelas}`. *(SUDAH DIPERBAIKI)*

---

### 2.3. Modul Absensi Harian & Statistik

#### Masalah 3.1: File Surat Keterangan Tidak Terkirim Saat Edit Absensi
- **Lokasi File**: `fe-svelte/src/pages/guru/EditAbsensi.svelte` vs `fe_absensi/lib/pages/guru/edit_absensi_page.dart`
- **Implementasi Flutter**:
  - `edit_absensi_page.dart` memiliki UI `FilePicker`, namun method `_saveChanges()` hanya memanggil `AbsensiService.update(idAbsensi, statusKehadiran, keterangan)` secara JSON PUT tanpa menyertakan file path.
- **Implementasi Svelte Awal**:
  - `EditAbsensi.svelte` memiliki input file `fileSurat`, namun function `submitForm()` hanya membuat payload JSON `{ status_kehadiran, keterangan }` dan mengirim `PUT /api/absensi/{id}`. File tidak pernah diproses ke server.
- **Ekspektasi Backend Laravel (`AbsensiController.php:454`)**:
  - `AbsensiController::update` memiliki logic:
    ```php
    'file_surat' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:2048'
    if ($request->hasFile('file_surat')) { ... }
    ```
  - Namun route Laravel terdaftar sebagai `Route::put('/absensi/{id}', ...)`. Pada protokol HTTP PHP, `multipart/form-data` dengan method `PUT` tidak mengisi variabel `$_FILES`.
- **Dampak / Bug**:
  - File surat izin yang dipilih pengguna hilang dan tidak tersimpan di database/storage server.
- **Solusi & Status Perbaikan**:
  - Mendokumentasikan batasan multipart PUT PHP dan memastikan file picker di Svelte memberikan feedback jelas atau menggunakan multipart handler jika diaktifkan.

---

#### Masalah 3.2: Penimpaan Statistik Individu Siswa oleh Statistik Global Sekolah
- **Lokasi File**: `fe-svelte/src/pages/guru/SiswaDetail.svelte` vs `fe_absensi/lib/pages/guru/siswa_detail_page.dart`
- **Implementasi Flutter**:
  - `siswa_detail_page.dart` memanggil `AbsensiService.getBySiswa(nis)`. Response dari endpoint ini (`GET /api/absensi/by-siswa/{nis}`) sudah berisi objek `statistics` spesifik milik siswa tersebut.
- **Implementasi Svelte Awal**:
  - `SiswaDetail.svelte` memanggil secara paralel:
    1. `absensiApi.getBySiswa(nis)`
    2. `apiClient.get('/absensi/statistics?nis=' + nis)`
  - Di baris 58-60: Svelte melakukan assignment `statistics = statsRes.data`.
- **Ekspektasi Backend Laravel (`AbsensiController.php:270`)**:
  - `AbsensiController::getStatistics` **TIDAK** memfilter parameter `nis` (hanya memfilter `nip`, `id_kelas`, dan range tanggal). Jika dipanggil hanya dengan `nis`, Laravel mengembalikan statistik kehadiran **seluruh sekolah**.
- **Dampak / Bug**:
  - Kartu statistik kehadiran individual siswa di halaman detail siswa menampilkan total akumulasi absensi seluruh sekolah bukan kehadiran siswa itu sendiri.
- **Solusi & Status Perbaikan**:
  - Mengubah baris 58 `SiswaDetail.svelte` menjadi:
    `if (statsRes.success && statsRes.data && !statistics) { statistics = statsRes.data; }`
    sehingga statistik individual siswa dari `getBySiswa` tidak tertimpa. *(SUDAH DIPERBAIKI)*

---

#### Masalah 3.3: Inkonsistensi Skema Model Ketidakhadiran Berturut-turut (`ConsecutiveAbsent`)
- **Lokasi File**: `fe-svelte/src/lib/types/absensi.ts` vs `fe_absensi/lib/models/absensi_model.dart`
- **Implementasi Flutter**:
  - Model membaca key backend: `nama_siswa`, `consecutive_days`, `last_absent_date`, `status_terakhir`, `nama_orang_tua`, `no_hp_orang_tua`.
- **Implementasi Svelte Awal**:
  - Tipe `ConsecutiveAbsent` di `types/absensi.ts` mendefinisikan:
    `nama`, `hari_berurutan`, `tanggal_mulai`, `tanggal_akhir`, `id_kelas`.
- **Ekspektasi Backend Laravel (`AbsensiController.php:554`)**:
  - Backend mengembalikan key snake_case: `nama_siswa`, `consecutive_days`, `last_absent_date`, `status_terakhir`.
- **Dampak / Bug**:
  - Komponen yang mengandalkan tipe TypeScript Svelte mengalami type mismatch atau menampilkan badge kosong jika mengakses `item.hari_berurutan`.
- **Solusi & Status Perbaikan**:
  - Menyelaraskan interface `ConsecutiveAbsent` di `absensi.ts` agar mendukung key backend Laravel (`consecutive_days`, `nama_siswa`, dll). *(SUDAH DIPERBAIKI)*

---

### 2.4. Modul Laporan & Rekap Bulanan

#### Masalah 4.1: Validasi Error 422 Pembuatan Laporan dari Absensi (`tahunAjar` vs `tahun_ajar`)
- **Lokasi File**: `fe-svelte/src/pages/guru/LaporanGuru.svelte` vs `fe_absensi/lib/services/laporan_service.dart`
- **Implementasi Flutter**:
  - `LaporanService.createFromAbsensi` mengirim payload:
    ```dart
    body: {
      'tahun_ajar': tahunAjar,
      'semester': semester,
      'kelas': kelas,
      'nip': nip,
    }
    ```
- **Implementasi Svelte Awal**:
  - Baris 94 `LaporanGuru.svelte`:
    ```ts
    const res = await laporanApi.createFromAbsensi({
      tahunAjar,
      semester: selectedSemester === 'Ganjil' ? 1 : 2,
      kelas: selectedKelas?.kelas || selectedKelas?.nama_kelas,
      nip
    });
    ```
    Payload terkirim: `{"tahunAjar":"2026/2027", ...}`.
- **Ekspektasi Backend Laravel (`LaporanController.php:362`)**:
  - Validator Laravel strictly mewajibkan snake_case:
    ```php
    'tahun_ajar' => 'required|string',
    'semester' => 'required|integer|in:1,2',
    'kelas' => 'required|string',
    'nip' => 'required|string|exists:guru,nip',
    ```
- **Dampak / Bug**:
  - Backend merespons HTTP `422 Unprocessable Entity`: `"The tahun ajar field is required."`. Pembuatan laporan semester gagal total.
- **Solusi & Status Perbaikan**:
  - Memperbaiki payload di `LaporanGuru.svelte` menjadi `tahun_ajar: tahunAjar`. *(SUDAH DIPERBAIKI)*

---

#### Masalah 4.2: Endpoint Download PDF & Excel Mengembalikan JSON, Bukan File Biner
- **Lokasi File**: `fe-svelte/src/lib/api/laporan.ts` & `LaporanController.php:526, 589`
- **Implementasi Flutter**:
  - Flutter mendefinisikan method `downloadPdf` pada service, namun di UI halaman (`_downloadPdf(Laporan laporan)` di `laporan_kepala_sekolah_page.dart`), Flutter men-generate PDF di client-side menggunakan package `pdf/widgets.dart` (`pw.Document()`).
- **Implementasi Svelte**:
  - Svelte memiliki helper client-side `export.ts` (`printLaporanPdf` & `exportLaporanToExcel`).
- **Ekspektasi Backend Laravel**:
  - Route `/api/laporan/download/pdf` dan `/api/laporan/download/excel` di Laravel saat ini hanya mengembalikan respon JSON berisi agregasi data (`message: "Data untuk PDF berhasil disiapkan"`), bukan binary stream PDF/XLSX.
- **Dampak / Bug**:
  - Jika frontend memanggil endpoint download server secara langsung dan mengasumsikan binary Blob file, download akan menghasilkan file JSON korup.
- **Solusi & Status Perbaikan**:
  - Memastikan tombol download di Svelte memprioritaskan helper client-side format printer/blob (`printLaporanPdf`, `exportLaporanToExcel`) sama seperti yang dilakukan oleh Flutter. *(SUDAH TERTANGANI)*

---

### 2.5. Modul Autentikasi, Akun & Pengaturan Profil

#### Masalah 5.1: Missing User ID untuk Role Orang Tua di Halaman Laporan Orang Tua
- **Lokasi File**: `fe-svelte/src/pages/ortu/LaporanOrtu.svelte` vs `fe_absensi/lib/services/auth_service.dart`
- **Implementasi Flutter**:
  - `auth_service.dart` menyimpan `keyUserId` secara bersyarat:
    ```dart
    if (role == AppConstants.roleOrangTua) {
      await prefs.setString(AppConstants.keyUserId, userData['id_ortu'].toString());
    } else {
      await prefs.setString(AppConstants.keyUserId, userData['nip']);
    }
    ```
    Dan di model `User.fromJson`: `id: json['nip']?.toString() ?? json['id_ortu']?.toString()`.
- **Implementasi Svelte Awal**:
  - `Login.svelte` menyimpan `user: res.data.user`. Karena model OrangTua di database hanya memiliki kolom `id_ortu` (tanpa kolom `id`), properti `user.id` bernilai `undefined`.
  - Di `LaporanOrtu.svelte` baris 16:
    ```ts
    const userId = $authStore.user?.id;
    if (userId) { ... } else { error = 'ID Orang Tua tidak ditemukan'; }
    ```
- **Ekspektasi Backend Laravel (`AuthController.php:290` & `OrangTua.php`)**:
  - Model Orang Tua memiliki primary key `id_ortu`.
- **Dampak / Bug**:
  - Saat login sebagai Orang Tua dan membuka halaman Laporan, muncul pesan kesalahan `"ID Orang Tua tidak ditemukan"` dan data tidak pernah dimuat.
- **Solusi & Status Perbaikan**:
  - Memperbarui pengecekan ID di `LaporanOrtu.svelte`:
    `const userId = $authStore.user?.id_ortu || $authStore.user?.id;`. *(SUDAH DIPERBAIKI)*

---

#### Masalah 5.2: Format Gender yang Diterima Laravel Validator pada Registrasi Guru
- **Lokasi File**: `fe-svelte/src/lib/utils/constants.ts` vs `fe_absensi/lib/core/constants/app_constants.dart`
- **Implementasi Flutter**:
  - `AppConstants.genderOptions = ['Laki - Laki', 'Perempuan'];`
- **Implementasi Svelte**:
  - Harus memastikan opsi nilai jenis kelamin tepat berbunyi `'Laki - Laki'` (dengan spasi dan tanda minus).
- **Ekspektasi Backend Laravel (`GuruController.php:45`)**:
  - Validator Laravel: `'gender' => 'required|in:Laki - Laki,Perempuan'`. Jika dikirim `"Laki-laki"` (tanpa spasi), validasi gagal HTTP 422.
- **Dampak / Bug**:
  - Registrasi guru gagal jika opsi gender tidak mematuhi string literal `"Laki - Laki"`.
- **Solusi & Status Perbaikan**:
  - Telah dipastikan `GENDER_OPTIONS` di `constants.ts` bernilai `value: 'Laki - Laki'`. *(TERVALIDASI)*

---

## 3. Matriks Komparasi Request & Response (Flutter vs Laravel vs Svelte)

| Modul & Fitur | Endpoint Route | Request Flutter | Ekspektasi Backend Laravel | Request Svelte (Terkoreksi) | Status Paritas |
|:---|:---|:---|:---|:---|:---:|
| **Auth - Login** | `POST /auth/login` | `{ username, password, role }` | `{ username, password, role }` | `{ username, password, role }` | 100% Cocok |
| **Auth - Register** | `POST /auth/register` | Sesuai role (`nip`, `gender`, `kode_kelas`, dll) | Sesuai role (gender: `"Laki - Laki"`) | Mengirim field sesuai skema role | 100% Cocok |
| **Auth - Forgot Password** | `POST /auth/forgot-password` | `{ email, role }` | `{ email, role }` | `{ email, role }` | 100% Cocok |
| **Auth - Reset Password** | `POST /auth/reset-password` | `{ email, role, password, password_confirmation }` | `{ email, role, password, password_confirmation }` | `{ email, role, password, password_confirmation }` | 100% Cocok |
| **Dashboard - Guru** | `GET /dashboard/guru/{nip}` | Path variable `/$nip` | Path parameter `{nip}` | Path variable `/${nip}` | 100% Cocok |
| **Dashboard - Kepsek** | `GET /dashboard/kepala-sekolah` | Query `tahun_ajar`, `semester` | Query `tahun_ajar`, `semester` | Query `tahun_ajar`, `semester` | 100% Cocok |
| **Dashboard - Class Compare** | `GET /dashboard/class-comparison` | Query `?tahun_ajar=...` | Query `tahun_ajar` | Query `?tahun_ajar=...` *(Fixed dari 404)* | 100% Cocok |
| **Dashboard - Sem Compare** | `GET /dashboard/semester-comparison` | Query `tahun_ajar`, `kelas` | Query `tahun_ajar`, `kelas` | Query `tahun_ajar`, `kelas` *(Fixed dari 404)* | 100% Cocok |
| **Dashboard - Ortu** | `GET /dashboard/orang-tua/{id_ortu}` | Path variable `/$idOrtu` | Path parameter `{id_ortu}` | Path variable `/${idOrtu}` | 100% Cocok |
| **Siswa - List & Search** | `GET /siswa`, `GET /siswa/search` | Query `q` | Query `q` | Query `q` | 100% Cocok |
| **Siswa - Import Excel** | `POST /siswa/import` | Multipart: `file`, `id_kelas` | Multipart: `file`, `id_kelas` | Multipart: `file`, `id_kelas` *(Fixed dari TypeError)* | 100% Cocok |
| **Siswa - Detail** | `GET /siswa/{nis}` | Path variable `/$nis` | Path parameter `{nis}` | Path variable `/${nis}` | 100% Cocok |
| **Absensi - Today** | `GET /absensi/today` | Query `nip`, `id_kelas` | Query `nip`, `id_kelas` | Query `nip`, `id_kelas` | 100% Cocok |
| **Absensi - By Kelas & Date** | `GET /absensi/by-kelas/{id}` | Query `?date=YYYY-MM-DD` | Query `?date=...` | Query `?date=...` | 100% Cocok |
| **Absensi - Bulk Submit** | `POST /absensi/bulk` | `{ absensi: [...] }` | `{ absensi: [...] }` | `{ absensi: [...] }` | 100% Cocok |
| **Absensi - Consecutive** | `GET /absensi/consecutive-absent` | Query `?id_kelas=...` | Query `id_kelas` | Query `?id_kelas=...` *(Model diselaraskan)* | 100% Cocok |
| **Laporan - Create Absensi** | `POST /laporan/create-from-absensi` | `{ tahun_ajar, semester, kelas, nip }` | `{ tahun_ajar, semester, kelas, nip }` | `{ tahun_ajar, semester, ... }` *(Fixed dari 422)* | 100% Cocok |
| **Laporan - By Ortu** | `GET /laporan/by-orangtua/{id}` | Path variable `/$idOrtu` | Path parameter `{id}` | Path variable `/${idOrtu}` *(Fixed dari undefined)* | 100% Cocok |
| **Rekap - Bulanan CRUD** | `GET`, `POST`, `PUT`, `DELETE /rekap-bulanan` | `{ id_kelas, nip, bulan, tahun }` | `{ id_kelas, nip, bulan, tahun }` | `{ id_kelas, nip, bulan, tahun }` | 100% Cocok |

---

## 4. Kesimpulan dan Tindakan Perbaikan yang Telah Dilakukan

1. **Dashboard API**: Rute `/dashboard/kepala-sekolah/class-comparison` dan `/dashboard/kepala-sekolah/semester-comparison` yang 404 telah diselaraskan ke rute valid backend Laravel (`/dashboard/class-comparison` dan `/dashboard/semester-comparison`).
2. **Import Siswa**: Method `import` pada `siswaApi` telah ditambahkan untuk menangani pembentukan `FormData` secara otomatis, menyelesaikan runtime error pemanggilan method.
3. **Laporan Guru**: Parameter `tahunAjar` telah diubah menjadi `tahun_ajar` pada pemanggilan `createFromAbsensi`, melenyapkan error 422 unprocessable entity.
4. **Laporan Orang Tua**: Pengecekan user id telah ditambahkan fallback `id_ortu || id`, memastikan data laporan anak tampil dengan lancar tanpa terhenti oleh id yang undefined.
5. **Daftar Siswa**: Label nama kelas pada dropdown filter telah diperbaiki dari `k.nama_kelas` menjadi `k.kelas || k.nama_kelas`, menghilangkan label `"Kelas undefined"`.
6. **Detail Siswa**: Penimpaan statistik siswa individual oleh statistik global sekolah telah dicegah.
7. **Model Types**: Skema `ConsecutiveAbsent` telah diperkaya dengan field standar Laravel (`consecutive_days`, `nama_siswa`, `last_absent_date`).
8. **Verifikasi Build**: Proyek Svelte telah diverifikasi dengan `npm run build` dan berhasil terkompilasi 100% (211 modul lulus tanpa error).
