class Absensi {
  final int? idAbsensi;
  final String nis;
  final String nip;
  final String tanggal;
  final String statusKehadiran;
  final String? keterangan;
  final String? fileSurat;
  final String? namaSiswa;
  final String? namaGuru;
  final SiswaAbsensi? siswaData;

  Absensi({
    this.idAbsensi,
    required this.nis,
    required this.nip,
    required this.tanggal,
    required this.statusKehadiran,
    this.keterangan,
    this.fileSurat,
    this.namaSiswa,
    this.namaGuru,
    this.siswaData,
  });

  // Alias for statusKehadiran
  String get status => statusKehadiran;
  
  // Alias for siswaData
  SiswaAbsensi? get siswa => siswaData;

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      idAbsensi: json['id_absensi'],
      nis: json['nis'] ?? '',
      nip: json['nip'] ?? '',
      tanggal: json['tanggal'] ?? '',
      statusKehadiran: json['status_kehadiran'] ?? '',
      keterangan: json['keterangan'],
      fileSurat: json['file_surat'],
      namaSiswa: json['nama_siswa'],
      namaGuru: json['nama_guru'],
      siswaData: json['siswa'] != null ? SiswaAbsensi.fromJson(json['siswa']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nis': nis,
      'nip': nip,
      'tanggal': tanggal,
      'status_kehadiran': statusKehadiran,
      'keterangan': keterangan,
    };
  }
}

class SiswaAbsensi {
  final String nis;
  final String nama;
  final String? kelas;

  SiswaAbsensi({
    required this.nis,
    required this.nama,
    this.kelas,
  });

  factory SiswaAbsensi.fromJson(Map<String, dynamic> json) {
    return SiswaAbsensi(
      nis: json['nis'] ?? '',
      nama: json['nama'] ?? '',
      kelas: json['kelas'],
    );
  }
}

class TodayStats {
  final int totalSiswa;
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;
  final int belumAbsen;
  final double persentaseHadir;

  TodayStats({
    required this.totalSiswa,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
    required this.belumAbsen,
    required this.persentaseHadir,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      totalSiswa: json['total_siswa'] ?? 0,
      hadir: json['hadir'] ?? 0,
      izin: json['izin'] ?? 0,
      sakit: json['sakit'] ?? 0,
      alfa: json['alfa'] ?? 0,
      belumAbsen: json['belum_absen'] ?? 0,
      persentaseHadir: (json['persentase_hadir'] ?? 0).toDouble(),
    );
  }
}

class WeeklyStats {
  final String tanggal;
  final String hari;
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;
  final int total;
  final double? persentaseHadir;

  WeeklyStats({
    required this.tanggal,
    required this.hari,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
    required this.total,
    this.persentaseHadir,
  });

  // Alias for tanggal
  String get date => tanggal;

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      tanggal: json['tanggal'] ?? '',
      hari: json['hari'] ?? '',
      hadir: json['hadir'] ?? 0,
      izin: json['izin'] ?? 0,
      sakit: json['sakit'] ?? 0,
      alfa: json['alfa'] ?? 0,
      total: json['total'] ?? 0,
      persentaseHadir: json['persentase_hadir']?.toDouble(),
    );
  }
}

class AbsentStudent {
  final String nis;
  final String nama;
  final String status;
  final String? keterangan;

  AbsentStudent({
    required this.nis,
    required this.nama,
    required this.status,
    this.keterangan,
  });

  factory AbsentStudent.fromJson(Map<String, dynamic> json) {
    return AbsentStudent(
      nis: json['nis'] ?? '',
      nama: json['nama'] ?? '',
      status: json['status'] ?? '',
      keterangan: json['keterangan'],
    );
  }
}

class ConsecutiveAbsent {
  final String nis;
  final String namaSiswa;
  final String? kelas;
  final String? namaOrangTua;
  final String? noHpOrangTua;
  final int consecutiveDays;
  final String? lastAbsentDate;
  final String? statusTerakhir;
  final String? keterangan;

  ConsecutiveAbsent({
    required this.nis,
    required this.namaSiswa,
    this.kelas,
    this.namaOrangTua,
    this.noHpOrangTua,
    required this.consecutiveDays,
    this.lastAbsentDate,
    this.statusTerakhir,
    this.keterangan,
  });

  factory ConsecutiveAbsent.fromJson(Map<String, dynamic> json) {
    return ConsecutiveAbsent(
      nis: json['nis'] ?? '',
      namaSiswa: json['nama_siswa'] ?? '',
      kelas: json['kelas'],
      namaOrangTua: json['nama_orang_tua'],
      noHpOrangTua: json['no_hp_orang_tua'],
      consecutiveDays: json['consecutive_days'] ?? 0,
      lastAbsentDate: json['last_absent_date'],
      statusTerakhir: json['status_terakhir'],
      keterangan: json['keterangan'],
    );
  }
}
