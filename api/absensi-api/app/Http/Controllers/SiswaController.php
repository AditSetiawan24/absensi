<?php

namespace App\Http\Controllers;

use App\Models\Siswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SiswaController extends Controller
{
    public function index()
    {
        $siswa = Siswa::with(['orangTua', 'kelas', 'absensi'])->get();
        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil diambil',
            'data' => $siswa
        ], 200);
    }

    public function show($nis)
    {
        $siswa = Siswa::with(['orangTua', 'kelas', 'absensi'])->find($nis);
        
        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Data siswa tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil diambil',
            'data' => $siswa
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nis' => 'required|string|max:255|unique:siswa,nis',
            'nama' => 'required|string|max:255',
            'gender' => 'required|in:Laki - Laki,Perempuan',
            'tanggal_lahir' => 'required|date',
            'alamat' => 'required|string',
            'id_ortu' => 'nullable|integer|exists:orang_tua,id_ortu',
            'id_kelas' => 'required|integer|exists:kelas,id_kelas'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $siswa = Siswa::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil ditambahkan',
            'data' => $siswa
        ], 201);
    }

    public function update(Request $request, $nis)
    {
        $siswa = Siswa::find($nis);
        
        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Data siswa tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'nama' => 'string|max:255',
            'gender' => 'in:Laki - Laki,Perempuan',
            'tanggal_lahir' => 'date',
            'alamat' => 'string',
            'id_ortu' => 'integer|exists:orang_tua,id_ortu',
            'id_kelas' => 'integer|exists:kelas,id_kelas'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $siswa->update($request->except('nis'));

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil diperbarui',
            'data' => $siswa
        ], 200);
    }

    public function destroy($nis)
    {
        $siswa = Siswa::find($nis);
        
        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Data siswa tidak ditemukan'
            ], 404);
        }

        $siswa->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berhasil dihapus'
        ], 200);
    }

    /**
     * Search siswa by nama
     */
    public function search(Request $request)
    {
        $query = $request->query('q', '');
        
        if (empty($query)) {
            return response()->json([
                'success' => true,
                'message' => 'Masukkan kata kunci pencarian',
                'data' => []
            ], 200);
        }

        $siswa = Siswa::with(['orangTua', 'kelas'])
            ->where('nama', 'like', '%' . $query . '%')
            ->orWhere('nis', 'like', '%' . $query . '%')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Hasil pencarian siswa',
            'data' => $siswa
        ], 200);
    }

    /**
     * Get siswa by kelas
     */
    public function getByKelas($id_kelas)
    {
        $siswa = Siswa::with(['orangTua', 'kelas', 'absensi'])
            ->where('id_kelas', $id_kelas)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data siswa berdasarkan kelas berhasil diambil',
            'data' => $siswa
        ], 200);
    }

    public function importExcel(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|mimes:xlsx,xls,csv',
            'id_kelas' => 'required|integer|exists:kelas,id_kelas'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $idKelas = $request->id_kelas;
            \Maatwebsite\Excel\Facades\Excel::import(new \App\Imports\SiswaImport($idKelas), $request->file('file'));

            return response()->json([
                'success' => true,
                'message' => 'Data siswa berhasil diimport. NIS duplikat telah diabaikan.'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat import: ' . $e->getMessage()
            ], 500);
        }
    }
}
