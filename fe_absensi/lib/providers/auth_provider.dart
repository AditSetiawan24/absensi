import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _role;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuth() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      _user = await AuthService.getCurrentUser();
      _role = await AuthService.getUserRole();
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    await checkAuth();
  }

  Future<bool> login({
    required String username,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(
        username: username,
        password: password,
        role: role,
      );

      _isLoading = false;

      if (response.success && response.data != null) {
        _user = User.fromJson(response.data!['user'], role);
        _role = role;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.register(
        nama: nama,
        email: email,
        username: username,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        noHp: noHp,
        nip: nip,
        gender: gender,
        alamat: alamat,
        kodeSekolah: kodeSekolah,
        kodeKelas: kodeKelas,
        nisAnak: nisAnak,
        namaAnak: namaAnak,
      );

      _isLoading = false;

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _role = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
