import '../core/constants/api_constants.dart';
import '../models/siswa_model.dart';
import 'api_service.dart';

// Helper function to safely extract list from data
List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data == null) return [];
  if (data is List) {
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  if (data is Map<String, dynamic>) {
    // Try common wrapper keys
    final listData = data['data'] ?? data['items'] ?? data['list'] ?? data['siswa'] ?? data['guru'] ?? data['kelas'];
    if (listData is List) {
      return listData.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
  }
  return [];
}

class SiswaService {
  static Future<ApiResponse<List<Siswa>>> getAll() async {
    return await ApiService.get<List<Siswa>>(
      ApiConstants.siswa,
      fromJson: (data) => _parseList(data, Siswa.fromJson),
    );
  }

  static Future<ApiResponse<Siswa>> getByNis(String nis) async {
    return await ApiService.get<Siswa>(
      '${ApiConstants.siswa}/$nis',
      fromJson: (data) => Siswa.fromJson(data),
    );
  }

  static Future<ApiResponse<List<Siswa>>> search(String query) async {
    return await ApiService.get<List<Siswa>>(
      ApiConstants.siswaSearch,
      queryParams: {'q': query},
      fromJson: (data) => _parseList(data, Siswa.fromJson),
    );
  }

  static Future<ApiResponse<List<Siswa>>> getByKelas(int idKelas) async {
    return await ApiService.get<List<Siswa>>(
      '${ApiConstants.siswaByKelas}/$idKelas',
      fromJson: (data) => _parseList(data, Siswa.fromJson),
    );
  }
}

class GuruService {
  static Future<ApiResponse<List<Guru>>> getAll() async {
    return await ApiService.get<List<Guru>>(
      ApiConstants.guru,
      fromJson: (data) => _parseList(data, Guru.fromJson),
    );
  }

  static Future<ApiResponse<Guru>> getByNip(String nip) async {
    return await ApiService.get<Guru>(
      '${ApiConstants.guru}/$nip',
      fromJson: (data) => Guru.fromJson(data),
    );
  }
}

class KelasService {
  static Future<ApiResponse<List<Kelas>>> getAll() async {
    return await ApiService.get<List<Kelas>>(
      ApiConstants.kelas,
      fromJson: (data) => _parseList(data, Kelas.fromJson),
    );
  }

  static Future<ApiResponse<Kelas>> getById(int id) async {
    return await ApiService.get<Kelas>(
      '${ApiConstants.kelas}/$id',
      fromJson: (data) => Kelas.fromJson(data),
    );
  }

  static Future<ApiResponse<List<Kelas>>> getByGuru(String nip) async {
    return await ApiService.get<List<Kelas>>(
      '${ApiConstants.kelasByGuru}/$nip',
      fromJson: (data) => _parseList(data, Kelas.fromJson),
    );
  }
}
