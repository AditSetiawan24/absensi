class AppConstants {
  static const String appName = 'Absensi SD';
  static const String schoolName = 'SD Negeri Kemutung Kidul';
  static const String appVersion = '1.0.0';
  
  // Roles
  static const String roleGuru = 'guru';
  static const String roleKepalaSekolah = 'kepala_sekolah';
  static const String roleOrangTua = 'orang_tua';
  
  // Attendance Status
  static const String statusHadir = 'hadir';
  static const String statusIzin = 'izin';
  static const String statusSakit = 'sakit';
  static const String statusAlfa = 'alfa';
  
  // Shared Preferences Keys
  static const String keyToken = 'token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserData = 'user_data';
  static const String keyDarkMode = 'dark_mode';
  static const String keyNotification = 'notification';
  
  // Kelas Options
  static const List<String> kelasOptions = ['1', '2', '3', '4', '5', '6'];
  
  // Gender Options
  static const List<String> genderOptions = ['Laki - Laki', 'Perempuan'];
  
  // Semester Options
  static const List<String> semesterOptions = ['1', '2'];
  static const List<String> semesterNames = ['Ganjil', 'Genap'];
}
