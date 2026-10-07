<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Absensi extends Model
{
    use HasFactory;

    protected $table = 'absensi';
    protected $primaryKey = 'id_absensi';
    public $timestamps = false;

    protected $fillable = [
        'nis',
        'nip',
        'tanggal',
        'status_kehadiran',
        'keterangan',
        'file_surat'
    ];

    public function siswa()
    {
        return $this->belongsTo(Siswa::class, 'nis', 'nis');
    }

    public function guru()
    {
        return $this->belongsTo(Guru::class, 'nip', 'nip');
    }
}
