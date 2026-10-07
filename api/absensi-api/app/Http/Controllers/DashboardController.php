<?php

namespace App\Http\Controllers;

use App\Models\Absensi;
use App\Models\Guru;
use App\Models\Kelas;
use App\Models\Siswa;
use App\Models\OrangTua;
use App\Models\Laporan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * Dashboard untuk Guru
     */
    public function guruDashboard($nip)
    {
        $guru = Guru::find($nip);
        
        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Guru tidak ditemukan'
            ], 404);
        }

        // Ambil kelas yang diampu guru
        $kelas = Kelas::where('nip', $nip)->first();
        
        if (!$kelas) {
            return response()->json([
                'success' => true,
                'message' => 'Guru belum memiliki kelas',
                'data' => [
                    'guru' => $guru,
                    'kelas' => null,
                    'today_stats' => null,
                    'absent_today' => [],
                    'weekly_stats' => [],
                    'consecutive_absent' => []
                ]
            ], 200);
        }

        $today = date('Y-m-d');
        
        // Statistik hari ini
        $siswaKelas = Siswa::where('id_kelas', $kelas->id_kelas)->get();
        $totalSiswa = $siswaKelas->count();
        
        $absensiToday = Absensi::whereIn('nis', $siswaKelas->pluck('nis'))
            ->where('tanggal', $today)
            ->get();
        
        $todayStats = [
            'total_siswa' => $totalSiswa,
            'hadir' => $absensiToday->where('status_kehadiran', 'hadir')->count(),
            'izin' => $absensiToday->where('status_kehadiran', 'izin')->count(),
            'sakit' => $absensiToday->where('status_kehadiran', 'sakit')->count(),
            'alfa' => $absensiToday->where('status_kehadiran', 'alfa')->count(),
            'belum_absen' => $totalSiswa - $absensiToday->count(),
            'persentase_hadir' => $totalSiswa > 0 ? round(($absensiToday->where('status_kehadiran', 'hadir')->count() / $totalSiswa) * 100, 2) : 0
        ];

        // Siswa yang tidak hadir hari ini
        $absentToday = $absensiToday->whereIn('status_kehadiran', ['izin', 'sakit', 'alfa'])
            ->map(function ($item) {
                return [
                    'nis' => $item->nis,
                    'nama' => $item->siswa ? $item->siswa->nama : null,
                    'status' => $item->status_kehadiran,
                    'keterangan' => $item->keterangan
                ];
            })->values();

        // Statistik mingguan (7 hari terakhir)
        $weeklyStats = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = date('Y-m-d', strtotime("-$i days"));
            $dayAbsensi = Absensi::whereIn('nis', $siswaKelas->pluck('nis'))
                ->where('tanggal', $date)
                ->get();
            
            $hadir = $dayAbsensi->where('status_kehadiran', 'hadir')->count();
            $izin = $dayAbsensi->where('status_kehadiran', 'izin')->count();
            $sakit = $dayAbsensi->where('status_kehadiran', 'sakit')->count();
            $alfa = $dayAbsensi->where('status_kehadiran', 'alfa')->count();
            $total = $dayAbsensi->count();
            $persentaseHadir = $totalSiswa > 0 ? round(($hadir / $totalSiswa) * 100, 2) : 0;
            
            $weeklyStats[] = [
                'tanggal' => $date,
                'hari' => $this->getDayName($date),
                'hadir' => $hadir,
                'izin' => $izin,
                'sakit' => $sakit,
                'alfa' => $alfa,
                'total' => $total,
                'persentase_hadir' => $persentaseHadir
            ];
        }

        // Siswa dengan ketidakhadiran berturut-turut
        $consecutiveAbsent = $this->getConsecutiveAbsentStudents($siswaKelas->pluck('nis')->toArray());

        return response()->json([
            'success' => true,
            'message' => 'Dashboard guru berhasil diambil',
            'data' => [
                'guru' => $guru,
                'kelas' => $kelas,
                'today_stats' => $todayStats,
                'absent_today' => $absentToday,
                'weekly_stats' => $weeklyStats,
                'consecutive_absent' => $consecutiveAbsent
            ]
        ], 200);
    }

    /**
     * Dashboard untuk Kepala Sekolah
     */
    public function kepalaSekolahDashboard(Request $request)
    {
        $tahunAjar = $request->query('tahun_ajar', date('Y'));
        $semester = $request->query('semester', 1);
        $kelasFilter = $request->query('kelas', 'all');

        // Total data
        $totalKelas = Kelas::count();
        $totalGuru = Guru::count();
        $totalSiswa = Siswa::count();

        // Query kelas
        $kelasQuery = Kelas::with(['guru', 'siswa']);
        if ($kelasFilter !== 'all') {
            $kelasQuery->where('kelas', $kelasFilter);
        }
        $kelasList = $kelasQuery->get();

        // Statistik per kelas
        $classStats = [];
        foreach ($kelasList as $kelas) {
            $siswaIds = $kelas->siswa->pluck('nis')->toArray();
            
            // Tentukan periode berdasarkan semester
            if ($semester == 1) {
                $startDate = $tahunAjar . '-07-01';
                $endDate = $tahunAjar . '-12-31';
            } else {
                $startDate = ($tahunAjar + 1) . '-01-01';
                $endDate = ($tahunAjar + 1) . '-06-30';
            }
            
            $absensi = Absensi::whereIn('nis', $siswaIds)
                ->whereBetween('tanggal', [$startDate, $endDate])
                ->get();
            
            $totalAbsensi = $absensi->count();
            $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
            
            $classStats[] = [
                'id_kelas' => $kelas->id_kelas,
                'kelas' => $kelas->kelas,
                'guru' => $kelas->guru ? $kelas->guru->nama : null,
                'nip' => $kelas->nip,
                'jumlah_siswa' => $kelas->siswa->count(),
                'total_absensi' => $totalAbsensi,
                'hadir' => $hadir,
                'izin' => $absensi->where('status_kehadiran', 'izin')->count(),
                'sakit' => $absensi->where('status_kehadiran', 'sakit')->count(),
                'alfa' => $absensi->where('status_kehadiran', 'alfa')->count(),
                'persentase_hadir' => $totalAbsensi > 0 ? round(($hadir / $totalAbsensi) * 100, 2) : 0
            ];
        }

        // Sort by persentase kehadiran
        usort($classStats, function($a, $b) {
            return $b['persentase_hadir'] <=> $a['persentase_hadir'];
        });

        return response()->json([
            'success' => true,
            'message' => 'Dashboard kepala sekolah berhasil diambil',
            'data' => [
                'nama_sekolah' => 'SD Negeri Kemutung Kidul',
                'total_kelas' => $totalKelas,
                'total_guru' => $totalGuru,
                'total_siswa' => $totalSiswa,
                'tahun_ajar' => $tahunAjar,
                'semester' => $semester,
                'class_stats' => $classStats
            ]
        ], 200);
    }

    /**
     * Dashboard untuk Orang Tua
     */
    public function orangTuaDashboard($id_ortu)
    {
        $orangTua = OrangTua::with('siswa')->find($id_ortu);
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Orang tua tidak ditemukan'
            ], 404);
        }

        $siswaData = [];
        foreach ($orangTua->siswa as $siswa) {
            $siswa->load('kelas');
            
            // Statistik kehadiran siswa
            $absensi = Absensi::where('nis', $siswa->nis)->get();
            $totalAbsensi = $absensi->count();
            $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
            
            // Kalender absensi (30 hari terakhir)
            $calendarData = [];
            for ($i = 29; $i >= 0; $i--) {
                $date = date('Y-m-d', strtotime("-$i days"));
                $dayAbsensi = $absensi->where('tanggal', $date)->first();
                
                $calendarData[] = [
                    'tanggal' => $date,
                    'status' => $dayAbsensi ? $dayAbsensi->status_kehadiran : null,
                    'keterangan' => $dayAbsensi ? $dayAbsensi->keterangan : null
                ];
            }

            // Riwayat ketidakhadiran
            $absentHistory = $absensi->whereIn('status_kehadiran', ['izin', 'sakit', 'alfa'])
                ->sortByDesc('tanggal')
                ->take(10)
                ->map(function ($item) {
                    return [
                        'tanggal' => $item->tanggal,
                        'status' => $item->status_kehadiran,
                        'keterangan' => $item->keterangan
                    ];
                })->values();

            $siswaData[] = [
                'nis' => $siswa->nis,
                'nama' => $siswa->nama,
                'kelas' => $siswa->kelas ? $siswa->kelas->kelas : null,
                'statistics' => [
                    'total_hari' => $totalAbsensi,
                    'hadir' => $hadir,
                    'izin' => $absensi->where('status_kehadiran', 'izin')->count(),
                    'sakit' => $absensi->where('status_kehadiran', 'sakit')->count(),
                    'alfa' => $absensi->where('status_kehadiran', 'alfa')->count(),
                    'persentase_hadir' => $totalAbsensi > 0 ? round(($hadir / $totalAbsensi) * 100, 2) : 0
                ],
                'calendar' => $calendarData,
                'absent_history' => $absentHistory
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Dashboard orang tua berhasil diambil',
            'data' => [
                'orang_tua' => [
                    'id_ortu' => $orangTua->id_ortu,
                    'nama' => $orangTua->nama,
                    'email' => $orangTua->email,
                    'no_hp' => $orangTua->no_hp
                ],
                'siswa' => $siswaData
            ]
        ], 200);
    }

    /**
     * Mendapatkan statistik umum
     */
    public function getStatistics(Request $request)
    {
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

        // Query absensi
        $query = Absensi::whereBetween('tanggal', [$startDate, $endDate]);
        
        if ($kelas !== 'all') {
            $kelasData = Kelas::where('kelas', $kelas)->first();
            if ($kelasData) {
                $siswaIds = Siswa::where('id_kelas', $kelasData->id_kelas)->pluck('nis');
                $query->whereIn('nis', $siswaIds);
            }
        }

        $absensi = $query->get();
        $totalAbsensi = $absensi->count();
        $hadir = $absensi->where('status_kehadiran', 'hadir')->count();

        // Hitung hari efektif
        $hariEfektif = $absensi->groupBy('tanggal')->count();

        return response()->json([
            'success' => true,
            'message' => 'Statistik berhasil diambil',
            'data' => [
                'periode' => [
                    'tahun_ajar' => $tahunAjar,
                    'semester' => $semester,
                    'start_date' => $startDate,
                    'end_date' => $endDate
                ],
                'statistics' => [
                    'total_absensi' => $totalAbsensi,
                    'hadir' => $hadir,
                    'izin' => $absensi->where('status_kehadiran', 'izin')->count(),
                    'sakit' => $absensi->where('status_kehadiran', 'sakit')->count(),
                    'alfa' => $absensi->where('status_kehadiran', 'alfa')->count(),
                    'persentase_hadir' => $totalAbsensi > 0 ? round(($hadir / $totalAbsensi) * 100, 2) : 0,
                    'hari_efektif' => $hariEfektif
                ]
            ]
        ], 200);
    }

    /**
     * Perbandingan antar kelas
     */
    public function classComparison(Request $request)
    {
        $tahunAjar = $request->query('tahun_ajar', date('Y'));
        
        $kelasList = Kelas::with(['guru', 'siswa'])->get();
        
        $comparison = [];
        foreach ($kelasList as $kelas) {
            $siswaIds = $kelas->siswa->pluck('nis')->toArray();
            $absensi = Absensi::whereIn('nis', $siswaIds)->get();
            
            $totalAbsensi = $absensi->count();
            $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
            
            $comparison[] = [
                'kelas' => $kelas->kelas,
                'guru' => $kelas->guru ? $kelas->guru->nama : null,
                'persentase_hadir' => $totalAbsensi > 0 ? round(($hadir / $totalAbsensi) * 100, 2) : 0
            ];
        }

        // Sort ascending by kelas name
        usort($comparison, function($a, $b) {
            return strcmp($a['kelas'], $b['kelas']);
        });

        return response()->json([
            'success' => true,
            'message' => 'Perbandingan kelas berhasil diambil',
            'data' => $comparison
        ], 200);
    }

    /**
     * Perbandingan semester
     */
    public function semesterComparison(Request $request)
    {
        $tahunAjar = $request->query('tahun_ajar', date('Y'));
        $kelas = $request->query('kelas', 'all');

        $semesters = [
            1 => [
                'start' => $tahunAjar . '-07-01',
                'end' => $tahunAjar . '-12-31'
            ],
            2 => [
                'start' => ($tahunAjar + 1) . '-01-01',
                'end' => ($tahunAjar + 1) . '-06-30'
            ]
        ];

        $comparison = [];
        foreach ($semesters as $sem => $dates) {
            $query = Absensi::whereBetween('tanggal', [$dates['start'], $dates['end']]);
            
            if ($kelas !== 'all') {
                $kelasData = Kelas::where('kelas', $kelas)->first();
                if ($kelasData) {
                    $siswaIds = Siswa::where('id_kelas', $kelasData->id_kelas)->pluck('nis');
                    $query->whereIn('nis', $siswaIds);
                }
            }

            $absensi = $query->get();
            $totalAbsensi = $absensi->count();
            $hadir = $absensi->where('status_kehadiran', 'hadir')->count();

            $comparison[] = [
                'semester' => $sem,
                'periode' => $dates,
                'persentase_hadir' => $totalAbsensi > 0 ? round(($hadir / $totalAbsensi) * 100, 2) : 0,
                'total_hadir' => $hadir,
                'total_absensi' => $totalAbsensi
            ];
        }

        // Hitung selisih
        $selisih = 0;
        if (count($comparison) == 2) {
            $selisih = $comparison[1]['persentase_hadir'] - $comparison[0]['persentase_hadir'];
        }

        return response()->json([
            'success' => true,
            'message' => 'Perbandingan semester berhasil diambil',
            'data' => [
                'comparison' => $comparison,
                'selisih_persentase' => $selisih
            ]
        ], 200);
    }

    /**
     * Helper function untuk mendapatkan nama hari
     */
    private function getDayName($date)
    {
        $days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
        return $days[date('w', strtotime($date))];
    }

    /**
     * Helper function untuk mendapatkan siswa dengan ketidakhadiran berturut-turut
     */
    private function getConsecutiveAbsentStudents($nisArray)
    {
        $alertList = [];
        
        foreach ($nisArray as $nis) {
            $siswa = Siswa::with(['kelas', 'orangTua'])->find($nis);
            
            if (!$siswa) continue;
            
            $absensiRecent = Absensi::where('nis', $nis)
                ->orderBy('tanggal', 'desc')
                ->limit(3)
                ->get();
            
            if ($absensiRecent->count() < 3) continue;
            
            $consecutiveAbsent = true;
            foreach ($absensiRecent as $absensi) {
                if ($absensi->status_kehadiran === 'hadir') {
                    $consecutiveAbsent = false;
                    break;
                }
            }
            
            if ($consecutiveAbsent) {
                $alertList[] = [
                    'nis' => $siswa->nis,
                    'nama' => $siswa->nama,
                    'kelas' => $siswa->kelas ? $siswa->kelas->kelas : null,
                    'consecutive_days' => 3,
                    'last_status' => $absensiRecent->first()->status_kehadiran,
                    'last_date' => $absensiRecent->first()->tanggal
                ];
            }
        }
        
        return $alertList;
    }
}
