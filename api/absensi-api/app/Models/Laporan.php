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

    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'id_kelas', 'id_kelas');
    }

    public function guru()
    {
        return $this->belongsTo(Guru::class, 'nip', 'nip');
    }
}
