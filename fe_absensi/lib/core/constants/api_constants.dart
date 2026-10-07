class ApiConstants {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String logout = '/logout';
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  
  // Guru
  static const String guru = '/guru';
  
  // Kepala Sekolah
  static const String kepalaSekolah = '/kepala-sekolah';
  
  // Orang Tua
  static const String orangTua = '/orang-tua';
  
  // Siswa
  static const String siswa = '/siswa';
  static const String siswaSearch = '/siswa/search';
  static const String siswaByKelas = '/siswa/by-kelas';
  
  // Kelas
  static const String kelas = '/kelas';
  static const String kelasByGuru = '/kelas/by-guru';
  
  // Absensi
  static const String absensi = '/absensi';
  static const String absensiToday = '/absensi/today';
  static const String absensiByDate = '/absensi/by-date';
  static const String absensiBySiswa = '/absensi/by-siswa';
  static const String absensiByKelas = '/absensi/by-kelas';
  static const String absensiWeekly = '/absensi/weekly-stats';
  static const String absensiStatistics = '/absensi/statistics';
  static const String absensiConsecutive = '/absensi/consecutive-absent';
  static const String absensiBulk = '/absensi/bulk';
  
  // Laporan
  static const String laporan = '/laporan';
  static const String laporanGenerate = '/laporan/generate';
  static const String laporanDownloadPdf = '/laporan/download/pdf';
  static const String laporanDownloadExcel = '/laporan/download/excel';
  
  // Rekap Bulanan
  static const String rekapBulanan = '/rekap-bulanan';
  
  // Dashboard
  static const String dashboardGuru = '/dashboard/guru';
  static const String dashboardKepalaSekolah = '/dashboard/kepala-sekolah';
  static const String dashboardOrangTua = '/dashboard/orang-tua';
  static const String dashboardStatistics = '/dashboard/statistics';
  static const String dashboardClassComparison = '/dashboard/class-comparison';
  static const String dashboardSemesterComparison = '/dashboard/semester-comparison';
}
