<?php

namespace App\Http\Controllers;

use App\Models\Laporan;
use App\Models\Absensi;
use App\Models\Kelas;
use App\Models\Siswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LaporanController extends Controller
{
    public function index(Request $request)
    {
        $query = Laporan::with(['kelas', 'guru'])
            ->where(function($q) {
                $q->whereNull('tipe')
                  ->orWhere('tipe', 'semester');
            });
        
        if ($request->has('nip')) {
            $query->where('nip', $request->nip);
        }
        
        if ($request->has('id_kelas')) {
            $query->where('id_kelas', $request->id_kelas);
        }
        
        $laporan = $query->orderBy('periode_akhir', 'desc')->get();
        
        return response()->json([
            'success' => true,
            'message' => 'Data laporan berhasil diambil',
            'data' => $laporan
        ], 200);
    }

    public function show($id)
    {
        $laporan = Laporan::with(['kelas', 'guru'])->find($id);
        
        if (!$laporan) {
            return response()->json([
                'success' => false,
                'message' => 'Data laporan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data laporan berhasil diambil',
            'data' => $laporan
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_kelas' => 'required|integer|exists:kelas,id_kelas',
            'nip' => 'required|string|max:255|exists:guru,nip',
            'total_hadir' => 'required|integer|min:0',
            'total_sakit' => 'required|integer|min:0',
            'total_izin' => 'required|integer|min:0',
            'total_alfa' => 'required|integer|min:0',
            'periode_awal' => 'required|date',
            'periode_akhir' => 'required|date|after_or_equal:periode_awal'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $laporan = Laporan::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Data laporan berhasil ditambahkan',
            'data' => $laporan
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $laporan = Laporan::find($id);
        
        if (!$laporan) {
            return response()->json([
                'success' => false,
                'message' => 'Data laporan tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'id_kelas' => 'integer|exists:kelas,id_kelas',
            'nip' => 'string|max:255|exists:guru,nip',
            'total_hadir' => 'integer|min:0',
            'total_sakit' => 'integer|min:0',
            'total_izin' => 'integer|min:0',
            'total_alfa' => 'integer|min:0',
            'periode_awal' => 'date',
            'periode_akhir' => 'date|after_or_equal:periode_awal'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $laporan->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Data laporan berhasil diperbarui',
            'data' => $laporan
        ], 200);
    }

    public function destroy($id)
    {
        $laporan = Laporan::find($id);
        
        if (!$laporan) {
            return response()->json([
                'success' => false,
                'message' => 'Data laporan tidak ditemukan'
            ], 404);
        }

        $laporan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data laporan berhasil dihapus'
        ], 200);
    }

    /**
     * Submit laporan
     */
    public function submit($id)
    {
        $laporan = Laporan::find($id);
        
        if (!$laporan) {
            return response()->json([
                'success' => false,
                'message' => 'Data laporan tidak ditemukan'
            ], 404);
        }

        if ($laporan->is_submitted) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan sudah disubmit sebelumnya'
            ], 400);
        }

        $laporan->update([
            'is_submitted' => true,
            'submitted_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil disubmit',
            'data' => $laporan->fresh(['kelas', 'guru'])
        ], 200);
    }

    /**
     * Batal submit laporan
     */
    public function unsubmit($id)
    {
        $laporan = Laporan::find($id);
        
        if (!$laporan) {
            return response()->json([
                'success' => false,
                'message' => 'Data laporan tidak ditemukan'
            ], 404);
        }

        if (!$laporan->is_submitted) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan belum disubmit'
            ], 400);
        }

        $laporan->update([
            'is_submitted' => false,
            'submitted_at' => null
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Submit laporan berhasil dibatalkan',
            'data' => $laporan->fresh(['kelas', 'guru'])
        ], 200);
    }

    /**
     * Refresh data laporan dari absensi terbaru
     */
    public function refresh($id)
    {
        $laporan = Laporan::with(['kelas'])->find($id);
        
        if (!$laporan) {
            return response()->json([
                'success' => false,
                'message' => 'Data laporan tidak ditemukan'
            ], 404);
        }

        if ($laporan->is_submitted) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan yang sudah disubmit tidak dapat di-refresh'
            ], 400);
        }

        // Ambil data siswa di kelas
        $siswaIds = Siswa::where('id_kelas', $laporan->id_kelas)->pluck('nis')->toArray();

        // Hitung ulang statistik absensi dalam periode laporan
        $absensi = Absensi::whereIn('nis', $siswaIds)
            ->whereBetween('tanggal', [$laporan->periode_awal, $laporan->periode_akhir])
            ->get();

        $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
        $sakit = $absensi->where('status_kehadiran', 'sakit')->count();
        $izin = $absensi->where('status_kehadiran', 'izin')->count();
        $alfa = $absensi->where('status_kehadiran', 'alfa')->count();

        $laporan->update([
            'total_hadir' => $hadir,
            'total_sakit' => $sakit,
            'total_izin' => $izin,
            'total_alfa' => $alfa,
        ]);

        $totalData = $hadir + $sakit + $izin + $alfa;

        return response()->json([
            'success' => true,
            'message' => "Data laporan berhasil di-refresh ($totalData data absensi)",
            'data' => $laporan->fresh(['kelas', 'guru'])
        ], 200);
    }

    /**
     * Generate laporan berdasarkan filter
     */
    public function generate(Request $request)
    {
        $tahunAjar = $request->query('tahun_ajar', date('Y'));
        $semester = $request->query('semester', 1);
        $kelas = $request->query('kelas', 'all');

        // Tentukan periode berdasarkan semester
        if ($semester == 1) {
            $startDate = $tahunAjar . '-07-01';
            $endDate = $tahunAjar . '-12-31';
        } else {
            $startDate = ($tahunAjar + 1) . '-01-01';
            $endDate = ($tahunAjar + 1) . '-06-30';
        }

        // Query kelas
        $kelasQuery = Kelas::with(['guru', 'siswa']);
        if ($kelas !== 'all') {
            $kelasQuery->where('kelas', $kelas);
        }
        $kelasList = $kelasQuery->get();

        $laporanData = [];
        $totalHadir = 0;
        $totalSakit = 0;
        $totalIzin = 0;
        $totalAlfa = 0;
        $totalAbsensi = 0;

        foreach ($kelasList as $kelasItem) {
            $siswaIds = $kelasItem->siswa->pluck('nis')->toArray();
            
            $absensi = Absensi::whereIn('nis', $siswaIds)
                ->whereBetween('tanggal', [$startDate, $endDate])
                ->get();
            
            $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
            $sakit = $absensi->where('status_kehadiran', 'sakit')->count();
            $izin = $absensi->where('status_kehadiran', 'izin')->count();
            $alfa = $absensi->where('status_kehadiran', 'alfa')->count();
            
            $kelasTotal = $absensi->count();
            
            $totalHadir += $hadir;
            $totalSakit += $sakit;
            $totalIzin += $izin;
            $totalAlfa += $alfa;
            $totalAbsensi += $kelasTotal;

            $laporanData[] = [
                'kelas' => $kelasItem->kelas,
                'guru' => $kelasItem->guru ? $kelasItem->guru->nama : null,
                'jumlah_siswa' => $kelasItem->siswa->count(),
                'hadir' => $hadir,
                'sakit' => $sakit,
                'izin' => $izin,
                'alfa' => $alfa,
                'total' => $kelasTotal,
                'persentase_hadir' => $kelasTotal > 0 ? round(($hadir / $kelasTotal) * 100, 2) : 0
            ];
        }

        // Hitung hari efektif
        $hariEfektif = Absensi::whereBetween('tanggal', [$startDate, $endDate])
            ->distinct('tanggal')
            ->count('tanggal');

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil di-generate',
            'data' => [
                'nama_sekolah' => 'SD Negeri Kemutung Kidul',
                'tahun_ajar' => $tahunAjar . '/' . ($tahunAjar + 1),
                'semester' => $semester,
                'periode' => [
                    'start' => $startDate,
                    'end' => $endDate
                ],
                'ringkasan' => [
                    'total_hadir' => $totalHadir,
                    'total_sakit' => $totalSakit,
                    'total_izin' => $totalIzin,
                    'total_alfa' => $totalAlfa,
                    'total_absensi' => $totalAbsensi,
                    'persentase_hadir' => $totalAbsensi > 0 ? round(($totalHadir / $totalAbsensi) * 100, 2) : 0,
                    'hari_efektif' => $hariEfektif
                ],
                'detail_kelas' => $laporanData
            ]
        ], 200);
    }

    /**
     * Create laporan dari data absensi (untuk Guru)
     */
    public function createFromAbsensi(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'tahun_ajar' => 'required|string',
            'semester' => 'required|integer|in:1,2',
            'kelas' => 'required|string',
            'nip' => 'required|string|exists:guru,nip',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $tahunAjar = $request->tahun_ajar;
        $semester = $request->semester;
        $kelasNama = $request->kelas;
        $nip = $request->nip;

        // Parse tahun ajar (format: 2025/2026)
        $tahunAjarParts = explode('/', $tahunAjar);
        $tahunAwal = (int) $tahunAjarParts[0];
        $tahunAkhir = isset($tahunAjarParts[1]) ? (int) $tahunAjarParts[1] : $tahunAwal + 1;

        // Tentukan periode berdasarkan semester
        // Semester Ganjil: Juli - Desember tahun awal
        // Semester Genap: Januari - Juni tahun akhir
        if ($semester == 1) {
            $startDate = $tahunAwal . '-07-01';
            $endDate = $tahunAwal . '-12-31';
        } else {
            $startDate = $tahunAkhir . '-01-01';
            $endDate = $tahunAkhir . '-06-30';
        }

        // Cari kelas
        $kelas = Kelas::where('kelas', $kelasNama)->first();
        if (!$kelas) {
            return response()->json([
                'success' => false,
                'message' => 'Kelas tidak ditemukan'
            ], 404);
        }

        // Cek apakah sudah ada laporan untuk periode ini
        $existingLaporan = Laporan::where('id_kelas', $kelas->id_kelas)
            ->where('periode_awal', $startDate)
            ->where('periode_akhir', $endDate)
            ->first();

        if ($existingLaporan) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan untuk periode ini sudah ada. Silakan edit atau hapus laporan yang sudah ada.'
            ], 400);
        }

        // Ambil data siswa di kelas
        $siswaList = Siswa::where('id_kelas', $kelas->id_kelas)->get();
        $siswaIds = $siswaList->pluck('nis')->toArray();

        if (empty($siswaIds)) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada siswa di kelas ini'
            ], 400);
        }

        // Hitung statistik absensi dalam periode
        $absensi = Absensi::whereIn('nis', $siswaIds)
            ->whereBetween('tanggal', [$startDate, $endDate])
            ->get();

        $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
        $sakit = $absensi->where('status_kehadiran', 'sakit')->count();
        $izin = $absensi->where('status_kehadiran', 'izin')->count();
        $alfa = $absensi->where('status_kehadiran', 'alfa')->count();

        // Buat laporan (jika tidak ada data, tetap buat dengan nilai 0)
        $laporan = Laporan::create([
            'id_kelas' => $kelas->id_kelas,
            'nip' => $nip,
            'total_hadir' => $hadir,
            'total_sakit' => $sakit,
            'total_izin' => $izin,
            'total_alfa' => $alfa,
            'periode_awal' => $startDate,
            'periode_akhir' => $endDate,
            'is_submitted' => false,
            'submitted_at' => null,
            'tipe' => 'semester',
        ]);

        $totalData = $hadir + $sakit + $izin + $alfa;

        return response()->json([
            'success' => true,
            'message' => $totalData > 0 
                ? "Laporan berhasil dibuat dengan $totalData data absensi" 
                : "Laporan berhasil dibuat (belum ada data absensi)",
            'data' => $laporan->load(['kelas', 'guru'])
        ], 201);
    }

    /**
     * Download laporan sebagai PDF
     */
    public function downloadPdf(Request $request)
    {
        // Generate laporan data
        $tahunAjar = $request->query('tahun_ajar', date('Y'));
        $semester = $request->query('semester', 1);
        $kelas = $request->query('kelas', 'all');

        // Tentukan periode
        if ($semester == 1) {
            $startDate = $tahunAjar . '-07-01';
            $endDate = $tahunAjar . '-12-31';
        } else {
            $startDate = ($tahunAjar + 1) . '-01-01';
            $endDate = ($tahunAjar + 1) . '-06-30';
        }

        // Query kelas
        $kelasQuery = Kelas::with(['guru', 'siswa']);
        if ($kelas !== 'all') {
            $kelasQuery->where('kelas', $kelas);
        }
        $kelasList = $kelasQuery->get();

        $laporanData = [];
        $totalHadir = 0;
        $totalSakit = 0;
        $totalIzin = 0;
        $totalAlfa = 0;

        foreach ($kelasList as $kelasItem) {
            $siswaIds = $kelasItem->siswa->pluck('nis')->toArray();
            
            $absensi = Absensi::whereIn('nis', $siswaIds)
                ->whereBetween('tanggal', [$startDate, $endDate])
                ->get();
            
            $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
            $sakit = $absensi->where('status_kehadiran', 'sakit')->count();
            $izin = $absensi->where('status_kehadiran', 'izin')->count();
            $alfa = $absensi->where('status_kehadiran', 'alfa')->count();
            
            $totalHadir += $hadir;
            $totalSakit += $sakit;
            $totalIzin += $izin;
            $totalAlfa += $alfa;

            $laporanData[] = [
                'kelas' => $kelasItem->kelas,
                'guru' => $kelasItem->guru ? $kelasItem->guru->nama : null,
                'hadir' => $hadir,
                'sakit' => $sakit,
                'izin' => $izin,
                'alfa' => $alfa
            ];
        }

        // Return as JSON for now (in production, you would use a PDF library like DomPDF)
        return response()->json([
            'success' => true,
            'message' => 'Data untuk PDF berhasil disiapkan',
            'download_type' => 'pdf',
            'data' => [
                'nama_sekolah' => 'SD Negeri Kemutung Kidul',
                'tahun_ajar' => $tahunAjar . '/' . ($tahunAjar + 1),
                'semester' => $semester,
                'periode' => $startDate . ' s/d ' . $endDate,
                'total_hadir' => $totalHadir,
                'total_sakit' => $totalSakit,
                'total_izin' => $totalIzin,
                'total_alfa' => $totalAlfa,
                'detail' => $laporanData
            ]
        ], 200);
    }

    /**
     * Download laporan sebagai Excel
     */
    public function downloadExcel(Request $request)
    {
        // Generate laporan data (same as PDF)
        $tahunAjar = $request->query('tahun_ajar', date('Y'));
        $semester = $request->query('semester', 1);
        $kelas = $request->query('kelas', 'all');

        if ($semester == 1) {
            $startDate = $tahunAjar . '-07-01';
            $endDate = $tahunAjar . '-12-31';
        } else {
            $startDate = ($tahunAjar + 1) . '-01-01';
            $endDate = ($tahunAjar + 1) . '-06-30';
        }

        $kelasQuery = Kelas::with(['guru', 'siswa']);
        if ($kelas !== 'all') {
            $kelasQuery->where('kelas', $kelas);
        }
        $kelasList = $kelasQuery->get();

        $laporanData = [];

        foreach ($kelasList as $kelasItem) {
            $siswaIds = $kelasItem->siswa->pluck('nis')->toArray();
            
            $absensi = Absensi::whereIn('nis', $siswaIds)
                ->whereBetween('tanggal', [$startDate, $endDate])
                ->get();
            
            $laporanData[] = [
                'kelas' => $kelasItem->kelas,
                'guru' => $kelasItem->guru ? $kelasItem->guru->nama : null,
                'jumlah_siswa' => $kelasItem->siswa->count(),
                'hadir' => $absensi->where('status_kehadiran', 'hadir')->count(),
                'sakit' => $absensi->where('status_kehadiran', 'sakit')->count(),
                'izin' => $absensi->where('status_kehadiran', 'izin')->count(),
                'alfa' => $absensi->where('status_kehadiran', 'alfa')->count()
            ];
        }

        // Return as JSON for now (in production, use Laravel Excel package)
        return response()->json([
            'success' => true,
            'message' => 'Data untuk Excel berhasil disiapkan',
            'download_type' => 'excel',
            'data' => [
                'nama_sekolah' => 'SD Negeri Kemutung Kidul',
                'tahun_ajar' => $tahunAjar . '/' . ($tahunAjar + 1),
                'semester' => $semester,
                'periode' => $startDate . ' s/d ' . $endDate,
                'detail' => $laporanData
            ]
        ], 200);
    }

    /**
     * Get laporan by kelas
     */
    public function getByKelas($id)
    {
        $kelas = Kelas::with(['guru', 'siswa'])->find($id);
        
        if (!$kelas) {
            return response()->json([
                'success' => false,
                'message' => 'Kelas tidak ditemukan'
            ], 404);
        }

        $laporan = Laporan::with(['kelas', 'guru'])
            ->where('id_kelas', $id)
            ->where(function($q) {
                $q->whereNull('tipe')
                  ->orWhere('tipe', 'semester');
            })
            ->orderBy('periode_akhir', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data laporan kelas berhasil diambil',
            'data' => [
                'kelas' => $kelas,
                'laporan' => $laporan
            ]
        ], 200);
    }

    /**
     * Get laporan by orang tua (berdasarkan siswa yang dimiliki)
     */
    public function getByOrangTua($id)
    {
        // Cari semua siswa yang memiliki orang tua dengan id tersebut
        $siswaList = Siswa::where('id_ortu', $id)->get();
        
        if ($siswaList->isEmpty()) {
            return response()->json([
                'success' => true,
                'message' => 'Tidak ada siswa untuk orang tua ini',
                'data' => []
            ], 200);
        }

        $result = [];
        
        foreach ($siswaList as $siswa) {
            // Ambil kelas siswa
            $kelas = $siswa->kelas;
            
            if (!$kelas) {
                continue;
            }
            
            // Ambil laporan untuk kelas tersebut
            $laporan = Laporan::with(['kelas', 'guru'])
                ->where('id_kelas', $kelas->id_kelas)
                ->orderBy('periode_akhir', 'desc')
                ->get();
            
            // Hitung statistik absensi siswa
            $absensi = Absensi::where('nis', $siswa->nis)->get();
            
            $result[] = [
                'siswa' => $siswa,
                'kelas' => $kelas,
                'laporan' => $laporan,
                'statistik' => [
                    'total_hadir' => $absensi->where('status_kehadiran', 'hadir')->count(),
                    'total_sakit' => $absensi->where('status_kehadiran', 'sakit')->count(),
                    'total_izin' => $absensi->where('status_kehadiran', 'izin')->count(),
                    'total_alfa' => $absensi->where('status_kehadiran', 'alfa')->count(),
                ]
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Data laporan orang tua berhasil diambil',
            'data' => $result
        ], 200);
    }

    /**
     * Get rekap bulanan by kelas
     */
    public function getRekapBulanan(Request $request)
    {
        $query = Laporan::with(['kelas', 'guru'])
            ->where('tipe', 'bulanan');
        
        if ($request->has('id_kelas')) {
            $query->where('id_kelas', $request->id_kelas);
        }
        
        if ($request->has('nip')) {
            $query->where('nip', $request->nip);
        }
        
        if ($request->has('tahun')) {
            $query->where('tahun', $request->tahun);
        }
        
        $rekap = $query->orderBy('tahun', 'desc')
            ->orderBy('bulan', 'desc')
            ->get();
        
        return response()->json([
            'success' => true,
            'message' => 'Data rekap bulanan berhasil diambil',
            'data' => $rekap
        ], 200);
    }

    /**
     * Create rekap bulanan dari data absensi
     */
    public function createRekapBulanan(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_kelas' => 'required|integer|exists:kelas,id_kelas',
            'nip' => 'required|string|exists:guru,nip',
            'bulan' => 'required|integer|min:1|max:12',
            'tahun' => 'required|integer|min:2000|max:2100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $idKelas = $request->id_kelas;
        $nip = $request->nip;
        $bulan = $request->bulan;
        $tahun = $request->tahun;

        // Tentukan periode bulan
        $startDate = sprintf('%04d-%02d-01', $tahun, $bulan);
        $endDate = date('Y-m-t', strtotime($startDate)); // Last day of month

        // Cek apakah sudah ada rekap untuk bulan ini
        $existingRekap = Laporan::where('id_kelas', $idKelas)
            ->where('tipe', 'bulanan')
            ->where('bulan', $bulan)
            ->where('tahun', $tahun)
            ->first();

        if ($existingRekap) {
            return response()->json([
                'success' => false,
                'message' => 'Rekap untuk bulan ini sudah ada. Silakan edit atau hapus rekap yang sudah ada.'
            ], 400);
        }

        // Ambil data siswa di kelas
        $siswaList = Siswa::where('id_kelas', $idKelas)->get();
        $siswaIds = $siswaList->pluck('nis')->toArray();

        if (empty($siswaIds)) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada siswa di kelas ini'
            ], 400);
        }

        // Hitung statistik absensi dalam periode
        $absensi = Absensi::whereIn('nis', $siswaIds)
            ->whereBetween('tanggal', [$startDate, $endDate])
            ->get();

        $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
        $sakit = $absensi->where('status_kehadiran', 'sakit')->count();
        $izin = $absensi->where('status_kehadiran', 'izin')->count();
        $alfa = $absensi->where('status_kehadiran', 'alfa')->count();

        // Buat rekap
        $rekap = Laporan::create([
            'id_kelas' => $idKelas,
            'nip' => $nip,
            'total_hadir' => $hadir,
            'total_sakit' => $sakit,
            'total_izin' => $izin,
            'total_alfa' => $alfa,
            'periode_awal' => $startDate,
            'periode_akhir' => $endDate,
            'is_submitted' => false,
            'submitted_at' => null,
            'tipe' => 'bulanan',
            'bulan' => $bulan,
            'tahun' => $tahun,
        ]);

        $totalData = $hadir + $sakit + $izin + $alfa;

        return response()->json([
            'success' => true,
            'message' => $totalData > 0 
                ? "Rekap bulanan berhasil dibuat dengan $totalData data absensi" 
                : "Rekap bulanan berhasil dibuat (belum ada data absensi)",
            'data' => $rekap->load(['kelas', 'guru'])
        ], 201);
    }

    /**
     * Update rekap bulanan
     */
    public function updateRekapBulanan(Request $request, $id)
    {
        $rekap = Laporan::where('tipe', 'bulanan')->find($id);
        
        if (!$rekap) {
            return response()->json([
                'success' => false,
                'message' => 'Data rekap tidak ditemukan'
            ], 404);
        }

        if ($rekap->is_submitted) {
            return response()->json([
                'success' => false,
                'message' => 'Rekap yang sudah disubmit tidak dapat diedit'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'total_hadir' => 'integer|min:0',
            'total_sakit' => 'integer|min:0',
            'total_izin' => 'integer|min:0',
            'total_alfa' => 'integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $rekap->update($request->only(['total_hadir', 'total_sakit', 'total_izin', 'total_alfa']));

        return response()->json([
            'success' => true,
            'message' => 'Rekap bulanan berhasil diperbarui',
            'data' => $rekap->fresh(['kelas', 'guru'])
        ], 200);
    }

    /**
     * Delete rekap bulanan
     */
    public function deleteRekapBulanan($id)
    {
        $rekap = Laporan::where('tipe', 'bulanan')->find($id);
        
        if (!$rekap) {
            return response()->json([
                'success' => false,
                'message' => 'Data rekap tidak ditemukan'
            ], 404);
        }

        if ($rekap->is_submitted) {
            return response()->json([
                'success' => false,
                'message' => 'Rekap yang sudah disubmit tidak dapat dihapus'
            ], 400);
        }

        $rekap->delete();

        return response()->json([
            'success' => true,
            'message' => 'Rekap bulanan berhasil dihapus'
        ], 200);
    }

    /**
     * Refresh rekap bulanan dari absensi
     */
    public function refreshRekapBulanan($id)
    {
        $rekap = Laporan::with(['kelas'])->where('tipe', 'bulanan')->find($id);
        
        if (!$rekap) {
            return response()->json([
                'success' => false,
                'message' => 'Data rekap tidak ditemukan'
            ], 404);
        }

        if ($rekap->is_submitted) {
            return response()->json([
                'success' => false,
                'message' => 'Rekap yang sudah disubmit tidak dapat di-refresh'
            ], 400);
        }

        // Ambil data siswa di kelas
        $siswaIds = Siswa::where('id_kelas', $rekap->id_kelas)->pluck('nis')->toArray();

        // Hitung ulang statistik absensi dalam periode
        $absensi = Absensi::whereIn('nis', $siswaIds)
            ->whereBetween('tanggal', [$rekap->periode_awal, $rekap->periode_akhir])
            ->get();

        $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
        $sakit = $absensi->where('status_kehadiran', 'sakit')->count();
        $izin = $absensi->where('status_kehadiran', 'izin')->count();
        $alfa = $absensi->where('status_kehadiran', 'alfa')->count();

        $rekap->update([
            'total_hadir' => $hadir,
            'total_sakit' => $sakit,
            'total_izin' => $izin,
            'total_alfa' => $alfa,
        ]);

        $totalData = $hadir + $sakit + $izin + $alfa;

        return response()->json([
            'success' => true,
            'message' => "Data rekap berhasil di-refresh ($totalData data absensi)",
            'data' => $rekap->fresh(['kelas', 'guru'])
        ], 200);
    }

    /**
     * Submit rekap bulanan
     */
    public function submitRekapBulanan($id)
    {
        $rekap = Laporan::where('tipe', 'bulanan')->find($id);
        
        if (!$rekap) {
            return response()->json([
                'success' => false,
                'message' => 'Data rekap tidak ditemukan'
            ], 404);
        }

        if ($rekap->is_submitted) {
            return response()->json([
                'success' => false,
                'message' => 'Rekap sudah disubmit sebelumnya'
            ], 400);
        }

        $rekap->update([
            'is_submitted' => true,
            'submitted_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Rekap bulanan berhasil disubmit',
            'data' => $rekap->fresh(['kelas', 'guru'])
        ], 200);
    }

    /**
     * Unsubmit rekap bulanan
     */
    public function unsubmitRekapBulanan($id)
    {
        $rekap = Laporan::where('tipe', 'bulanan')->find($id);
        
        if (!$rekap) {
            return response()->json([
                'success' => false,
                'message' => 'Data rekap tidak ditemukan'
            ], 404);
        }

        if (!$rekap->is_submitted) {
            return response()->json([
                'success' => false,
                'message' => 'Rekap belum disubmit'
            ], 400);
        }

        $rekap->update([
            'is_submitted' => false,
            'submitted_at' => null
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Submit rekap berhasil dibatalkan',
            'data' => $rekap->fresh(['kelas', 'guru'])
        ], 200);
    }
}
