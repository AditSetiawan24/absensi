import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
    required String role,
  }) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConstants.login,
      body: {
        'username': username,
        'password': password,
        'role': role,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final userData = response.data!['user'];
      final userRole = response.data!['role'];

      await _saveSession(token, userData, userRole);
      ApiService.setToken(token);
    }

    return response;
  }

  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String nama,
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String noHp,
    String? nip,
    String? gender,
    String? alamat,
    String? kodeSekolah,
    String? kodeKelas,
    String? nisAnak,
    String? namaAnak,
  }) async {
    final body = {
      'nama': nama,
      'email': email,
      'username': username,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
      'no_hp': noHp,
    };

    if (role == AppConstants.roleGuru || role == AppConstants.roleKepalaSekolah) {
      body['nip'] = nip!;
      if (role == AppConstants.roleGuru) {
        body['gender'] = gender!;
        body['kode_sekolah'] = kodeSekolah!;
        body['kode_kelas'] = kodeKelas!;
      }
    } else if (role == AppConstants.roleOrangTua) {
      body['alamat'] = alamat!;
      body['nis_anak'] = nisAnak!;
      body['nama_anak'] = namaAnak!;
    }

    return await ApiService.post<Map<String, dynamic>>(
      ApiConstants.register,
      body: body,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse> forgotPassword({
    required String email,
    required String role,
  }) async {
    return await ApiService.post(
      ApiConstants.forgotPassword,
      body: {
        'email': email,
        'role': role,
      },
    );
  }

  static Future<ApiResponse> resetPassword({
    required String email,
    required String role,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await ApiService.post(
      ApiConstants.resetPassword,
      body: {
        'email': email,
        'role': role,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  static Future<ApiResponse> changePassword({
    required String username,
    required String role,
    required String oldPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await ApiService.post(
      ApiConstants.changePassword,
      body: {
        'username': username,
        'role': role,
        'old_password': oldPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  static Future<void> logout() async {
    try {
      await ApiService.post(ApiConstants.logout);
    } catch (_) {}
    
    await _clearSession();
    ApiService.setToken(null);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);
    if (token != null) {
      ApiService.setToken(token);
      return true;
    }
    return false;
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.keyUserData);
    final role = prefs.getString(AppConstants.keyUserRole);
    
    if (userData != null && role != null) {
      return User.fromJson(jsonDecode(userData), role);
    }
    return null;
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserRole);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserId);
  }

  static Future<void> _saveSession(
    String token,
    Map<String, dynamic> userData,
    String role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyToken, token);
    await prefs.setString(AppConstants.keyUserData, jsonEncode(userData));
    await prefs.setString(AppConstants.keyUserRole, role);
    
    // Save user ID based on role
    if (role == AppConstants.roleOrangTua) {
      await prefs.setString(AppConstants.keyUserId, userData['id_ortu'].toString());
    } else {
      await prefs.setString(AppConstants.keyUserId, userData['nip']);
    }
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyUserId);
  }

  /// Lepas kelas yang diampu guru
  static Future<ApiResponse> releaseClass({
    required String nip,
  }) async {
    return await ApiService.post(
      '/guru/release-class',
      body: {
        'nip': nip,
      },
    );
  }

  /// Pindah ke kelas lain
  static Future<ApiResponse> changeClass({
    required String nip,
    required String kodeKelas,
  }) async {
    return await ApiService.post(
      '/guru/change-class',
      body: {
        'nip': nip,
        'kode_kelas': kodeKelas,
      },
    );
  }

  /// Get info kelas guru
  static Future<ApiResponse<Map<String, dynamic>>> getGuruClass({
    required String nip,
  }) async {
    return await ApiService.get<Map<String, dynamic>>(
      '/guru/my-class?nip=$nip',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
