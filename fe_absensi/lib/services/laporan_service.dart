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
    final listData = data['data'] ?? data['items'] ?? data['list'] ?? data['laporan'];
    if (listData is List) {
      return listData.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
  }
  return [];
}

class LaporanService {
  static Future<ApiResponse<List<Laporan>>> getAll({
    String? nip,
    int? idKelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (nip != null) queryParams['nip'] = nip;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

    return await ApiService.get<List<Laporan>>(
      ApiConstants.laporan,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => _parseList(data, Laporan.fromJson),
    );
  }

  static Future<ApiResponse<Laporan>> getById(int id) async {
    return await ApiService.get<Laporan>(
      '${ApiConstants.laporan}/$id',
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  static Future<ApiResponse<LaporanGenerated>> generate({
    String? tahunAjar,
    int? semester,
    String? kelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tahunAjar != null) queryParams['tahun_ajar'] = tahunAjar;
    if (semester != null) queryParams['semester'] = semester;
    if (kelas != null) queryParams['kelas'] = kelas;

    return await ApiService.get<LaporanGenerated>(
      ApiConstants.laporanGenerate,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => LaporanGenerated.fromJson(data),
    );
  }

  static Future<ApiResponse<Laporan>> createFromAbsensi({
    required String tahunAjar,
    required int semester,
    required String kelas,
    required String nip,
  }) async {
    return await ApiService.post<Laporan>(
      '${ApiConstants.laporan}/create-from-absensi',
      body: {
        'tahun_ajar': tahunAjar,
        'semester': semester,
        'kelas': kelas,
        'nip': nip,
      },
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  static Future<ApiResponse<Laporan>> create({
    required int idKelas,
    required String nip,
    required int totalHadir,
    required int totalSakit,
    required int totalIzin,
    required int totalAlfa,
    required String periodeAwal,
    required String periodeAkhir,
  }) async {
    return await ApiService.post<Laporan>(
      ApiConstants.laporan,
      body: {
        'id_kelas': idKelas,
        'nip': nip,
        'total_hadir': totalHadir,
        'total_sakit': totalSakit,
        'total_izin': totalIzin,
        'total_alfa': totalAlfa,
        'periode_awal': periodeAwal,
        'periode_akhir': periodeAkhir,
      },
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> downloadPdf({
    String? tahunAjar,
    int? semester,
    String? kelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tahunAjar != null) queryParams['tahun_ajar'] = tahunAjar;
    if (semester != null) queryParams['semester'] = semester;
    if (kelas != null) queryParams['kelas'] = kelas;

    return await ApiService.get<Map<String, dynamic>>(
      ApiConstants.laporanDownloadPdf,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> downloadExcel({
    String? tahunAjar,
    int? semester,
    String? kelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tahunAjar != null) queryParams['tahun_ajar'] = tahunAjar;
    if (semester != null) queryParams['semester'] = semester;
    if (kelas != null) queryParams['kelas'] = kelas;

    return await ApiService.get<Map<String, dynamic>>(
      ApiConstants.laporanDownloadExcel,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<List<Laporan>>> getByKelas(int idKelas) async {
    return await ApiService.get<List<Laporan>>(
      '${ApiConstants.laporan}/by-kelas/$idKelas',
      fromJson: (data) {
        if (data is Map && data.containsKey('laporan')) {
          return (data['laporan'] as List).map((e) => Laporan.fromJson(e)).toList();
        }
        if (data is List) {
          return data.map((e) => Laporan.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getByOrangTua(String idOrtu) async {
    return await ApiService.get<List<Map<String, dynamic>>>(
      '${ApiConstants.laporan}/by-orangtua/$idOrtu',
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
        return [];
      },
    );
  }

  static Future<ApiResponse<Laporan>> update({
    required int idLaporan,
    int? idKelas,
    String? nip,
    int? totalHadir,
    int? totalSakit,
    int? totalIzin,
    int? totalAlfa,
    String? periodeAwal,
    String? periodeAkhir,
  }) async {
    final body = <String, dynamic>{};
    if (idKelas != null) body['id_kelas'] = idKelas;
    if (nip != null) body['nip'] = nip;
    if (totalHadir != null) body['total_hadir'] = totalHadir;
    if (totalSakit != null) body['total_sakit'] = totalSakit;
    if (totalIzin != null) body['total_izin'] = totalIzin;
    if (totalAlfa != null) body['total_alfa'] = totalAlfa;
    if (periodeAwal != null) body['periode_awal'] = periodeAwal;
    if (periodeAkhir != null) body['periode_akhir'] = periodeAkhir;

    return await ApiService.put<Laporan>(
      '${ApiConstants.laporan}/$idLaporan',
      body: body,
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  static Future<ApiResponse<void>> delete(int idLaporan) async {
    return await ApiService.delete<void>(
      '${ApiConstants.laporan}/$idLaporan',
      fromJson: (_) {},
    );
  }

  static Future<ApiResponse<Laporan>> submit(int idLaporan) async {
    return await ApiService.post<Laporan>(
      '${ApiConstants.laporan}/$idLaporan/submit',
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  static Future<ApiResponse<Laporan>> unsubmit(int idLaporan) async {
    return await ApiService.post<Laporan>(
      '${ApiConstants.laporan}/$idLaporan/unsubmit',
      fromJson: (data) => Laporan.fromJson(data),
    );
  }

  static Future<ApiResponse<Laporan>> refresh(int idLaporan) async {
    return await ApiService.post<Laporan>(
      '${ApiConstants.laporan}/$idLaporan/refresh',
      fromJson: (data) => Laporan.fromJson(data),
    );
  }
}
