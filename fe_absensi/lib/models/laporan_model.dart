class Laporan {
  final int? idLaporan;
  final int idKelas;
  final String nip;
  final int totalHadir;
  final int totalSakit;
  final int totalIzin;
  final int totalAlfa;
  final String periodeAwal;
  final String periodeAkhir;
  final bool isSubmitted;
  final String? submittedAt;
  final String? tipe; // 'semester' atau 'bulanan'
  final int? bulan;
  final int? tahun;
  final LaporanKelas? kelas;
  final LaporanGuru? guru;
  final LaporanSiswa? siswa;

  Laporan({
    this.idLaporan,
    required this.idKelas,
    required this.nip,
    required this.totalHadir,
    required this.totalSakit,
    required this.totalIzin,
    required this.totalAlfa,
    required this.periodeAwal,
    required this.periodeAkhir,
    this.isSubmitted = false,
    this.submittedAt,
    this.tipe,
    this.bulan,
    this.tahun,
    this.kelas,
    this.guru,
    this.siswa,
  });

  factory Laporan.fromJson(Map<String, dynamic> json) {
    return Laporan(
      idLaporan: json['id_laporan'],
      idKelas: json['id_kelas'] ?? 0,
      nip: json['nip'] ?? '',
      totalHadir: json['total_hadir'] ?? 0,
      totalSakit: json['total_sakit'] ?? 0,
      totalIzin: json['total_izin'] ?? 0,
      totalAlfa: json['total_alfa'] ?? 0,
      periodeAwal: json['periode_awal'] ?? '',
      periodeAkhir: json['periode_akhir'] ?? '',
      isSubmitted: json['is_submitted'] == true || json['is_submitted'] == 1,
      submittedAt: json['submitted_at'],
      tipe: json['tipe'],
      bulan: json['bulan'],
      tahun: json['tahun'],
      kelas: json['kelas'] != null ? LaporanKelas.fromJson(json['kelas']) : null,
      guru: json['guru'] != null ? LaporanGuru.fromJson(json['guru']) : null,
      siswa: json['siswa'] != null ? LaporanSiswa.fromJson(json['siswa']) : null,
    );
  }

  int get totalAbsensi => totalHadir + totalSakit + totalIzin + totalAlfa;
  
  double get persentaseHadir => 
      totalAbsensi > 0 ? (totalHadir / totalAbsensi) * 100 : 0;

  // Aliases for compatibility
  int get hadir => totalHadir;
  int get izin => totalIzin;
  int get sakit => totalSakit;
  int get alfa => totalAlfa;
  
  // Nama bulan untuk rekap bulanan
  String get namaBulan {
    if (bulan == null) return '';
    const bulanNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanNames[bulan!];
  }
  
  // Hitung tahun ajaran dari periode
  String? get tahunAjar => _getTahunAjarFromPeriode();
  
  String? _getTahunAjarFromPeriode() {
    try {
      if (periodeAwal.isEmpty) return kelas?.tahunAjar;
      
      final parts = periodeAwal.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      
      // Jika bulan Juli-Desember, tahun ajaran adalah year/year+1
      // Jika bulan Januari-Juni, tahun ajaran adalah year-1/year
      if (month >= 7) {
        return '$year/${year + 1}';
      } else {
        return '${year - 1}/$year';
      }
    } catch (e) {
      return kelas?.tahunAjar;
    }
  }
  
  String get semester => _getSemesterFromPeriode();
  
  String _getSemesterFromPeriode() {
    try {
      final startMonth = int.parse(periodeAwal.split('-')[1]);
      return startMonth >= 7 ? 'Semester Ganjil' : 'Semester Genap';
    } catch (e) {
      return 'Semester Ganjil';
    }
  }
}

class LaporanSiswa {
  final String nis;
  final String nama;

  LaporanSiswa({
    required this.nis,
    required this.nama,
  });

  factory LaporanSiswa.fromJson(Map<String, dynamic> json) {
    return LaporanSiswa(
      nis: json['nis'] ?? '',
      nama: json['nama'] ?? '',
    );
  }
}

class LaporanKelas {
  final int idKelas;
  final String kelas;
  final String tahunAjar;

  LaporanKelas({
    required this.idKelas,
    required this.kelas,
    required this.tahunAjar,
  });

  factory LaporanKelas.fromJson(Map<String, dynamic> json) {
    return LaporanKelas(
      idKelas: json['id_kelas'] ?? 0,
      kelas: json['kelas'] ?? '',
      tahunAjar: json['tahun_ajar'] ?? '',
    );
  }
}

class LaporanGuru {
  final String nip;
  final String nama;

  LaporanGuru({
    required this.nip,
    required this.nama,
  });

  factory LaporanGuru.fromJson(Map<String, dynamic> json) {
    return LaporanGuru(
      nip: json['nip'] ?? '',
      nama: json['nama'] ?? '',
    );
  }
}

class LaporanGenerated {
  final String namaSekolah;
  final String tahunAjar;
  final int semester;
  final LaporanPeriode periode;
  final LaporanRingkasan ringkasan;
  final List<LaporanDetailKelas> detailKelas;

  LaporanGenerated({
    required this.namaSekolah,
    required this.tahunAjar,
    required this.semester,
    required this.periode,
    required this.ringkasan,
    required this.detailKelas,
  });

  factory LaporanGenerated.fromJson(Map<String, dynamic> json) {
    return LaporanGenerated(
      namaSekolah: json['nama_sekolah'] ?? '',
      tahunAjar: json['tahun_ajar'] ?? '',
      semester: json['semester'] ?? 1,
      periode: LaporanPeriode.fromJson(json['periode'] ?? {}),
      ringkasan: LaporanRingkasan.fromJson(json['ringkasan'] ?? {}),
      detailKelas: (json['detail_kelas'] as List?)
          ?.map((e) => LaporanDetailKelas.fromJson(e))
          .toList() ?? [],
    );
  }
}

class LaporanPeriode {
  final String start;
  final String end;

  LaporanPeriode({required this.start, required this.end});

  factory LaporanPeriode.fromJson(Map<String, dynamic> json) {
    return LaporanPeriode(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }
}

class LaporanRingkasan {
  final int totalHadir;
  final int totalSakit;
  final int totalIzin;
  final int totalAlfa;
  final int totalAbsensi;
  final double persentaseHadir;
  final int hariEfektif;

  LaporanRingkasan({
    required this.totalHadir,
    required this.totalSakit,
    required this.totalIzin,
    required this.totalAlfa,
    required this.totalAbsensi,
    required this.persentaseHadir,
    required this.hariEfektif,
  });

  factory LaporanRingkasan.fromJson(Map<String, dynamic> json) {
    return LaporanRingkasan(
      totalHadir: json['total_hadir'] ?? 0,
      totalSakit: json['total_sakit'] ?? 0,
      totalIzin: json['total_izin'] ?? 0,
      totalAlfa: json['total_alfa'] ?? 0,
      totalAbsensi: json['total_absensi'] ?? 0,
      persentaseHadir: (json['persentase_hadir'] ?? 0).toDouble(),
      hariEfektif: json['hari_efektif'] ?? 0,
    );
  }
}

class LaporanDetailKelas {
  final String kelas;
  final String? guru;
  final int jumlahSiswa;
  final int hadir;
  final int sakit;
  final int izin;
  final int alfa;
  final int total;
  final double persentaseHadir;

  LaporanDetailKelas({
    required this.kelas,
    this.guru,
    required this.jumlahSiswa,
    required this.hadir,
    required this.sakit,
    required this.izin,
    required this.alfa,
    required this.total,
    required this.persentaseHadir,
  });

  factory LaporanDetailKelas.fromJson(Map<String, dynamic> json) {
    return LaporanDetailKelas(
      kelas: json['kelas'] ?? '',
      guru: json['guru'],
      jumlahSiswa: json['jumlah_siswa'] ?? 0,
      hadir: json['hadir'] ?? 0,
      sakit: json['sakit'] ?? 0,
      izin: json['izin'] ?? 0,
      alfa: json['alfa'] ?? 0,
      total: json['total'] ?? 0,
      persentaseHadir: (json['persentase_hadir'] ?? 0).toDouble(),
    );
  }
}
