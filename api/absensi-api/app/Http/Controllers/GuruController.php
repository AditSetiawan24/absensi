<?php

namespace App\Http\Controllers;

use App\Models\Guru;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class GuruController extends Controller
{
    public function index()
    {
        $guru = Guru::with(['kelas', 'absensi'])->get();
        return response()->json([
            'success' => true,
            'message' => 'Data guru berhasil diambil',
            'data' => $guru
        ], 200);
    }

    public function show($nip)
    {
        $guru = Guru::with(['kelas', 'absensi'])->find($nip);
        
        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Data guru tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data guru berhasil diambil',
            'data' => $guru
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nip' => 'required|string|max:255|unique:guru,nip',
            'nama' => 'required|string|max:255',
            'gender' => 'required|in:Laki - Laki,Perempuan',
            'no_hp' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'username' => 'required|string|max:255|unique:guru,username',
            'password' => 'required|string|min:6'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $guru = Guru::create([
            'nip' => $request->nip,
            'nama' => $request->nama,
            'gender' => $request->gender,
            'no_hp' => $request->no_hp,
            'email' => $request->email,
            'username' => $request->username,
            'password' => Hash::make($request->password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data guru berhasil ditambahkan',
            'data' => $guru
        ], 201);
    }

    public function update(Request $request, $nip)
    {
        $guru = Guru::find($nip);
        
        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Data guru tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'nama' => 'string|max:255',
            'gender' => 'in:Laki - Laki,Perempuan',
            'no_hp' => 'string|max:255',
            'email' => 'email|max:255',
            'username' => 'string|max:255|unique:guru,username,' . $nip . ',nip',
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

        $guru->update($dataToUpdate);

        return response()->json([
            'success' => true,
            'message' => 'Data guru berhasil diperbarui',
            'data' => $guru
        ], 200);
    }

    public function destroy($nip)
    {
        $guru = Guru::find($nip);
        
        if (!$guru) {
            return response()->json([
                'success' => false,
                'message' => 'Data guru tidak ditemukan'
            ], 404);
        }

        $guru->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data guru berhasil dihapus'
        ], 200);
    }
}
