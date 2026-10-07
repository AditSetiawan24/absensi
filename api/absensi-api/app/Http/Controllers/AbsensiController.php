<?php

namespace App\Http\Controllers;

use App\Models\Absensi;
use App\Models\Siswa;
use App\Models\Kelas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class AbsensiController extends Controller
{
    public function index(Request $request)
    {
        $query = Absensi::with(['siswa', 'guru']);
        
        // Filter by date range
        if ($request->has('start_date') && $request->has('end_date')) {
            $query->whereBetween('tanggal', [$request->start_date, $request->end_date]);
        }
        
        // Filter by NIP (guru)
        if ($request->has('nip')) {
            $query->where('nip', $request->nip);
        }
        
        // Filter by kelas
        if ($request->has('id_kelas')) {
            $siswaIds = Siswa::where('id_kelas', $request->id_kelas)->pluck('nis');
            $query->whereIn('nis', $siswaIds);
        }
        
        $absensi = $query->orderBy('tanggal', 'desc')->get();
        
        $data = $absensi->map(function ($item) {
            return [
                'id_absensi' => $item->id_absensi,
                'nis' => $item->nis,
                'nip' => $item->nip,
                'tanggal' => $item->tanggal,
                'status_kehadiran' => $item->status_kehadiran,
                'keterangan' => $item->keterangan,
                'file_surat' => $item->file_surat,
                'nama_siswa' => $item->siswa ? $item->siswa->nama : null,
                'nama_guru' => $item->guru ? $item->guru->nama : null,
                'siswa' => $item->siswa,
                'guru' => $item->guru
            ];
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Data absensi berhasil diambil',
            'data' => $data
        ], 200);
    }

    public function getToday(Request $request)
    {
        $today = date('Y-m-d');
        $query = Absensi::with(['siswa', 'guru'])->where('tanggal', $today);
        
        if ($request->has('nip')) {
            $query->where('nip', $request->nip);
        }
        
        if ($request->has('id_kelas')) {
            $siswaIds = Siswa::where('id_kelas', $request->id_kelas)->pluck('nis');
            $query->whereIn('nis', $siswaIds);
        }
        
        $absensi = $query->get();
        
        $data = $absensi->map(function ($item) {
            return [
                'id_absensi' => $item->id_absensi,
                'nis' => $item->nis,
                'nip' => $item->nip,
                'tanggal' => $item->tanggal,
                'status_kehadiran' => $item->status_kehadiran,
                'keterangan' => $item->keterangan,
                'file_surat' => $item->file_surat,
                'nama_siswa' => $item->siswa ? $item->siswa->nama : null,
                'nama_guru' => $item->guru ? $item->guru->nama : null
            ];
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Data absensi hari ini berhasil diambil',
            'tanggal' => $today,
            'data' => $data
        ], 200);
    }

    public function getByDate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'tanggal' => 'required|date'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = Absensi::with(['siswa', 'guru'])->where('tanggal', $request->tanggal);
        
        if ($request->has('nip')) {
            $query->where('nip', $request->nip);
        }
        
        if ($request->has('id_kelas')) {
            $siswaIds = Siswa::where('id_kelas', $request->id_kelas)->pluck('nis');
            $query->whereIn('nis', $siswaIds);
        }
        
        $absensi = $query->get();
        
        $data = $absensi->map(function ($item) {
            return [
                'id_absensi' => $item->id_absensi,
                'nis' => $item->nis,
                'nip' => $item->nip,
                'tanggal' => $item->tanggal,
                'status_kehadiran' => $item->status_kehadiran,
                'keterangan' => $item->keterangan,
                'file_surat' => $item->file_surat,
                'nama_siswa' => $item->siswa ? $item->siswa->nama : null,
                'nama_guru' => $item->guru ? $item->guru->nama : null,
                'siswa' => $item->siswa ? [
                    'nis' => $item->siswa->nis,
                    'nama' => $item->siswa->nama,
                ] : null,
            ];
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Data absensi berhasil diambil',
            'tanggal' => $request->tanggal,
            'data' => $data
        ], 200);
    }

    public function getBySiswa($nis)
    {
        $siswa = Siswa::with('kelas')->find($nis);
        
        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Siswa tidak ditemukan'
            ], 404);
        }

        $absensi = Absensi::where('nis', $nis)->orderBy('tanggal', 'desc')->get();
        
        // Calculate statistics
        $totalAbsensi = $absensi->count();
        $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
        
        return response()->json([
            'success' => true,
            'message' => 'Data absensi siswa berhasil diambil',
            'data' => [
                'siswa' => $siswa,
                'statistics' => [
                    'total_hari' => $totalAbsensi,
                    'hadir' => $hadir,
                    'izin' => $absensi->where('status_kehadiran', 'izin')->count(),
                    'sakit' => $absensi->where('status_kehadiran', 'sakit')->count(),
                    'alfa' => $absensi->where('status_kehadiran', 'alfa')->count(),
                    'persentase_hadir' => $totalAbsensi > 0 ? round(($hadir / $totalAbsensi) * 100, 2) : 0
                ],
                'absensi' => $absensi
            ]
        ], 200);
    }

    public function getByKelas($id_kelas)
    {
        $kelas = Kelas::with(['guru', 'siswa'])->find($id_kelas);
        
        if (!$kelas) {
            return response()->json([
                'success' => false,
                'message' => 'Kelas tidak ditemukan'
            ], 404);
        }

        $tanggal = request()->query('date', date('Y-m-d'));
        $siswaIds = $kelas->siswa->pluck('nis');
        
        $absensi = Absensi::with('siswa')
            ->whereIn('nis', $siswaIds)
            ->where('tanggal', $tanggal)
            ->orderBy('tanggal', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'id_absensi' => $item->id_absensi,
                    'nis' => $item->nis,
                    'nip' => $item->nip,
                    'tanggal' => $item->tanggal,
                    'status_kehadiran' => $item->status_kehadiran,
                    'keterangan' => $item->keterangan,
                    'file_surat' => $item->file_surat,
                    'nama_siswa' => $item->siswa ? $item->siswa->nama : null,
                    'siswa' => $item->siswa ? [
                        'nis' => $item->siswa->nis,
                        'nama' => $item->siswa->nama,
                        'kelas' => $item->siswa->kelas ? $item->siswa->kelas->kelas : null,
                    ] : null,
                ];
            });
        
        return response()->json([
            'success' => true,
            'message' => 'Data absensi kelas berhasil diambil',
            'data' => $absensi
        ], 200);
    }

    public function weeklyStats(Request $request)
    {
        $nip = $request->query('nip');
        $id_kelas = $request->query('id_kelas');
        
        $weeklyStats = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = date('Y-m-d', strtotime("-$i days"));
            
            $query = Absensi::where('tanggal', $date);
            
            if ($nip) {
                $query->where('nip', $nip);
            }
            
            if ($id_kelas) {
                $siswaIds = Siswa::where('id_kelas', $id_kelas)->pluck('nis');
                $query->whereIn('nis', $siswaIds);
            }
            
            $dayAbsensi = $query->get();
            
            $weeklyStats[] = [
                'tanggal' => $date,
                'hari' => $this->getDayName($date),
                'hadir' => $dayAbsensi->where('status_kehadiran', 'hadir')->count(),
                'izin' => $dayAbsensi->where('status_kehadiran', 'izin')->count(),
                'sakit' => $dayAbsensi->where('status_kehadiran', 'sakit')->count(),
                'alfa' => $dayAbsensi->where('status_kehadiran', 'alfa')->count(),
                'total' => $dayAbsensi->count()
            ];
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Statistik mingguan berhasil diambil',
            'data' => $weeklyStats
        ], 200);
    }

    public function getStatistics(Request $request)
    {
        $query = Absensi::query();
        
        if ($request->has('start_date') && $request->has('end_date')) {
            $query->whereBetween('tanggal', [$request->start_date, $request->end_date]);
        }
        
        if ($request->has('nip')) {
            $query->where('nip', $request->nip);
        }
        
        if ($request->has('id_kelas')) {
            $siswaIds = Siswa::where('id_kelas', $request->id_kelas)->pluck('nis');
            $query->whereIn('nis', $siswaIds);
        }
        
        $absensi = $query->get();
        $totalAbsensi = $absensi->count();
        $hadir = $absensi->where('status_kehadiran', 'hadir')->count();
        
        return response()->json([
            'success' => true,
            'message' => 'Statistik absensi berhasil diambil',
            'data' => [
                'total' => $totalAbsensi,
                'hadir' => $hadir,
                'izin' => $absensi->where('status_kehadiran', 'izin')->count(),
                'sakit' => $absensi->where('status_kehadiran', 'sakit')->count(),
                'alfa' => $absensi->where('status_kehadiran', 'alfa')->count(),
                'persentase_hadir' => $totalAbsensi > 0 ? round(($hadir / $totalAbsensi) * 100, 2) : 0
            ]
        ], 200);
    }

    public function show($id)
    {
        $absensi = Absensi::with(['siswa', 'guru'])->find($id);
        
        if (!$absensi) {
            return response()->json([
                'success' => false,
                'message' => 'Data absensi tidak ditemukan'
            ], 404);
        }

        $data = [
            'id_absensi' => $absensi->id_absensi,
            'nis' => $absensi->nis,
            'nip' => $absensi->nip,
            'tanggal' => $absensi->tanggal,
            'status_kehadiran' => $absensi->status_kehadiran,
            'keterangan' => $absensi->keterangan,
            'file_surat' => $absensi->file_surat,
            'nama_siswa' => $absensi->siswa ? $absensi->siswa->nama : null,
            'nama_guru' => $absensi->guru ? $absensi->guru->nama : null,
            'siswa' => $absensi->siswa,
            'guru' => $absensi->guru
        ];

        return response()->json([
            'success' => true,
            'message' => 'Data absensi berhasil diambil',
            'data' => $data
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nis' => 'required|string|max:255|exists:siswa,nis',
            'nip' => 'required|string|max:255|exists:guru,nip',
            'tanggal' => 'required|date',
            'status_kehadiran' => 'required|in:hadir,izin,sakit,alfa',
            'keterangan' => 'nullable|string|max:255',
            'file_surat' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check if absensi already exists for this siswa on this date
        $existingAbsensi = Absensi::where('nis', $request->nis)
            ->where('tanggal', $request->tanggal)
            ->first();
            
        if ($existingAbsensi) {
            return response()->json([
                'success' => false,
                'message' => 'Absensi untuk siswa ini pada tanggal tersebut sudah ada'
            ], 422);
        }

        $data = $request->except('file_surat');
        
        // Handle file upload
        if ($request->hasFile('file_surat')) {
            $file = $request->file('file_surat');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->storeAs('public/surat_izin', $filename);
            $data['file_surat'] = 'surat_izin/' . $filename;
        }

        $absensi = Absensi::create($data);
        $absensi->load(['siswa', 'guru']);
        
        return response()->json([
            'success' => true,
            'message' => 'Data absensi berhasil ditambahkan',
            'data' => $absensi
        ], 201);
    }

    public function storeBulk(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'absensi' => 'required|array',
            'absensi.*.nis' => 'required|string|max:255|exists:siswa,nis',
            'absensi.*.nip' => 'required|string|max:255|exists:guru,nip',
            'absensi.*.tanggal' => 'required|date',
            'absensi.*.status_kehadiran' => 'required|in:hadir,izin,sakit,alfa',
            'absensi.*.keterangan' => 'nullable|string|max:255'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $created = [];
        $skipped = [];
        
        foreach ($request->absensi as $item) {
            // Check if already exists
            $existing = Absensi::where('nis', $item['nis'])
                ->where('tanggal', $item['tanggal'])
                ->first();
                
            if ($existing) {
                // Update existing
                $existing->update($item);
                $created[] = $existing;
            } else {
                // Create new
                $absensi = Absensi::create($item);
                $created[] = $absensi;
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Data absensi bulk berhasil ditambahkan/diperbarui',
            'data' => [
                'total_processed' => count($created),
                'absensi' => $created
            ]
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $absensi = Absensi::find($id);
        
        if (!$absensi) {
            return response()->json([
                'success' => false,
                'message' => 'Data absensi tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'nis' => 'string|max:255|exists:siswa,nis',
            'nip' => 'string|max:255|exists:guru,nip',
            'tanggal' => 'date',
            'status_kehadiran' => 'in:hadir,izin,sakit,alfa',
            'keterangan' => 'nullable|string|max:255',
            'file_surat' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->except('file_surat');
        
        // Handle file upload
        if ($request->hasFile('file_surat')) {
            // Delete old file if exists
            if ($absensi->file_surat) {
                Storage::delete('public/' . $absensi->file_surat);
            }
            
            $file = $request->file('file_surat');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->storeAs('public/surat_izin', $filename);
            $data['file_surat'] = 'surat_izin/' . $filename;
        }

        $absensi->update($data);
        $absensi->load(['siswa', 'guru']);

        return response()->json([
            'success' => true,
            'message' => 'Data absensi berhasil diperbarui',
            'data' => $absensi
        ], 200);
    }

    public function destroy($id)
    {
        $absensi = Absensi::find($id);
        
        if (!$absensi) {
            return response()->json([
                'success' => false,
                'message' => 'Data absensi tidak ditemukan'
            ], 404);
        }

        // Delete associated file
        if ($absensi->file_surat) {
            Storage::delete('public/' . $absensi->file_surat);
        }

        $absensi->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data absensi berhasil dihapus'
        ], 200);
    }

    /**
     * Mendapatkan daftar siswa yang tidak hadir berturut-turut 3 hari atau lebih
     */
    public function consecutiveAbsent(Request $request)
    {
        $siswaQuery = Siswa::with(['kelas', 'orangTua']);
        
        if ($request->has('id_kelas')) {
            $siswaQuery->where('id_kelas', $request->id_kelas);
        }
        
        $siswaList = $siswaQuery->get();
        $alertList = [];
        
        foreach ($siswaList as $siswa) {
            $absensiRecent = Absensi::where('nis', $siswa->nis)
                ->orderBy('tanggal', 'desc')
                ->limit(3)
                ->get();
            
            if ($absensiRecent->count() < 3) {
                continue;
            }
            
            $consecutiveAbsent = true;
            $absentDays = 0;
            $lastDate = null;
            
            foreach ($absensiRecent as $absensi) {
                if ($absensi->status_kehadiran === 'hadir') {
                    $consecutiveAbsent = false;
                    break;
                }
                $absentDays++;
                if (!$lastDate) {
                    $lastDate = $absensi->tanggal;
                }
            }
            
            if ($consecutiveAbsent && $absentDays >= 3) {
                $alertList[] = [
                    'nis' => $siswa->nis,
                    'nama_siswa' => $siswa->nama,
                    'kelas' => $siswa->kelas ? $siswa->kelas->kelas : null,
                    'nama_orang_tua' => $siswa->orangTua ? $siswa->orangTua->nama : null,
                    'no_hp_orang_tua' => $siswa->orangTua ? $siswa->orangTua->no_hp : null,
                    'consecutive_days' => $absentDays,
                    'last_absent_date' => $lastDate,
                    'status_terakhir' => $absensiRecent->first()->status_kehadiran,
                    'keterangan' => $absensiRecent->first()->keterangan
                ];
            }
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Data siswa dengan ketidakhadiran berturut-turut berhasil diambil',
            'total' => count($alertList),
            'data' => $alertList
        ], 200);
    }

    private function getDayName($date)
    {
        $days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
        return $days[date('w', strtotime($date))];
    }
}
