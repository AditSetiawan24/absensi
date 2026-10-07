<?php

namespace App\Imports;

use App\Models\Siswa;
use App\Models\Kelas;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\SkipsEmptyRows;

class SiswaImport implements ToModel, WithHeadingRow, SkipsEmptyRows
{
    protected $idKelas;

    public function __construct($idKelas = null)
    {
        $this->idKelas = $idKelas;
    }

    public function model(array $row)
    {
        if (!isset($row['nis']) || !isset($row['nama'])) {
            return null;
        }

        // Check for duplicate NIS
        if (Siswa::where('nis', $row['nis'])->exists()) {
            return null;
        }
        
        $kelasId = $this->idKelas;
        
        // Use class ID from row if available and valid
        if (!$kelasId && isset($row['kelas'])) {
            $kelas = Kelas::where('kelas', $row['kelas'])->first();
            if ($kelas) {
                $kelasId = $kelas->id_kelas;
            }
        }

        if (!$kelasId) {
            return null;
        }

        $tanggalLahir = null;
        if (isset($row['tanggal_lahir'])) {
            if (is_numeric($row['tanggal_lahir'])) {
                $tanggalLahir = \PhpOffice\PhpSpreadsheet\Shared\Date::excelToDateTimeObject($row['tanggal_lahir'])->format('Y-m-d');
            } else {
                $tanggalLahir = date('Y-m-d', strtotime($row['tanggal_lahir']));
            }
        }

        return new Siswa([
            'nis' => (string) $row['nis'],
            'nama' => $row['nama'],
            'gender' => $row['gender'] ?? 'Laki - Laki',
            'tanggal_lahir' => $tanggalLahir,
            'alamat' => $row['alamat'] ?? '-',
            'id_kelas' => $kelasId,
        ]);
    }
}
