import 'absensi_model.dart';
import 'siswa_model.dart';

class GuruDashboard {
  final Guru guru;
  final Kelas? kelas;
  final TodayStats? todayStats;
  final List<AbsentStudent> absentToday;
  final List<WeeklyStats> weeklyStats;
  final List<ConsecutiveAbsent> consecutiveAbsent;

  GuruDashboard({
    required this.guru,
    this.kelas,
    this.todayStats,
    required this.absentToday,
    required this.weeklyStats,
    required this.consecutiveAbsent,
  });

  // Alias for absentToday
  List<AbsentStudent> get absentStudents => absentToday;

  factory GuruDashboard.fromJson(Map<String, dynamic> json) {
    return GuruDashboard(
      guru: Guru.fromJson(json['guru'] ?? {}),
      kelas: json['kelas'] != null ? Kelas.fromJson(json['kelas']) : null,
      todayStats: json['today_stats'] != null 
          ? TodayStats.fromJson(json['today_stats']) 
          : null,
      absentToday: (json['absent_today'] as List?)
          ?.map((e) => AbsentStudent.fromJson(e))
          .toList() ?? [],
      weeklyStats: (json['weekly_stats'] as List?)
          ?.map((e) => WeeklyStats.fromJson(e))
          .toList() ?? [],
      consecutiveAbsent: (json['consecutive_absent'] as List?)
          ?.map((e) => ConsecutiveAbsent.fromJson(e))
          .toList() ?? [],
    );
  }
}

class KepalaSekolahDashboard {
  final String namaSekolah;
  final int totalKelas;
  final int totalGuru;
  final int totalSiswa;
  final String tahunAjar;
  final int semester;
  final List<ClassStats> classStats;
  final TodayStats? todayStatistics;
  final ComparisonData? comparisonData;

  KepalaSekolahDashboard({
    required this.namaSekolah,
    required this.totalKelas,
    required this.totalGuru,
    required this.totalSiswa,
    required this.tahunAjar,
    required this.semester,
    required this.classStats,
    this.todayStatistics,
    this.comparisonData,
  });

  // Aliases
  List<ClassStats> get kelasStats => classStats;
  TodayStats? get todayStats => todayStatistics;
  ComparisonData? get comparison => comparisonData;

  factory KepalaSekolahDashboard.fromJson(Map<String, dynamic> json) {
    return KepalaSekolahDashboard(
      namaSekolah: json['nama_sekolah']?.toString() ?? '',
      totalKelas: _parseToInt(json['total_kelas']),
      totalGuru: _parseToInt(json['total_guru']),
      totalSiswa: _parseToInt(json['total_siswa']),
      tahunAjar: json['tahun_ajar']?.toString() ?? '',
      semester: _parseToInt(json['semester'], defaultValue: 1),
      classStats: (json['class_stats'] as List?)
          ?.map((e) => ClassStats.fromJson(e))
          .toList() ?? [],
      todayStatistics: json['today_stats'] != null 
          ? TodayStats.fromJson(json['today_stats']) 
          : null,
      comparisonData: json['comparison'] != null 
          ? ComparisonData.fromJson(json['comparison']) 
          : null,
    );
  }
}

// Helper function to safely parse int from dynamic value
int _parseToInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

// Helper function to safely parse double from dynamic value
double _parseToDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class ComparisonData {
  final double currentSemester;
  final double previousSemester;
  final double improvement;

  ComparisonData({
    required this.currentSemester,
    required this.previousSemester,
    required this.improvement,
  });

  factory ComparisonData.fromJson(Map<String, dynamic> json) {
    return ComparisonData(
      currentSemester: _parseToDouble(json['current_semester']),
      previousSemester: _parseToDouble(json['previous_semester']),
      improvement: _parseToDouble(json['improvement']),
    );
  }
}

// Alias for ClassStats
typedef KelasStats = ClassStats;

class ClassStats {
  final int idKelas;
  final String kelas;
  final String? guru;
  final String? nip;
  final int jumlahSiswa;
  final int totalAbsensi;
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;
  final double persentaseHadir;

  ClassStats({
    required this.idKelas,
    required this.kelas,
    this.guru,
    this.nip,
    required this.jumlahSiswa,
    required this.totalAbsensi,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
    required this.persentaseHadir,
  });

  factory ClassStats.fromJson(Map<String, dynamic> json) {
    return ClassStats(
      idKelas: _parseToInt(json['id_kelas']),
      kelas: json['kelas']?.toString() ?? '',
      guru: json['guru']?.toString(),
      nip: json['nip']?.toString(),
      jumlahSiswa: _parseToInt(json['jumlah_siswa']),
      totalAbsensi: _parseToInt(json['total_absensi']),
      hadir: _parseToInt(json['hadir']),
      izin: _parseToInt(json['izin']),
      sakit: _parseToInt(json['sakit']),
      alfa: _parseToInt(json['alfa']),
      persentaseHadir: _parseToDouble(json['persentase_hadir']),
    );
  }
}


class OrangTuaDashboard {
  final OrangTuaInfo orangTua;
  final List<SiswaAbsensiData> siswa;

  OrangTuaDashboard({
    required this.orangTua,
    required this.siswa,
  });

  // Alias for siswa
  List<SiswaAbsensiData> get siswaList => siswa;

  factory OrangTuaDashboard.fromJson(Map<String, dynamic> json) {
    return OrangTuaDashboard(
      orangTua: OrangTuaInfo.fromJson(json['orang_tua'] ?? {}),
      siswa: (json['siswa'] as List?)
          ?.map((e) => SiswaAbsensiData.fromJson(e))
          .toList() ?? [],
    );
  }
}

class OrangTuaInfo {
  final int idOrtu;
  final String nama;
  final String email;
  final String noHp;

  OrangTuaInfo({
    required this.idOrtu,
    required this.nama,
    required this.email,
    required this.noHp,
  });

  factory OrangTuaInfo.fromJson(Map<String, dynamic> json) {
    return OrangTuaInfo(
      idOrtu: json['id_ortu'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noHp: json['no_hp'] ?? '',
    );
  }
}

class SiswaAbsensiData {
  final String nis;
  final String nama;
  final String? kelas;
  final SiswaStatistics statistics;
  final List<CalendarData> calendar;
  final List<AbsentHistory> absentHistory;

  SiswaAbsensiData({
    required this.nis,
    required this.nama,
    this.kelas,
    required this.statistics,
    required this.calendar,
    required this.absentHistory,
  });

  // Alias for persentaseHadir from statistics
  double get persentaseHadir => statistics.persentaseHadir;

  factory SiswaAbsensiData.fromJson(Map<String, dynamic> json) {
    return SiswaAbsensiData(
      nis: json['nis'] ?? '',
      nama: json['nama'] ?? '',
      kelas: json['kelas'],
      statistics: SiswaStatistics.fromJson(json['statistics'] ?? {}),
      calendar: (json['calendar'] as List?)
          ?.map((e) => CalendarData.fromJson(e))
          .toList() ?? [],
      absentHistory: (json['absent_history'] as List?)
          ?.map((e) => AbsentHistory.fromJson(e))
          .toList() ?? [],
    );
  }
}

class SiswaStatistics {
  final int totalHari;
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;
  final double persentaseHadir;

  SiswaStatistics({
    required this.totalHari,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
    required this.persentaseHadir,
  });

  factory SiswaStatistics.fromJson(Map<String, dynamic> json) {
    return SiswaStatistics(
      totalHari: json['total_hari'] ?? 0,
      hadir: json['hadir'] ?? 0,
      izin: json['izin'] ?? 0,
      sakit: json['sakit'] ?? 0,
      alfa: json['alfa'] ?? 0,
      persentaseHadir: (json['persentase_hadir'] ?? 0).toDouble(),
    );
  }
}

class CalendarData {
  final String tanggal;
  final String? status;
  final String? keterangan;

  // Alias for tanggal
  String get date => tanggal;

  CalendarData({
    required this.tanggal,
    this.status,
    this.keterangan,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    return CalendarData(
      tanggal: json['tanggal'] ?? '',
      status: json['status'],
      keterangan: json['keterangan'],
    );
  }
}

class AbsentHistory {
  final String tanggal;
  final String status;
  final String? keterangan;

  AbsentHistory({
    required this.tanggal,
    required this.status,
    this.keterangan,
  });

  factory AbsentHistory.fromJson(Map<String, dynamic> json) {
    return AbsentHistory(
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? '',
      keterangan: json['keterangan'],
    );
  }
}
