<?php

namespace App\Http\Controllers;

use App\Models\KepalaSekolah;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class KepalaSekolahController extends Controller
{
    public function index()
    {
        $kepalaSekolah = KepalaSekolah::all();
        return response()->json([
            'success' => true,
            'message' => 'Data kepala sekolah berhasil diambil',
            'data' => $kepalaSekolah
        ], 200);
    }

    public function show($nip)
    {
        $kepalaSekolah = KepalaSekolah::find($nip);
        
        if (!$kepalaSekolah) {
            return response()->json([
                'success' => false,
                'message' => 'Data kepala sekolah tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data kepala sekolah berhasil diambil',
            'data' => $kepalaSekolah
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nip' => 'required|string|max:255|unique:kepala_sekolah,nip',
            'nama' => 'required|string|max:255',
            'no_hp' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'username' => 'required|string|max:255|unique:kepala_sekolah,username',
            'password' => 'required|string|min:6'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $kepalaSekolah = KepalaSekolah::create([
            'nip' => $request->nip,
            'nama' => $request->nama,
            'no_hp' => $request->no_hp,
            'email' => $request->email,
            'username' => $request->username,
            'password' => Hash::make($request->password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data kepala sekolah berhasil ditambahkan',
            'data' => $kepalaSekolah
        ], 201);
    }

    public function update(Request $request, $nip)
    {
        $kepalaSekolah = KepalaSekolah::find($nip);
        
        if (!$kepalaSekolah) {
            return response()->json([
                'success' => false,
                'message' => 'Data kepala sekolah tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'nama' => 'string|max:255',
            'no_hp' => 'string|max:255',
            'email' => 'email|max:255',
            'username' => 'string|max:255|unique:kepala_sekolah,username,' . $nip . ',nip',
            'password' => 'string|min:6'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $dataToUpdate = $request->except(['nip', 'password']);
        
        if ($request->has('password')) {
            $dataToUpdate['password'] = Hash::make($request->password);
        }

        $kepalaSekolah->update($dataToUpdate);

        return response()->json([
            'success' => true,
            'message' => 'Data kepala sekolah berhasil diperbarui',
            'data' => $kepalaSekolah
        ], 200);
    }

    public function destroy($nip)
    {
        $kepalaSekolah = KepalaSekolah::find($nip);
        
        if (!$kepalaSekolah) {
            return response()->json([
                'success' => false,
                'message' => 'Data kepala sekolah tidak ditemukan'
            ], 404);
        }

        $kepalaSekolah->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data kepala sekolah berhasil dihapus'
        ], 200);
    }
}
