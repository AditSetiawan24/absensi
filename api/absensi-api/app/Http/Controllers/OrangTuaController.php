<?php

namespace App\Http\Controllers;

use App\Models\OrangTua;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class OrangTuaController extends Controller
{
    public function index()
    {
        $orangTua = OrangTua::with('siswa')->get();
        return response()->json([
            'success' => true,
            'message' => 'Data orang tua berhasil diambil',
            'data' => $orangTua
        ], 200);
    }

    public function show($id)
    {
        $orangTua = OrangTua::with('siswa')->find($id);
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Data orang tua tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data orang tua berhasil diambil',
            'data' => $orangTua
        ], 200);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'no_hp' => 'required|string|max:255',
            'alamat' => 'required|string',
            'username' => 'required|string|max:255|unique:orang_tua,username',
            'password' => 'required|string|min:6'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $orangTua = OrangTua::create([
            'nama' => $request->nama,
            'email' => $request->email,
            'no_hp' => $request->no_hp,
            'alamat' => $request->alamat,
            'username' => $request->username,
            'password' => Hash::make($request->password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data orang tua berhasil ditambahkan',
            'data' => $orangTua
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $orangTua = OrangTua::find($id);
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Data orang tua tidak ditemukan'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'nama' => 'string|max:255',
            'email' => 'email|max:255',
            'no_hp' => 'string|max:255',
            'alamat' => 'string',
            'username' => 'string|max:255|unique:orang_tua,username,' . $id . ',id_ortu',
            'password' => 'string|min:6'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $dataToUpdate = $request->except('password');
        
        if ($request->has('password')) {
            $dataToUpdate['password'] = Hash::make($request->password);
        }

        $orangTua->update($dataToUpdate);

        return response()->json([
            'success' => true,
            'message' => 'Data orang tua berhasil diperbarui',
            'data' => $orangTua
        ], 200);
    }

    public function destroy($id)
    {
        $orangTua = OrangTua::find($id);
        
        if (!$orangTua) {
            return response()->json([
                'success' => false,
                'message' => 'Data orang tua tidak ditemukan'
            ], 404);
        }

        $orangTua->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data orang tua berhasil dihapus'
        ], 200);
    }
}
