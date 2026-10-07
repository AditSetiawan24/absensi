import '../core/constants/api_constants.dart';
import '../models/absensi_model.dart';
import 'api_service.dart';

// Helper function to safely extract list from data
List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data == null) return [];
  if (data is List) {
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  if (data is Map<String, dynamic>) {
    // Try common wrapper keys
    final listData = data['data'] ?? data['items'] ?? data['list'] ?? data['absensi'];
    if (listData is List) {
      return listData.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
  }
  return [];
}

class AbsensiService {
  static Future<ApiResponse<List<Absensi>>> getAll({
    String? nip,
    int? idKelas,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (nip != null) queryParams['nip'] = nip;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await ApiService.get<List<Absensi>>(
      ApiConstants.absensi,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => _parseList(data, Absensi.fromJson),
    );
  }

  static Future<ApiResponse<List<Absensi>>> getToday({
    String? nip,
    int? idKelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (nip != null) queryParams['nip'] = nip;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

    return await ApiService.get<List<Absensi>>(
      ApiConstants.absensiToday,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => _parseList(data, Absensi.fromJson),
    );
  }

  static Future<ApiResponse<List<Absensi>>> getByDate({
    required String tanggal,
    String? nip,
    int? idKelas,
  }) async {
    final queryParams = <String, dynamic>{'tanggal': tanggal};
    if (nip != null) queryParams['nip'] = nip;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

    return await ApiService.get<List<Absensi>>(
      ApiConstants.absensiByDate,
      queryParams: queryParams,
      fromJson: (data) => _parseList(data, Absensi.fromJson),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getBySiswa(String nis) async {
    return await ApiService.get<Map<String, dynamic>>(
      '${ApiConstants.absensiBySiswa}/$nis',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<List<WeeklyStats>>> getWeeklyStats({
    String? nip,
    int? idKelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (nip != null) queryParams['nip'] = nip;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

    return await ApiService.get<List<WeeklyStats>>(
      ApiConstants.absensiWeekly,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => _parseList(data, WeeklyStats.fromJson),
    );
  }

  static Future<ApiResponse<List<ConsecutiveAbsent>>> getConsecutiveAbsent({
    int? idKelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

    return await ApiService.get<List<ConsecutiveAbsent>>(
      ApiConstants.absensiConsecutive,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => _parseList(data, ConsecutiveAbsent.fromJson),
    );
  }

  static Future<ApiResponse<Absensi>> create({
    required String nis,
    required String nip,
    required String tanggal,
    required String statusKehadiran,
    String? keterangan,
    String? filePath,
  }) async {
    if (filePath != null) {
      return await ApiService.postMultipart<Absensi>(
        ApiConstants.absensi,
        fields: {
          'nis': nis,
          'nip': nip,
          'tanggal': tanggal,
          'status_kehadiran': statusKehadiran,
          if (keterangan != null) 'keterangan': keterangan,
        },
        filePath: filePath,
        fileField: 'file_surat',
        fromJson: (data) => Absensi.fromJson(data),
      );
    }

    return await ApiService.post<Absensi>(
      ApiConstants.absensi,
      body: {
        'nis': nis,
        'nip': nip,
        'tanggal': tanggal,
        'status_kehadiran': statusKehadiran,
        if (keterangan != null) 'keterangan': keterangan,
      },
      fromJson: (data) => Absensi.fromJson(data),
    );
  }

  static Future<ApiResponse> createBulk(List<Map<String, dynamic>> absensiList) async {
    return await ApiService.post(
      ApiConstants.absensiBulk,
      body: {'absensi': absensiList},
    );
  }

  static Future<ApiResponse<Absensi>> update({
    required int idAbsensi,
    String? statusKehadiran,
    String? keterangan,
  }) async {
    return await ApiService.put<Absensi>(
      '${ApiConstants.absensi}/$idAbsensi',
      body: {
        if (statusKehadiran != null) 'status_kehadiran': statusKehadiran,
        if (keterangan != null) 'keterangan': keterangan,
      },
      fromJson: (data) => Absensi.fromJson(data),
    );
  }

  static Future<ApiResponse> delete(int idAbsensi) async {
    return await ApiService.delete('${ApiConstants.absensi}/$idAbsensi');
  }

  static Future<ApiResponse<List<Absensi>>> getByKelas(int idKelas, {String? date}) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date;
    
    return await ApiService.get<List<Absensi>>(
      '${ApiConstants.absensiByKelas}/$idKelas',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => _parseList(data, Absensi.fromJson),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getStatistics({
    String? nis,
    int? idKelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (nis != null) queryParams['nis'] = nis;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

    return await ApiService.get<Map<String, dynamic>>(
      ApiConstants.absensiStatistics,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
