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

    public function pending(Request $request)
    {
        $guruNip = $request->user()->nip;
        $pendingList = KepalaSekolah::where('status', 'pending')->get();
        
        $data = $pendingList->map(function ($kepsek) use ($guruNip) {
            $approvals = \App\Models\KepsekApproval::where('nip_kepsek', $kepsek->nip)->get();
            return [
                'nip' => $kepsek->nip,
                'nama' => $kepsek->nama,
                'no_hp' => $kepsek->no_hp,
                'email' => $kepsek->email,
                'approvals_count' => $approvals->count(),
                'has_approved' => $approvals->where('nip_guru', $guruNip)->isNotEmpty()
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Daftar kepala sekolah pending',
            'data' => $data
        ], 200);
    }

    public function approve(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nip_kepsek' => 'required|string|exists:kepala_sekolah,nip'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $guruNip = $request->user()->nip;
        if (!$guruNip) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya guru yang dapat menyetujui'
            ], 403);
        }

        $nipKepsek = $request->nip_kepsek;
        $kepsek = KepalaSekolah::find($nipKepsek);

        if ($kepsek->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Akun kepala sekolah ini sudah disetujui'
            ], 400);
        }

        // Cek jika sudah approve
        $existing = \App\Models\KepsekApproval::where('nip_kepsek', $nipKepsek)
            ->where('nip_guru', $guruNip)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah menyetujui akun ini'
            ], 400);
        }

        \App\Models\KepsekApproval::create([
            'nip_kepsek' => $nipKepsek,
            'nip_guru' => $guruNip
        ]);

        $count = \App\Models\KepsekApproval::where('nip_kepsek', $nipKepsek)->count();
        if ($count >= 4) {
            $kepsek->update(['status' => 'approved']);
            return response()->json([
                'success' => true,
                'message' => 'Persetujuan berhasil. Akun Kepala Sekolah kini aktif.'
            ], 200);
        }

        return response()->json([
            'success' => true,
            'message' => 'Persetujuan berhasil ditambahkan. Total persetujuan: ' . $count
        ], 200);
    }
}
