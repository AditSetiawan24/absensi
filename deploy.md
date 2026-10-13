# Panduan Lengkap Deploy: Laravel Backend (GoogieHost DirectAdmin) & Svelte Frontend (Vercel)

Panduan ini dibuat secara **langkah demi langkah (step-by-step)** dengan bahasa yang mudah dipahami, khusus untuk Anda yang melakukan deploy aplikasi web Absensi SD menggunakan **GoogieHost (DirectAdmin Panel)** untuk backend & database, serta **Vercel** untuk frontend Svelte.

---

## Daftar Isi
1. [Arsitektur & Konsep Dasar](#arsitektur--konsep-dasar)
2. [Keuntungan GoogieHost (DirectAdmin) vs InfinityFree](#keuntungan-googiehost-directadmin-vs-infinityfree)
3. [BAGIAN 1: Menyiapkan Akun & Database MySQL di GoogieHost (DirectAdmin)](#bagian-1-menyiapkan-akun--database-mysql-di-googiehost-directadmin)
4. [BAGIAN 2: Deploy Laravel Backend ke GoogieHost (DirectAdmin)](#bagian-2-deploy-laravel-backend-ke-googiehost-directadmin)
5. [BAGIAN 3: Pengaturan CORS & Uji Coba Endpoint API](#bagian-3-pengaturan-cors--uji-coba-endpoint-api)
6. [BAGIAN 4: Deploy Frontend Svelte ke Vercel](#bagian-4-deploy-frontend-svelte-ke-vercel)
7. [BAGIAN 5: Uji Coba Lengkap & Troubleshooting Masalah Umum](#bagian-5-uji-coba-lengkap--troubleshooting-masalah-umum)

---

## Arsitektur & Konsep Dasar

Aplikasi ini menggunakan arsitektur **terpisah (decoupled/headless)**:
* **Backend (Laravel API + Database MySQL)**: Dihosting di **GoogieHost** yang menggunakan kontrol panel **DirectAdmin**. Bertugas mengelola database, autentikasi, serta seluruh endpoint REST API.
* **Frontend (Svelte + Vite SPA)**: Dideploy di **Vercel**. Bertugas menampilkan antarmuka pengguna yang cepat di browser dan mengirim request HTTP (`fetch`) ke Backend Laravel di GoogieHost.

```
[ Pengguna di Browser / HP ]
        │
        ├──► Buka Tampilan Frontend (Vercel: https://absensi-sd.vercel.app)
        │
        └──► Request Data API (Fetch / REST) ──► Backend Laravel (GoogieHost: https://domain-anda.cu.ma/api)
                                                            │
                                                            └──► Database MySQL (Localhost di GoogieHost)
```

---

## Keuntungan GoogieHost (DirectAdmin) vs InfinityFree

1. **Tidak Ada Masalah Bot Protection Cookie (`aes.js`)**: InfinityFree sering memblokir request API dari Vercel dengan kode `403 Forbidden` atau respons HTML script proteksi. GoogieHost tidak memblokir REST API cross-origin, sehingga panggilan API dari Vercel berjalan lancar.
2. **File Manager Mendukung Extract/Unzip Langsung**: Di DirectAdmin, Anda bisa mengunggah 1 file `.zip` berisi seluruh project Laravel dan mengekstraknya dalam hitungan detik. Anda tidak perlu menunggu berjam-jam mengunggah ribuan file via FTP seperti di InfinityFree.
3. **Database Berjalan di `localhost`**: Di GoogieHost, MySQL berada di server yang sama (`DB_HOST=127.0.0.1` atau `localhost`), sehingga latensi query database jauh lebih cepat dan konfigurasinya standar.

---

## BAGIAN 1: Menyiapkan Akun & Database MySQL di GoogieHost (DirectAdmin)

### Langkah 1.1: Gunakan Domain Utama Anda (Tidak Perlu Subdomain!)
> [!NOTE]
> **Tidak perlu membuat subdomain khusus seperti `api.domain.com`!**
> Pada paket gratis GoogieHost, fitur membuat subdomain tambahan memang seringkali dinonaktifkan/dibatasi. Hal ini **sama sekali tidak menjadi masalah**, karena:
> 1. **Domain utama Anda** (misal: `https://namadomainanda.com` atau `.cu.ma` dll) langsung dijadikan sebagai host Backend Laravel API.
> 2. Di Laravel, seluruh endpoint API secara otomatis sudah memiliki awalan `/api` (misal: `https://namadomainanda.com/api/statistics`, `/api/auth/login`).
> 3. Frontend Svelte tetap berjalan di **Vercel** (`https://absensi-sd.vercel.app`) dan akan memanggil API ke domain utama GoogieHost Anda.

1. Buka Client Area GoogieHost Anda, lalu klik tautan/tombol **Login to DirectAdmin** (atau buka URL login DirectAdmin dengan username dan password yang diberikan GoogieHost).
2. Perhatikan nama **Domain Utama** Anda yang sudah aktif (misal: `kemutugkidul.page.gd` atau `namadomainanda.com`). Domain inilah yang kita pakai.

---

### Langkah 1.2: Cek Versi PHP (Ekstensi Sudah Otomatis Aktif)
> [!NOTE]
> **Tidak ada tab/menu "Extensions"? Itu NORMAL!**  
> Di DirectAdmin (GoogieHost), seluruh ekstensi penting PHP (`pdo_mysql`, `mbstring`, `openssl`, `tokenizer`, `xml`, `fileinfo`, `curl`, dll) **sudah terinstal dan aktif secara default dari sistem server**. Anda tidak perlu mencentang atau mengaktifkannya secara manual.

Yang perlu Anda periksa hanya versi PHP-nya:
1. Jika di dashboard DirectAdmin ada menu **PHP Version Selector** / **Select PHP Version** (atau di menu Domain Setup):
   * Pastikan versi PHP yang dipilih adalah **PHP 8.1** atau **PHP 8.2**.
2. Jika tidak ada menu ubah versi PHP sama sekali:
   * **Bisa langsung dilewati (skip)!** Server GoogieHost sudah secara otomatis menjalankan PHP versi terbaru (8.x) yang kompatibel dengan Laravel.

---

### Langkah 1.3: Membuat Database MySQL di DirectAdmin
1. Di dashboard DirectAdmin, masuk ke menu **Account Manager** > klik **MySQL Management**.
2. Klik tombol **Create New Database** (atau **+ Create Database**).
3. Isi kolom yang diminta:
   * **Database Name**: Masukkan nama database, misalnya `absensi`.
     *(Perhatikan: DirectAdmin akan otomatis menambahkan prefix username Anda, misal: `ghuser_absensi`)*
   * **Database User**: Centang opsi **Same as database name** (atau buat user baru, misal: `ghuser_absensi`).
   * **Database Password**: Buat password yang kuat dan catat dengan aman.
4. Klik tombol **Create Database**.
5. **Catat 4 informasi penting ini untuk konfigurasi `.env` Laravel nanti**:
   * **DB_HOST**: `127.0.0.1` (atau `localhost`)
   * **DB_PORT**: `3306`
   * **DB_DATABASE**: Nama lengkap database Anda (contoh: `ghuser_absensi`)
   * **DB_USERNAME**: Nama lengkap user database (contoh: `ghuser_absensi`)
   * **DB_PASSWORD**: Password yang baru Anda buat

---

### Langkah 1.4: Import File SQL ke phpMyAdmin
1. Masih di halaman **MySQL Management** DirectAdmin, klik tautan / ikon **phpMyAdmin** (atau cari menu **phpMyAdmin** di dashboard DirectAdmin).
2. Jika diminta login, masukkan **Username Database** dan **Password Database** yang Anda buat di Langkah 1.3 tadi.
3. Setelah masuk ke phpMyAdmin:
   * Perhatikan panel sebelah kiri, klik nama database Anda (misal: `ghuser_absensi`).
4. Klik tab menu **Import** di baris navigasi bagian atas.
5. Pada bagian **File to import** / **Berkas untuk diimpor**, klik tombol **Choose File** (Pilih Berkas).
6. Pilih file database terbaru dari komputer Anda:
   `absensi_sd1.sql` (atau `absensi_sd.sql`).
7. Gulir ke bagian paling bawah, lalu klik tombol **Import** (atau **Go** / **Kirim**).
8. Tunggu beberapa saat sampai muncul notifikasi hijau:
   `Import has been successfully finished, ... queries executed.`
9. Database Anda sekarang sudah terisi seluruh tabel siswa, kelas, guru, absensi, dan data user!

---

## BAGIAN 2: Deploy Laravel Backend ke GoogieHost (DirectAdmin)

### Langkah 2.1: Siapkan Dependensi Vendor di Komputer Lokal
Sebelum mengupload, pastikan pustaka vendor Laravel sudah terinstal dan dioptimalkan untuk mode produksi:
1. Buka terminal (PowerShell) di komputer Anda, lalu masuk ke folder backend:
   ```powershell
   cd "c:\Users\Adit Setiawan\Code Project\absensi\api\absensi-api"
   ```
2. Jalankan perintah composer berikut:
   ```powershell
   composer install --optimize-autoloader --no-dev
   ```

---

### Langkah 2.2: Buat File `.env` untuk Hosting GoogieHost
Edit atau buat file `.env` di dalam folder `api/absensi-api/` yang disesuaikan dengan kredensial GoogieHost Anda:

```env
APP_NAME="Absensi SD"
APP_ENV=production
APP_KEY=base64:nXWDfhn5+N/2k8dKUol5c+MeM9+971qS7mQLMH5uEtY=
APP_DEBUG=false
APP_URL=https://api-absensi.cu.ma

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=ghuser_absensi
DB_USERNAME=ghuser_absensi
DB_PASSWORD=password_database_anda

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=public
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
```
> [!IMPORTANT]
> Ganti `APP_URL` dengan domain GoogieHost Anda, serta `DB_DATABASE`, `DB_USERNAME`, dan `DB_PASSWORD` dengan data database yang Anda buat di Langkah 1.3.

---

### Langkah 2.3: Pahami Struktur Folder di DirectAdmin
Di DirectAdmin, setiap domain memiliki struktur folder bawaan seperti ini:
```
/home/USERNAME/domains/DOMAIN_ANDA/
├── public_html/          <-- Ini adalah document root yang diakses oleh publik browser
```

Agar aplikasi Laravel aman dan file sensitif (seperti `.env`, `app`, `storage`) tidak bisa diakses langsung dari browser, kita pisahkan strukturnya menjadi:
```
/home/USERNAME/domains/DOMAIN_ANDA/
│
├── laravel_core/         <-- Folder baru untuk menyimpan seluruh file inti Laravel (KECUALI folder public)
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── routes/
│   ├── storage/
│   ├── vendor/
│   ├── .env
│   ├── artisan
│   └── composer.json
│
└── public_html/          <-- Folder bawaan DirectAdmin. Diisi ISI dari folder public/ Laravel!
    ├── .htaccess
    ├── favicon.ico
    ├── index.php         <-- Diedit agar memanggil folder ../laravel_core/
    └── robots.txt
```

---

### Langkah 2.4: Sesuaikan File `public/index.php`
Sebelum diunggah, buka file `api/absensi-api/public/index.php` di editor teks Anda:

Cari baris berikut:
```php
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

require __DIR__.'/../vendor/autoload.php';

$app = require_once __DIR__.'/../bootstrap/app.php';
```

Ubah menjadi (tambahkan `laravel_core/` pada path):
```php
if (file_exists($maintenance = __DIR__.'/../laravel_core/storage/framework/maintenance.php')) {
    require $maintenance;
}

require __DIR__.'/../laravel_core/vendor/autoload.php';

$app = require_once __DIR__.'/../laravel_core/bootstrap/app.php';
```
*Simpan file tersebut.*

---

### Langkah 2.5: Buat File ZIP untuk Upload Cepat
Agar proses upload ke DirectAdmin sangat cepat dan tidak perlu upload ribuan file satu per satu:

1. Buka File Explorer di komputer Anda, masuk ke:
   `c:\Users\Adit Setiawan\Code Project\absensi\api\absensi-api\`
2. Pilih semua file dan folder **KECUALI folder `public`** (yaitu pilih folder `app`, `bootstrap`, `config`, `database`, `routes`, `storage`, `vendor`, serta file `.env`, `artisan`, `composer.json`, dll).
3. Klik kanan > **Compress to ZIP file** (Kirim ke > Folder Terkompresi ZIP).
4. Beri nama file zip tersebut: **`laravel_core.zip`**.
5. Untuk isi folder `public/`, Anda bisa zip secara terpisah dengan nama **`public_files.zip`** (berisi `index.php`, `.htaccess`, `favicon.ico`, `robots.txt`).

---

### Langkah 2.6: Upload & Ekstrak Melalui File Manager DirectAdmin
1. Di panel DirectAdmin, buka menu **System Info & Files** > klik **File Manager**.
2. Masuk ke direktori domain Anda:
   Klik folder **`domains`** > klik nama domain Anda (misal: `api-absensi.cu.ma`).
3. Di dalam direktori domain Anda, sekarang Anda melihat folder **`public_html`**.
4. **Upload Core Laravel:**
   * Klik tombol **Upload File** (ikon panah ke atas) di bagian atas File Manager.
   * Pilih file **`laravel_core.zip`** dari komputer Anda dan klik Upload.
   * Setelah selesai, klik kanan pada file `laravel_core.zip` di File Manager > pilih **Extract**.
   * Ekstrak ke folder bernama **`laravel_core`** (atau ekstrak lalu pindahkan semua isinya ke folder baru `laravel_core`).
   * Hapus file zip `laravel_core.zip` setelah diekstrak untuk menghemat ruang penyimpanan.
5. **Upload Public Files:**
   * Buka folder **`public_html`**.
   * Hapus file bawaan (jika ada file seperti `index.html` default DirectAdmin).
   * Upload file yang ada di folder `public` Laravel Anda (`index.php` yang sudah diedit tadi, `.htaccess`, `favicon.ico`, dan `robots.txt`).
6. **Pastikan Permission Folder Storage:**
   * Di dalam folder `laravel_core`, klik kanan folder `storage` > pilih **Set Permissions** > pastikan bernilai **775** (atau centang Read, Write, Execute).
   * Lakukan hal yang sama untuk folder `laravel_core/bootstrap/cache` (**775**).

---

### Langkah 2.7: Membuat Symlink Storage (Untuk File Surat Izin / Bukti Upload)
Karena GoogieHost Free Hosting tidak memiliki akses terminal SSH untuk menjalankan `php artisan storage:link`:

1. Buka file `laravel_core/routes/web.php` langsung lewat editor bawaan File Manager DirectAdmin.
2. Tambahkan route bantuan berikut di baris paling bawah:
   ```php
   Route::get('/buat-symlink-storage', function () {
       $target = storage_path('app/public');
       $link = base_path('../public_html/storage');

       if (!file_exists($target)) {
           mkdir($target, 0775, true);
       }

       if (file_exists($link) || is_link($link)) {
           return 'Storage link sudah ada di public_html/storage!';
       }

       if (symlink($target, $link)) {
           return 'Storage link berhasil dibuat!';
       }

       return 'Gagal membuat symlink.';
   });
   ```
3. Buka browser dan buka tautan berikut:
   `https://domain-utama-anda.com/buat-symlink-storage`
4. Jika muncul tulisan *"Storage link berhasil dibuat!"*, artinya folder upload sudah terhubung ke `public_html`.
5. Anda sekarang bisa menghapus route bantuan tersebut dari `web.php`.

---

## BAGIAN 3: Pengaturan CORS & Uji Coba Endpoint API

### Langkah 3.1: Pastikan Konfigurasi CORS Laravel
File `config/cors.php` di Laravel Anda sudah diset untuk mengizinkan request dari frontend:
```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_methods' => ['*'],
'allowed_origins' => ['*'], // Mengizinkan request dari domain Vercel Anda
'allowed_headers' => ['*'],
```

### Langkah 3.2: Pastikan Header Authorization di `.htaccess`
Di folder `public_html/.htaccess`, pastikan baris ini ada agar token JWT / Sanctum tidak terpotong oleh web server Apache:
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
</IfModule>
```

### Langkah 3.3: Uji Coba Endpoint API Backend
Buka browser Anda dan akses endpoint API berikut:
`https://api-absensi.cu.ma/api/statistics`

Jika backend mengembalikan respon format JSON (misalnya data statistik atau `{ "success": true, ... }`), selamat! **Backend Laravel dan Database MySQL Anda di GoogieHost sudah aktif 100%!**

---

## BAGIAN 4: Deploy Frontend Svelte ke Vercel

Vercel adalah platform hosting cloud terbaik, sangat cepat, dan gratis untuk aplikasi Single Page Application (SPA) berbasis Svelte dan Vite.

### Langkah 4.1: Pastikan Konfigurasi `vercel.json` Sudah Ada
File `fe-svelte/vercel.json` sudah tersedia di project Anda agar saat berpindah halaman dan me-refresh browser tidak terjadi error 404:
```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/"
    }
  ]
}
```

---

### Langkah 4.2: Simpan & Push Kode Terbaru ke GitHub
Pastikan seluruh perubahan terbaru pada kode Anda sudah di-push ke GitHub:
```powershell
git add .
git commit -m "Update konfigurasi deploy GoogieHost dan Vercel"
git push origin main
```

---

### Langkah 4.3: Import Repositori di Vercel
1. Buka [Vercel](https://vercel.com/) dan login menggunakan akun GitHub Anda.
2. Di halaman Dashboard Vercel, klik tombol **Add New...** > pilih **Project**.
3. Di daftar repositori GitHub Anda, cari repositori project absensi ini, lalu klik tombol **Import**.

---

### Langkah 4.4: Konfigurasi Deployment di Vercel
Pada form konfigurasi sebelum menekan deploy:

1. **Project Name**: Beri nama project Anda (misal: `absensi-sd`).
2. **Framework Preset**: Pilih **Vite**.
3. **Root Directory (PENTING!)**:
   * Klik tombol **Edit** di samping *Root Directory*.
   * Pilih folder **`fe-svelte`** (karena source code frontend Svelte Anda berada di dalam folder ini).
   * Klik **Continue**.
4. **Build and Output Settings**:
   * Biarkan default bawaan Vite:
     * *Build Command:* `npm run build`
     * *Output Directory:* `dist`
5. **Environment Variables (KUNCI PENGHUBUNG FRONTEND & BACKEND):**
   * Klik dropdown **Environment Variables**.
   * Tambahkan key berikut:
     * **Key**: `VITE_API_BASE_URL`
     * **Value**: `https://api-absensi.cu.ma/api` *(Ganti dengan alamat domain GoogieHost Anda ditambah `/api`)*
   * Klik tombol **Add**.

---

### Langkah 4.5: Klik Deploy!
1. Klik tombol **Deploy** di bagian bawah.
2. Tunggu proses build selesai (sekitar 30-60 detik).
3. Setelah selesai, akan muncul animasi konfeti perayaan.
4. Klik URL domain yang diberikan oleh Vercel, misalnya:
   `https://absensi-sd.vercel.app`
5. Aplikasi Absensi SD Anda sekarang sudah aktif, terhubung ke backend GoogieHost, dan siap digunakan!

---

## BAGIAN 5: Uji Coba Lengkap & Troubleshooting Masalah Umum

### Checklist Uji Coba Fitur Aplikasi:
1. **Login Akun**: Coba login dengan akun Guru, Kepala Sekolah, dan Orang Tua yang ada di database.
2. **Dashboard**: Periksa apakah grafik, total siswa, dan kalender absensi muncul dengan data nyata.
3. **Input Absensi Harian**: Coba lakukan input absensi siswa dan pastikan tersimpan ke database.
4. **Export Dokumen**: Coba download rekap bulanan ke Excel dan cetak PDF.

---

### Troubleshooting Masalah Umum:

#### 1. Masalah: Error 500 (Internal Server Error) saat membuka Backend
* **Penyebab:** Path di file `public_html/index.php` belum tepat, versi PHP di bawah 8.1, atau permission folder storage.
* **Solusi:**
  1. Periksa kembali isi `public_html/index.php`. Pastikan mengarah ke `../laravel_core/vendor/autoload.php` dan `../laravel_core/bootstrap/app.php`.
  2. Masuk ke DirectAdmin > **Select PHP Version** > pastikan menggunakan **PHP 8.1** atau **8.2**.
  3. Buka File Manager di DirectAdmin, buka file `laravel_core/storage/logs/laravel.log` untuk melihat pesan error spesifiknya.

#### 2. Masalah: Database Connection Refused / Access Denied
* **Penyebab:** Kesalahan nama database, username, atau `DB_HOST`.
* **Solusi:**
  1. Pastikan di file `.env`, `DB_HOST=127.0.0.1` atau `localhost`.
  2. Pastikan `DB_DATABASE` dan `DB_USERNAME` menyertakan prefix akun DirectAdmin Anda secara lengkap (misal: `ghuser_absensi`).
  3. Pastikan password sama persis dengan yang dibuat di MySQL Management.

#### 3. Masalah: CORS Error di Browser (Failed to fetch / NetworkError)
* **Penyebab:** Backend belum menyertakan header CORS untuk domain Vercel.
* **Solusi:**
  1. Buka file `laravel_core/config/cors.php`, pastikan `'allowed_origins' => ['*']`.
  2. Buka file `public_html/.htaccess` dan pastikan konfigurasi rewrite modul Apache aktif.

#### 4. Masalah: File Surat Keterangan / Gambar Tidak Bisa Dibuka (404)
* **Penyebab:** Symlink storage belum terpasang.
* **Solusi:**
  Jalankan kembali Langkah 2.7 (akses `https://domain-anda/buat-symlink-storage` di browser) untuk mengaktifkan symlink storage publik.

---

*Selamat! Aplikasi Absensi SD Anda kini telah sukses dideploy ke GoogieHost (DirectAdmin) dan Vercel! 🎉*
