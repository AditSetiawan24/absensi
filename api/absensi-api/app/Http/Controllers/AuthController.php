<?php

namespace App\Http\Controllers;

use App\Models\Guru;
use App\Models\KepalaSekolah;
use App\Models\OrangTua;
use App\Models\Siswa;
use App\Models\Kelas;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Register user baru
     * Bisa untuk guru, kepala_sekolah, atau orang_tua
     */
    // Kode sekolah untuk validasi pendaftaran guru
    private const KODE_SEKOLAH = 'SDN1KK';
    
    // Mapping kode kelas ke id_kelas
    private const KODE_KELAS = [
        'KLS1' => 1,
        'KLS2' => 2,
        'KLS3' => 3,
        'KLS4' => 4,
        'KLS5' => 5,
        'KLS6' => 6,
    ];

    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'role' => 'required|in:guru,kepala_sekolah,orang_tua',
            'nama' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'username' => 'required|string|max:255',
            'password' => 'required|string|min:6|confirmed',
            'no_hp' => 'required|string|max:255',
            
            // Field khusus guru
            'nip' => 'required_if:role,guru,kepala_sekolah|string|max:255',
            'gender' => 'required_if:role,guru|in:Laki - Laki,Perempuan',
            'kode_sekolah' => 'required_if:role,guru|string',
            
            // Field khusus orang tua
            'alamat' => 'required_if:role,orang_tua|string',
            'nis_anak' => 'required_if:role,orang_tua|string',
            'nama_anak' => 'required_if:role,orang_tua|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $user = null;

            switch ($request->role) {
                case 'guru':
                    // Validasi kode sekolah
                    if ($request->kode_sekolah !== self::KODE_SEKOLAH) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Kode sekolah tidak valid'
                        ], 422);
                    }

                    // Validasi kode kelas
                    $kodeKelas = strtoupper($request->kode_kelas ?? '');
                    if (!array_key_exists($kodeKelas, self::KODE_KELAS)) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Kode kelas tidak valid. Hubungi admin untuk mendapatkan kode kelas yang benar.'
                        ], 422);
                    }
                    
                    $idKelas = self::KODE_KELAS[$kodeKelas];
                    
                    // Cek apakah kelas sudah diambil guru lain
                    $kelas = Kelas::find($idKelas);
                    if ($kelas && $kelas->nip) {
                        $guruLain = Guru::find($kelas->nip);
                        $namaGuru = $guruLain ? $guruLain->nama : 'guru lain';
                        return response()->json([
                            'success' => false,
                            'message' => "Kelas ini sudah diampu oleh {$namaGuru}. Silakan berkoordinasi dengan guru tersebut atau hubungi admin."
                        ], 422);
                    }

                    // Cek apakah NIP sudah ada
                    if (Guru::where('nip', $request->nip)->exists()) {
                        return response()->json([
                            'success' => false,
                            'message' => 'NIP sudah terdaftar'
                        ], 422);
                    }

                    // Cek apakah username sudah ada
                    if (Guru::where('username', $request->username)->exists()) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Username sudah digunakan'
                        ], 422);
                    }

                    $user = Guru::create([
                        'nip' => $request->nip,
                        'nama' => $request->nama,
                        'gender' => $request->gender,
                        'no_hp' => $request->no_hp,
                        'email' => $request->email,
                        'username' => $request->username,
                        'password' => Hash::make($request->password)
                    ]);
                    
                    // Update kelas dengan NIP guru baru
                    if ($kelas) {
                        $kelas->update(['nip' => $user->nip]);
                    }
                    break;

                case 'kepala_sekolah':
                    // Cek apakah NIP sudah ada
                    if (KepalaSekolah::where('nip', $request->nip)->exists()) {
                        return response()->json([
                            'success' => false,
                            'message' => 'NIP sudah terdaftar'
                        ], 422);
                    }

                    // Cek apakah username sudah ada
                    if (KepalaSekolah::where('username', $request->username)->exists()) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Username sudah digunakan'
                        ], 422);
                    }

                    $user = KepalaSekolah::create([
                        'nip' => $request->nip,
                        'nama' => $request->nama,
                        'no_hp' => $request->no_hp,
                        'email' => $request->email,
                        'username' => $request->username,
                        'password' => Hash::make($request->password)
                    ]);
                    break;

                case 'orang_tua':
                    // Verifikasi NIS dan nama anak
                    $siswa = Siswa::where('nis', $request->nis_anak)->first();
                    
                    if (!$siswa) {
                        return response()->json([
                            'success' => false,
                            'message' => 'NIS siswa tidak ditemukan dalam database'
                        ], 422);
                    }

                    // Cek kecocokan nama (case-insensitive, trim spasi)
                    $namaAnakInput = strtolower(trim($request->nama_anak));
                    $namaAnakDb = strtolower(trim($siswa->nama));
                    
                    if ($namaAnakInput !== $namaAnakDb) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Nama siswa tidak cocok dengan NIS yang dimasukkan'
                        ], 422);
                    }

                    // Cek apakah siswa sudah memiliki orang tua
                    if ($siswa->id_ortu) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Siswa ini sudah terdaftar dengan akun orang tua lain'
                        ], 422);
                    }

                    // Cek apakah username sudah ada
                    if (OrangTua::where('username', $request->username)->exists()) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Username sudah digunakan'
                        ], 422);
                    }

                    $user = OrangTua::create([
                        'nama' => $request->nama,
                        'email' => $request->email,
                        'no_hp' => $request->no_hp,
                        'alamat' => $request->alamat,
                        'username' => $request->username,
                        'password' => Hash::make($request->password)
                    ]);

                    // Update siswa dengan id_ortu
                    $siswa->update(['id_ortu' => $user->id_ortu]);
                    break;
            }

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil',
                'data' => [
                    'user' => $user,
                    'role' => $request->role
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Registrasi gagal',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Login untuk semua tipe user
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string',
            'password' => 'required|string',
            'role' => 'required|in:guru,kepala_sekolah,orang_tua'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = null;
        $model = null;

        // Cari user berdasarkan role
        switch ($request->role) {
            case 'guru':
                $user = Guru::where('username', $request->username)->first();
                $model = 'Guru';
                break;

            case 'kepala_sekolah':
                $user = KepalaSekolah::where('username', $request->username)->first();
                $model = 'KepalaSekolah';
                break;

            case 'orang_tua':
                $user = OrangTua::where('username', $request->username)->first();
                $model = 'OrangTua';
                break;
        }

        // Cek apakah user ditemukan dan password cocok
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Username atau password salah'
            ], 401);
        }

        // Generate token menggunakan Sanctum
        $token = $user->createToken('auth_token', [$request->role])->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => $user,
                'role' => $request->role,
                'token' => $token,
                'token_type' => 'Bearer'
            ]
        ], 200);
    }

    /**
     * Logout
     */
    public function logout(Request $request)
    {
        // Hapus token yang sedang digunakan
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ], 200);
    }

    /**
     * Get user profile yang sedang login
     */
    public function profile(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Data profil berhasil diambil',
            'data' => $request->user()
        ], 200);
    }

    /**
     * Forgot password - generate reset token
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'role' => 'required|in:guru,kepala_sekolah,orang_tua'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = null;
        switch ($request->role) {
            case 'guru':
                $user = Guru::where('email', $request->email)->first();
                break;
            case 'kepala_sekolah':
                $user = KepalaSekolah::where('email', $request->email)->first();
                break;
            case 'orang_tua':
                $user = OrangTua::where('email', $request->email)->first();
                break;
        }

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak ditemukan'
            ], 404);
        }

        // Generate a simple reset token (in production, use proper token storage)
        $resetToken = bin2hex(random_bytes(32));

        return response()->json([
            'success' => true,
            'message' => 'Token reset password berhasil dibuat',
            'data' => [
                'email' => $request->email,
                'reset_token' => $resetToken,
                'expires_in' => '60 minutes'
            ]
        ], 200);
    }

    /**
     * Reset password with token
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'role' => 'required|in:guru,kepala_sekolah,orang_tua',
            'password' => 'required|string|min:6|confirmed'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = null;
        switch ($request->role) {
            case 'guru':
                $user = Guru::where('email', $request->email)->first();
                break;
            case 'kepala_sekolah':
                $user = KepalaSekolah::where('email', $request->email)->first();
                break;
            case 'orang_tua':
                $user = OrangTua::where('email', $request->email)->first();
                break;
        }

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak ditemukan'
            ], 404);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil direset'
        ], 200);
    }

    /**
     * Change password for authenticated user
     */
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string',
            'role' => 'required|in:guru,kepala_sekolah,orang_tua',
            'old_password' => 'required|string',
            'password' => 'required|string|min:6|confirmed'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = null;
        switch ($request->role) {
            case 'guru':
                $user = Guru::where('username', $request->username)->first();
                break;
            case 'kepala_sekolah':
                $user = KepalaSekolah::where('username', $request->username)->first();
                break;
            case 'orang_tua':
                $user = OrangTua::where('username', $request->username)->first();
                break;
        }

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        if (!Hash::check($request->old_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama tidak sesuai'
            ], 401);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah'
        ], 200);
    }

    /**
     * Update profile
     */
    public function updateProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string',
            'role' => 'required|in:guru,kepala_sekolah,orang_tua',
            'nama' => 'string|max:255',
            'email' => 'email|max:255',
            'no_hp' => 'string|max:255'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = null;
        switch ($request->role) {
            case 'guru':
                $user = Guru::where('username', $request->username)->first();
                break;
            case 'kepala_sekolah':
                $user = KepalaSekolah::where('username', $request->username)->first();
                break;
            case 'orang_tua':
                $user = OrangTua::where('username', $request->username)->first();
                break;
        }

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        $user->update($request->only(['nama', 'email', 'no_hp']));

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data' => $user
        ], 200);
    }

    /**
     * Lepas kelas (guru melepaskan kelas yang diampu)
     */
    public function releaseClass(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nip' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $guru = Guru::find($request->nip);
            if (!$guru) {
                return response()->json([
                    'success' => false,
                    'message' => 'Guru tidak ditemukan'
                ], 404);
            }

            // Cari kelas yang diampu guru ini
            $kelas = Kelas::where('nip', $request->nip)->first();
            if (!$kelas) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak sedang mengampu kelas manapun'
                ], 422);
            }

            $namaKelas = 'Kelas ' . $kelas->kelas;
            
            // Lepaskan kelas
            $kelas->update(['nip' => null]);

            return response()->json([
                'success' => true,
                'message' => "Berhasil melepaskan {$namaKelas}"
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Pindah kelas (guru pindah ke kelas lain)
     */
    public function changeClass(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nip' => 'required|string',
            'kode_kelas' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $guru = Guru::find($request->nip);
            if (!$guru) {
                return response()->json([
                    'success' => false,
                    'message' => 'Guru tidak ditemukan'
                ], 404);
            }

            // Validasi kode kelas
            $kodeKelas = strtoupper($request->kode_kelas);
            if (!array_key_exists($kodeKelas, self::KODE_KELAS)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kode kelas tidak valid. Gunakan format KLS1-KLS6.'
                ], 422);
            }

            $idKelas = self::KODE_KELAS[$kodeKelas];

            // Cek apakah kelas sudah diambil guru lain
            $kelasBaru = Kelas::find($idKelas);
            if (!$kelasBaru) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kelas tidak ditemukan'
                ], 404);
            }

            if ($kelasBaru->nip && $kelasBaru->nip !== $request->nip) {
                $guruLain = Guru::find($kelasBaru->nip);
                $namaGuru = $guruLain ? $guruLain->nama : 'guru lain';
                return response()->json([
                    'success' => false,
                    'message' => "Kelas ini sudah diampu oleh {$namaGuru}. Silakan berkoordinasi dengan guru tersebut atau hubungi admin."
                ], 422);
            }

            // Lepaskan kelas lama jika ada
            $kelasLama = Kelas::where('nip', $request->nip)->first();
            if ($kelasLama && $kelasLama->id_kelas !== $idKelas) {
                $kelasLama->update(['nip' => null]);
            }

            // Assign ke kelas baru
            $kelasBaru->update(['nip' => $request->nip]);

            return response()->json([
                'success' => true,
                'message' => "Berhasil pindah ke Kelas {$kelasBaru->kelas}",
                'data' => [
                    'kelas' => $kelasBaru
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get kelas info untuk guru
     */
    public function getGuruClass(Request $request)
    {
        $nip = $request->query('nip');
        
        if (!$nip) {
            return response()->json([
                'success' => false,
                'message' => 'NIP diperlukan'
            ], 422);
        }

        $kelas = Kelas::where('nip', $nip)->first();
        
        return response()->json([
            'success' => true,
            'data' => [
                'kelas' => $kelas ? [
                    'id_kelas' => $kelas->id_kelas,
                    'kelas' => $kelas->kelas,
                    'nama_kelas' => 'Kelas ' . $kelas->kelas,
                    'tahun_ajar' => $kelas->tahun_ajar,
                    'nip' => $kelas->nip,
                ] : null,
                'has_class' => $kelas !== null
            ]
        ], 200);
    }
}
