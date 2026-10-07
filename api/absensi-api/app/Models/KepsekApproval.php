<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KepsekApproval extends Model
{
    use HasFactory;
    
    protected $table = 'kepsek_approvals';

    protected $fillable = [
        'nip_kepsek',
        'nip_guru'
    ];
}
