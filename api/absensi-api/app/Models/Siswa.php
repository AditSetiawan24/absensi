<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Siswa extends Model
{
    use HasFactory;

    protected $table = 'siswa';
    protected $primaryKey = 'nis';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'nis',
        'nama',
        'gender',
        'tanggal_lahir',
        'alamat',
        'id_ortu',
        'id_kelas'
    ];

    public function orangTua()
    {
        return $this->belongsTo(OrangTua::class, 'id_ortu', 'id_ortu');
    }

    public function kelas()
    {
        return $this->belongsTo(Kelas::class, 'id_kelas', 'id_kelas');
    }

    public function absensi()
    {
        return $this->hasMany(Absensi::class, 'nis', 'nis');
    }
}
