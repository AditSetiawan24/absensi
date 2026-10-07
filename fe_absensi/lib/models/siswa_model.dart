class Siswa {
  final String nis;
  final String nama;
  final String gender;
  final String tanggalLahir;
  final String alamat;
  final int idOrtu;
  final int idKelas;
  final Kelas? kelas;
  final OrangTua? orangTua;

  Siswa({
    required this.nis,
    required this.nama,
    required this.gender,
    required this.tanggalLahir,
    required this.alamat,
    required this.idOrtu,
    required this.idKelas,
    this.kelas,
    this.orangTua,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      nis: json['nis'] ?? '',
      nama: json['nama'] ?? '',
      gender: json['gender'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      alamat: json['alamat'] ?? '',
      idOrtu: json['id_ortu'] ?? 0,
      idKelas: json['id_kelas'] ?? 0,
      kelas: json['kelas'] != null ? Kelas.fromJson(json['kelas']) : null,
      orangTua: json['orang_tua'] != null ? OrangTua.fromJson(json['orang_tua']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nis': nis,
      'nama': nama,
      'gender': gender,
      'tanggal_lahir': tanggalLahir,
      'alamat': alamat,
      'id_ortu': idOrtu,
      'id_kelas': idKelas,
    };
  }
}

class Kelas {
  final int idKelas;
  final String kelas;
  final String tahunAjar;
  final String nip;
  final Guru? guru;
  final List<Siswa>? siswa;

  Kelas({
    required this.idKelas,
    required this.kelas,
    required this.tahunAjar,
    required this.nip,
    this.guru,
    this.siswa,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      idKelas: json['id_kelas'] ?? 0,
      kelas: json['kelas'] ?? '',
      tahunAjar: json['tahun_ajar'] ?? '',
      nip: json['nip'] ?? '',
      guru: json['guru'] != null ? Guru.fromJson(json['guru']) : null,
      siswa: json['siswa'] != null
          ? (json['siswa'] as List).map((e) => Siswa.fromJson(e)).toList()
          : null,
    );
  }
}

class Guru {
  final String nip;
  final String nama;
  final String gender;
  final String noHp;
  final String email;
  final String username;

  Guru({
    required this.nip,
    required this.nama,
    required this.gender,
    required this.noHp,
    required this.email,
    required this.username,
  });

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      nip: json['nip'] ?? '',
      nama: json['nama'] ?? '',
      gender: json['gender'] ?? '',
      noHp: json['no_hp'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class OrangTua {
  final int idOrtu;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final String username;
  final List<Siswa>? siswa;

  OrangTua({
    required this.idOrtu,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.username,
    this.siswa,
  });

  factory OrangTua.fromJson(Map<String, dynamic> json) {
    return OrangTua(
      idOrtu: json['id_ortu'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noHp: json['no_hp'] ?? '',
      alamat: json['alamat'] ?? '',
      username: json['username'] ?? '',
      siswa: json['siswa'] != null
          ? (json['siswa'] as List).map((e) => Siswa.fromJson(e)).toList()
          : null,
    );
  }
}
