import '../core/constants/api_constants.dart';
import '../models/laporan_model.dart';
import 'api_service.dart';

// Helper function to safely extract list from data
List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data == null) return [];
  if (data is List) {
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  if (data is Map<String, dynamic>) {
    // Try common wrapper keys
    final listData = data['data'] ?? data['items'] ?? data['list'] ?? data['rekap'];
    if (listData is List) {
      return listData.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
  }
  return [];
}

class RekapBulananService {
  /// Get all rekap bulanan dengan filter opsional
  static Future<ApiResponse<List<Laporan>>> getAll({
    int? idKelas,
    String? nip,
    int? tahun,
  }) async {
    final queryParams = <String, dynamic>{};
    if (idKelas != null) queryParams['id_kelas'] = idKelas;
    if (nip != null) queryParams['nip'] = nip;
    if (tahun != null) queryParams['tahun'] = tahun;

    return await ApiService.get<List<Laporan>>(
      ApiConstants.rekapBulanan,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => _parseList(data, Laporan.fromJson),
    );
  }

  /// Create rekap bulanan baru
  static Future<ApiResponse<Laporan>> create({
    required int idKelas,
    required String nip,
    required int bulan,
    required int tahun,
  }) async {
    return await ApiService.post<Laporan>(
      ApiConstants.rekapBulanan,
      body: {
        'id_kelas': idKelas,
        'nip': nip,
        'bulan': bulan,
        'tahun': tahun,
      },
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  /// Update rekap bulanan
  static Future<ApiResponse<Laporan>> update({
    required int id,
    int? totalHadir,
    int? totalSakit,
    int? totalIzin,
    int? totalAlfa,
  }) async {
    final body = <String, dynamic>{};
    if (totalHadir != null) body['total_hadir'] = totalHadir;
    if (totalSakit != null) body['total_sakit'] = totalSakit;
    if (totalIzin != null) body['total_izin'] = totalIzin;
    if (totalAlfa != null) body['total_alfa'] = totalAlfa;

    return await ApiService.put<Laporan>(
      '${ApiConstants.rekapBulanan}/$id',
      body: body,
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  /// Delete rekap bulanan
  static Future<ApiResponse<void>> delete(int id) async {
    return await ApiService.delete(
      '${ApiConstants.rekapBulanan}/$id',
    );
  }

  /// Refresh data rekap dari absensi terbaru
  static Future<ApiResponse<Laporan>> refresh(int id) async {
    return await ApiService.post<Laporan>(
      '${ApiConstants.rekapBulanan}/$id/refresh',
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  /// Submit rekap bulanan
  static Future<ApiResponse<Laporan>> submit(int id) async {
    return await ApiService.post<Laporan>(
      '${ApiConstants.rekapBulanan}/$id/submit',
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  /// Batal submit rekap bulanan
  static Future<ApiResponse<Laporan>> unsubmit(int id) async {
    return await ApiService.post<Laporan>(
      '${ApiConstants.rekapBulanan}/$id/unsubmit',
      fromJson: (data) => Laporan.fromJson(data),
    );
  }
}
