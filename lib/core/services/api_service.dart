import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/app_config.dart';
import 'session_service.dart';

class ApiService {
  final SessionService _sessionService;

  ApiService([SessionService? sessionService])
      : _sessionService = sessionService ?? SessionService();

  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    final headers = await _headers(authenticated);
    final url = '${AppConfig.baseUrl}$endpoint';

    try {
      final response = await http
          .post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Pastikan Laravel sedang berjalan.',
        0,
        {},
      );
    } on TimeoutException {
      throw ApiException(
        'Koneksi ke server terlalu lama. Periksa koneksi dan alamat API.',
        0,
        {},
      );
    } on HttpException {
      throw ApiException(
        'Terjadi masalah saat menghubungkan ke server.',
        0,
        {},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Gagal terhubung ke server: $e',
        0,
        {},
      );
    }
  }

  Future<Map<String, dynamic>> get(
      String endpoint, {
        bool authenticated = false,
      }) async {
    final headers = await _headers(authenticated);
    final url = '${AppConfig.baseUrl}$endpoint';

    try {
      final response = await http
          .get(
        Uri.parse(url),
        headers: headers,
      )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Pastikan Laravel sedang berjalan.',
        0,
        {},
      );
    } on TimeoutException {
      throw ApiException(
        'Koneksi ke server terlalu lama. Periksa koneksi dan alamat API.',
        0,
        {},
      );
    } on HttpException {
      throw ApiException(
        'Terjadi masalah saat menghubungkan ke server.',
        0,
        {},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Gagal terhubung ke server: $e',
        0,
        {},
      );
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    final headers = await _headers(authenticated);
    final url = '${AppConfig.baseUrl}$endpoint';

    try {
      final response = await http
          .put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server.',
        0,
        {},
      );
    } on TimeoutException {
      throw ApiException(
        'Koneksi ke server terlalu lama. Periksa koneksi dan alamat API.',
        0,
        {},
      );
    } on HttpException {
      throw ApiException(
        'Terjadi masalah saat menghubungkan ke server.',
        0,
        {},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Gagal terhubung ke server: $e',
        0,
        {},
      );
    }
  }

  Future<Map<String, dynamic>> delete(
      String endpoint, {
        bool authenticated = false,
      }) async {
    final headers = await _headers(authenticated);
    final url = '${AppConfig.baseUrl}$endpoint';

    try {
      final response = await http
          .delete(
        Uri.parse(url),
        headers: headers,
      )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server.',
        0,
        {},
      );
    } on TimeoutException {
      throw ApiException(
        'Koneksi ke server terlalu lama. Periksa koneksi dan alamat API.',
        0,
        {},
      );
    } on HttpException {
      throw ApiException(
        'Terjadi masalah saat menghubungkan ke server.',
        0,
        {},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Gagal terhubung ke server: $e',
        0,
        {},
      );
    }
  }

  Future<Map<String, dynamic>> upload(
      String endpoint, {
        required File file,
        required String fieldName,
        bool authenticated = false,
        Map<String, String>? fields,
      }) async {
    final token = await _sessionService.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
    );

    request.headers['Accept'] = 'application/json';

    if (authenticated && token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      ),
    );

    try {
      final streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 30));

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server.',
        0,
        {},
      );
    } on TimeoutException {
      throw ApiException(
        'Koneksi ke server terlalu lama. Periksa koneksi dan alamat API.',
        0,
        {},
      );
    } on HttpException {
      throw ApiException(
        'Terjadi masalah saat menghubungkan ke server.',
        0,
        {},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Gagal mengirim data ke server: $e',
        0,
        {},
      );
    }
  }

  Future<Map<String, String>> _headers(
      bool authenticated,
      ) async {
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

  Map<String, dynamic> _handleResponse(
      http.Response response,
      ) {
    dynamic decoded;

    try {
      decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};
    } catch (_) {
      throw ApiException(
        'Server mengirim response yang tidak valid. HTTP ${response.statusCode}.',
        response.statusCode,
        {
          'raw_response': response.body,
        },
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw ApiException(
        'Format response server tidak sesuai.',
        response.statusCode,
        {},
      );
    }

    if (decoded is Map<String, dynamic>) {
      String message =
          decoded['message']?.toString() ??
              decoded['error']?.toString() ??
              'Terjadi kesalahan pada server.';

      if (decoded['errors'] is Map) {
        final errors = Map<String, dynamic>.from(
          decoded['errors'],
        );

        final messages = <String>[];

        for (final entry in errors.entries) {
          final value = entry.value;

          if (value is List) {
            messages.addAll(
              value.map((item) => item.toString()),
            );
          } else {
            messages.add(value.toString());
          }
        }

        if (messages.isNotEmpty) {
          message = messages.join('\n');
        }
      }

      throw ApiException(
        message,
        response.statusCode,
        decoded,
      );
    }

    throw ApiException(
      'Terjadi kesalahan pada server. HTTP ${response.statusCode}.',
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
  String toString() {
    return message;
  }
}