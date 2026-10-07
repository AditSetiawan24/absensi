<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Guru extends Model
{
    use HasFactory, HasApiTokens;

    protected $table = 'guru';
    protected $primaryKey = 'nip';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'nip',
        'nama',
        'gender',
        'no_hp',
        'email',
        'username',
        'password'
    ];

    protected $hidden = [
        'password'
    ];

    public function kelas()
    {
        return $this->hasMany(Kelas::class, 'nip', 'nip');
    }

    public function absensi()
    {
        return $this->hasMany(Absensi::class, 'nip', 'nip');
    }

    public function laporan()
    {
        return $this->hasMany(Laporan::class, 'nip', 'nip');
    }
}
