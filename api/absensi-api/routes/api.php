<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\GuruController;
use App\Http\Controllers\KepalaSekolahController;
use App\Http\Controllers\OrangTuaController;
use App\Http\Controllers\SiswaController;
use App\Http\Controllers\KelasController;
use App\Http\Controllers\AbsensiController;
use App\Http\Controllers\LaporanController;
use App\Http\Controllers\DashboardController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Authentication Routes (Public)
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/auth/reset-password', [AuthController::class, 'resetPassword']);
Route::post('/auth/change-password', [AuthController::class, 'changePassword']);

// Protected Routes (Need Authentication)
Route::middleware('auth:sanctum')->group(function () {
    // Auth Routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile/update', [AuthController::class, 'updateProfile']);
});

// Guru Routes
Route::get('/guru', [GuruController::class, 'index']);
Route::get('/guru/my-class', [AuthController::class, 'getGuruClass']);
Route::post('/guru/release-class', [AuthController::class, 'releaseClass']);
Route::post('/guru/change-class', [AuthController::class, 'changeClass']);
Route::get('/guru/{nip}', [GuruController::class, 'show']);
Route::post('/guru', [GuruController::class, 'store']);
Route::put('/guru/{nip}', [GuruController::class, 'update']);
Route::delete('/guru/{nip}', [GuruController::class, 'destroy']);

// Kepala Sekolah Routes
Route::get('/kepala-sekolah', [KepalaSekolahController::class, 'index']);
Route::get('/kepala-sekolah/pending', [KepalaSekolahController::class, 'pending'])->middleware('auth:sanctum');
Route::post('/kepala-sekolah/approve', [KepalaSekolahController::class, 'approve'])->middleware('auth:sanctum');
Route::get('/kepala-sekolah/{nip}', [KepalaSekolahController::class, 'show']);
Route::post('/kepala-sekolah', [KepalaSekolahController::class, 'store']);
Route::put('/kepala-sekolah/{nip}', [KepalaSekolahController::class, 'update']);
Route::delete('/kepala-sekolah/{nip}', [KepalaSekolahController::class, 'destroy']);

// Orang Tua Routes
Route::get('/orang-tua', [OrangTuaController::class, 'index']);
Route::get('/orang-tua/{id}', [OrangTuaController::class, 'show']);
Route::post('/orang-tua', [OrangTuaController::class, 'store']);
Route::put('/orang-tua/{id}', [OrangTuaController::class, 'update']);
Route::delete('/orang-tua/{id}', [OrangTuaController::class, 'destroy']);

// Siswa Routes
Route::get('/siswa', [SiswaController::class, 'index']);
Route::get('/siswa/search', [SiswaController::class, 'search']);
Route::post('/siswa/import', [SiswaController::class, 'importExcel']);
Route::get('/siswa/{nis}', [SiswaController::class, 'show']);
Route::post('/siswa', [SiswaController::class, 'store']);
Route::put('/siswa/{nis}', [SiswaController::class, 'update']);
Route::delete('/siswa/{nis}', [SiswaController::class, 'destroy']);
Route::get('/siswa/by-kelas/{id_kelas}', [SiswaController::class, 'getByKelas']);

// Kelas Routes
Route::get('/kelas', [KelasController::class, 'index']);
Route::get('/kelas/{id}', [KelasController::class, 'show']);
Route::post('/kelas', [KelasController::class, 'store']);
Route::put('/kelas/{id}', [KelasController::class, 'update']);
Route::delete('/kelas/{id}', [KelasController::class, 'destroy']);
Route::get('/kelas/by-guru/{nip}', [KelasController::class, 'getByGuru']);

// Absensi Routes
Route::get('/absensi', [AbsensiController::class, 'index']);
Route::get('/absensi/consecutive-absent', [AbsensiController::class, 'consecutiveAbsent']);
Route::get('/absensi/today', [AbsensiController::class, 'getToday']);
Route::get('/absensi/by-date', [AbsensiController::class, 'getByDate']);
Route::get('/absensi/by-siswa/{nis}', [AbsensiController::class, 'getBySiswa']);
Route::get('/absensi/by-kelas/{id_kelas}', [AbsensiController::class, 'getByKelas']);
Route::get('/absensi/weekly-stats', [AbsensiController::class, 'weeklyStats']);
Route::get('/absensi/statistics', [AbsensiController::class, 'getStatistics']);
Route::get('/absensi/{id}', [AbsensiController::class, 'show']);
Route::post('/absensi', [AbsensiController::class, 'store']);
Route::post('/absensi/bulk', [AbsensiController::class, 'storeBulk']);
Route::put('/absensi/{id}', [AbsensiController::class, 'update']);
Route::delete('/absensi/{id}', [AbsensiController::class, 'destroy']);

// Laporan Routes
Route::get('/laporan', [LaporanController::class, 'index']);
Route::get('/laporan/generate', [LaporanController::class, 'generate']);
Route::get('/laporan/download/pdf', [LaporanController::class, 'downloadPdf']);
Route::get('/laporan/download/excel', [LaporanController::class, 'downloadExcel']);
Route::get('/laporan/by-kelas/{id}', [LaporanController::class, 'getByKelas']);
Route::get('/laporan/by-orangtua/{id}', [LaporanController::class, 'getByOrangTua']);
Route::get('/laporan/{id}', [LaporanController::class, 'show']);
Route::post('/laporan', [LaporanController::class, 'store']);
Route::post('/laporan/create-from-absensi', [LaporanController::class, 'createFromAbsensi']);
Route::put('/laporan/{id}', [LaporanController::class, 'update']);
Route::delete('/laporan/{id}', [LaporanController::class, 'destroy']);
Route::post('/laporan/{id}/submit', [LaporanController::class, 'submit']);
Route::post('/laporan/{id}/unsubmit', [LaporanController::class, 'unsubmit']);
Route::post('/laporan/{id}/refresh', [LaporanController::class, 'refresh']);

// Rekap Bulanan Routes
Route::get('/rekap-bulanan', [LaporanController::class, 'getRekapBulanan']);
Route::post('/rekap-bulanan', [LaporanController::class, 'createRekapBulanan']);
Route::put('/rekap-bulanan/{id}', [LaporanController::class, 'updateRekapBulanan']);
Route::delete('/rekap-bulanan/{id}', [LaporanController::class, 'deleteRekapBulanan']);
Route::post('/rekap-bulanan/{id}/refresh', [LaporanController::class, 'refreshRekapBulanan']);
Route::post('/rekap-bulanan/{id}/submit', [LaporanController::class, 'submitRekapBulanan']);
Route::post('/rekap-bulanan/{id}/unsubmit', [LaporanController::class, 'unsubmitRekapBulanan']);

// Dashboard Routes
Route::get('/dashboard/guru/{nip}', [DashboardController::class, 'guruDashboard']);
Route::get('/dashboard/kepala-sekolah', [DashboardController::class, 'kepalaSekolahDashboard']);
Route::get('/dashboard/orang-tua/{id_ortu}', [DashboardController::class, 'orangTuaDashboard']);
Route::get('/dashboard/statistics', [DashboardController::class, 'getStatistics']);
Route::get('/dashboard/class-comparison', [DashboardController::class, 'classComparison']);
Route::get('/dashboard/semester-comparison', [DashboardController::class, 'semesterComparison']);
