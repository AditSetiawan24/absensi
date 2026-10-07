import '../core/constants/api_constants.dart';
import '../models/dashboard_model.dart';
import 'api_service.dart';

// Helper function to safely extract list from data
List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data == null) return [];
  if (data is List) {
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  if (data is Map<String, dynamic>) {
    // Try common wrapper keys
    final listData = data['data'] ?? data['items'] ?? data['list'] ?? data['class_stats'];
    if (listData is List) {
      return listData.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
  }
  return [];
}

class DashboardService {
  static Future<ApiResponse<GuruDashboard>> getGuruDashboard(String nip) async {
    return await ApiService.get<GuruDashboard>(
      '${ApiConstants.dashboardGuru}/$nip',
      fromJson: (data) => GuruDashboard.fromJson(data is Map<String, dynamic> ? data : {}),
    );
  }

  static Future<ApiResponse<KepalaSekolahDashboard>> getKepalaSekolahDashboard({
    String? tahunAjar,
    int? semester,
    String? kelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tahunAjar != null) queryParams['tahun_ajar'] = tahunAjar;
    if (semester != null) queryParams['semester'] = semester;
    if (kelas != null) queryParams['kelas'] = kelas;

    return await ApiService.get<KepalaSekolahDashboard>(
      ApiConstants.dashboardKepalaSekolah,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => KepalaSekolahDashboard.fromJson(data is Map<String, dynamic> ? data : {}),
    );
  }

  static Future<ApiResponse<OrangTuaDashboard>> getOrangTuaDashboard(int idOrtu) async {
    return await ApiService.get<OrangTuaDashboard>(
      '${ApiConstants.dashboardOrangTua}/$idOrtu',
      fromJson: (data) => OrangTuaDashboard.fromJson(data is Map<String, dynamic> ? data : {}),
    );
  }

  static Future<ApiResponse<List<ClassStats>>> getClassComparison({
    String? tahunAjar,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tahunAjar != null) queryParams['tahun_ajar'] = tahunAjar;

    return await ApiService.get<List<ClassStats>>(
      ApiConstants.dashboardClassComparison,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => _parseList(data, ClassStats.fromJson),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getSemesterComparison({
    String? tahunAjar,
    String? kelas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tahunAjar != null) queryParams['tahun_ajar'] = tahunAjar;
    if (kelas != null) queryParams['kelas'] = kelas;

    return await ApiService.get<Map<String, dynamic>>(
      ApiConstants.dashboardSemesterComparison,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => data is Map<String, dynamic> ? data : {},
    );
  }
}
