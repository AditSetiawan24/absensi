class User {
  final String? id;
  final String? nip;
  final int? idOrtu;
  final String nama;
  final String email;
  final String? username;
  final String? noHp;
  final String? gender;
  final String? alamat;
  final String role;

  User({
    this.id,
    this.nip,
    this.idOrtu,
    required this.nama,
    required this.email,
    this.username,
    this.noHp,
    this.gender,
    this.alamat,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json, String role) {
    return User(
      id: json['nip']?.toString() ?? json['id_ortu']?.toString(),
      nip: json['nip'],
      idOrtu: json['id_ortu'],
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      noHp: json['no_hp'],
      gender: json['gender'],
      alamat: json['alamat'],
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nip': nip,
      'id_ortu': idOrtu,
      'nama': nama,
      'email': email,
      'username': username,
      'no_hp': noHp,
      'gender': gender,
      'alamat': alamat,
      'role': role,
    };
  }
}
