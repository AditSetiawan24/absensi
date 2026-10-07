import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });
}

class ApiService {
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));
      
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required Map<String, String> fields,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    String? fileField,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });
      
      request.fields.addAll(fields);
      
      if (fileField != null) {
        if (fileBytes != null && fileName != null) {
          request.files.add(http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
          ));
        } else if (filePath != null) {
          request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final body = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic data = body['data'];
        
        // Handle paginated or wrapped responses
        if (data is Map<String, dynamic>) {
          // Check for common wrapper keys
          if (data.containsKey('data')) {
            data = data['data'];
          } else if (data.containsKey('items')) {
            data = data['items'];
          } else if (data.containsKey('list')) {
            data = data['list'];
          }
        }
        
        return ApiResponse(
          success: body['success'] ?? true,
          message: body['message'] ?? 'Berhasil',
          data: fromJson != null && data != null 
              ? fromJson(data) 
              : data,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Terjadi kesalahan',
          errors: body['errors'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error parsing response: $e',
      );
    }
  }
}
