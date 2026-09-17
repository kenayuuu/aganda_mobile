import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_config.dart';
import 'session_service.dart';

class ApiService {
  final SessionService _sessionService = SessionService();

  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    final headers = await _headers(authenticated);

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(
      String endpoint, {
        bool authenticated = false,
      }) async {
    final headers = await _headers(authenticated);

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    final headers = await _headers(authenticated);

    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
      String endpoint, {
        bool authenticated = false,
      }) async {
    final headers = await _headers(authenticated);

    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  Future<Map<String, String>> _headers(bool authenticated) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await _sessionService.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(decoded);
    }

    if (decoded is Map<String, dynamic>) {
      throw ApiException(
        decoded['message']?.toString() ?? 'Terjadi kesalahan pada server.',
        response.statusCode,
        decoded,
      );
    }

    throw ApiException(
      'Terjadi kesalahan pada server.',
      response.statusCode,
      {},
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic> data;

  ApiException(
      this.message,
      this.statusCode,
      this.data,
      );

  @override
  String toString() => message;
}