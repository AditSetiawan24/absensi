<?php

namespace App\Http\Controllers;

use App\Models\Kelas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class KelasController extends Controller
{
    public function index()
    {
        $kelas = Kelas::with(['guru', 'siswa'])->get();
        return response()->json([
            'success' => true,
            'message' => 'Data kelas berhasil diambil',
            'data' => $kelas
        ], 200);
    }

    public function show($id)
    {
        $kelas = Kelas::with(['guru', 'siswa'])->find($id);
        
        if (!$kelas) {
            return response()->json([
                'success' => false,
                'message' => 'Data kelas tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data kelas berhasil diambil',
            'data' => $kelas
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'kelas' => 'required|string|max:255',
            'tahun_ajar' => 'required|string|max:255',
            'nip' => 'required|string|max:255|exists:guru,nip'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $kelas = Kelas::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Data kelas berhasil ditambahkan',
            'data' => $kelas
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $kelas = Kelas::find($id);
        
        if (!$kelas) {
            return response()->json([
                'success' => false,
                'message' => 'Data kelas tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'kelas' => 'string|max:255',
            'tahun_ajar' => 'string|max:255',
            'nip' => 'string|max:255|exists:guru,nip'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $kelas->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Data kelas berhasil diperbarui',
            'data' => $kelas
        ], 200);
    }

    public function destroy($id)
    {
        $kelas = Kelas::find($id);
        
        if (!$kelas) {
            return response()->json([
                'success' => false,
                'message' => 'Data kelas tidak ditemukan'
            ], 404);
        }

        $kelas->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data kelas berhasil dihapus'
        ], 200);
    }

    /**
     * Get kelas by guru NIP
     */
    public function getByGuru($nip)
    {
        $kelas = Kelas::with(['guru', 'siswa'])->where('nip', $nip)->get();

        return response()->json([
            'success' => true,
            'message' => 'Data kelas berdasarkan guru berhasil diambil',
            'data' => $kelas
        ], 200);
    }
}
