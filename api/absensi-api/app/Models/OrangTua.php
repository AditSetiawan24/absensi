<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class OrangTua extends Model
{
    use HasFactory, HasApiTokens;

    protected $table = 'orang_tua';
    protected $primaryKey = 'id_ortu';
    public $timestamps = false;

    protected $fillable = [
        'nama',
        'email',
        'no_hp',
        'alamat',
        'username',
        'password'
    ];

    protected $hidden = [
        'password'
    ];

    public function siswa()
    {
        return $this->hasMany(Siswa::class, 'id_ortu', 'id_ortu');
    }
}
