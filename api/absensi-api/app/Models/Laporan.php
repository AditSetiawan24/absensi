<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Laporan extends Model
{
    use HasFactory;

    protected $table = 'laporan';
    protected $primaryKey = 'id_laporan';
    public $timestamps = false;

    protected $fillable = [
        'id_kelas',
        'nip',
        'total_hadir',
        'total_sakit',
        'total_izin',
        'total_alfa',
        'periode_awal',
        'periode_akhir',
        'is_submitted',
        'submitted_at',
        'tipe',
        'bulan',
        'tahun'
    ];

    protected $casts = [
        'is_submitted' => 'boolean',
        'submitted_at' => 'datetime',
        'bulan' => 'integer',
        'tahun' => 'integer',
    ];

    protected $appends = [
        'tahun_ajar',
        'semester',
        'nama_bulan'
    ];

    public function getTahunAjarAttribute()
    {
        if (empty($this->periode_awal)) {
            return $this->kelas ? ($this->kelas->tahun_ajar ?? null) : null;
        }
        $parts = explode('-', $this->periode_awal);
        $year = (int)$parts[0];
        $month = isset($parts[1]) ? (int)$parts[1] : 7;
        return $month >= 7 ? "$year/" . ($year + 1) : ($year - 1) . "/$year";
    }

    public function getSemesterAttribute()
    {
        if (empty($this->periode_awal)) {
            return 'Ganjil';
        }
        $parts = explode('-', $this->periode_awal);
        $month = isset($parts[1]) ? (int)$parts[1] : 7;
        return $month >= 7 ? 'Ganjil' : 'Genap';
    }

    public function getNamaBulanAttribute()
    {
        if (!$this->bulan) {
            return null;
        }
        $bulanNames = [
            1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April',
            5 => 'Mei', 6 => 'Juni', 7 => 'Juli', 8 => 'Agustus',
            9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember'
        ];
        return $bulanNames[$this->bulan] ?? null;
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'id_kelas', 'id_kelas');
    }

    public function guru()
    {
        return $this->belongsTo(Guru::class, 'nip', 'nip');
    }
}
