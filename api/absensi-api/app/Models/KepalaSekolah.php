<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class KepalaSekolah extends Model
{
    use HasFactory, HasApiTokens;

    protected $table = 'kepala_sekolah';
    protected $primaryKey = 'nip';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'nip',
        'nama',
        'no_hp',
        'email',
        'username',
        'password'
    ];

    protected $hidden = [
        'password'
    ];
}
