import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/session_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  UserModel? _user;
  bool _loading = true;
  int _authRequestId = 0;

  AuthProvider() {
    checkSession();
  }

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  Future<void> checkSession() async {
    final requestId = ++_authRequestId;

    _loading = true;
    notifyListeners();

    try {
      final loggedIn = await _sessionService.isLoggedIn();

      if (requestId != _authRequestId) {
        return;
      }

      if (!loggedIn) {
        _user = null;
        return;
      }

      final response = await _apiService.get(
        '/me',
        authenticated: true,
      );

      if (requestId != _authRequestId) {
        return;
      }

      final userData = response['user'];

      if (userData is Map<String, dynamic>) {
        _user = UserModel.fromJson(userData);
      } else {
        await _sessionService.clearSession();
        _user = null;
      }
    } catch (_) {
      if (requestId != _authRequestId) {
        return;
      }

      await _sessionService.clearSession();
      _user = null;
    } finally {
      if (requestId == _authRequestId) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> login({
    required String login,
    required String password,
  }) async {
    final requestId = ++_authRequestId;

    _loading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/login',
        body: {
          'login': login,
          'password': password,
        },
      );

      final token = response['token']?.toString();
      final userData = response['user'];

      if (token == null || userData is! Map<String, dynamic>) {
        throw Exception('Data login dari server tidak valid.');
      }

      final user = UserModel.fromJson(userData);

      await _sessionService.saveSession(
        token: token,
        userId: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        memberId: user.memberId,
      );

      if (requestId != _authRequestId) {
        return;
      }

      _user = user;
    } finally {
      if (requestId == _authRequestId) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    ++_authRequestId;

    try {
      await _apiService.post(
        '/logout',
        authenticated: true,
      );
    } catch (_) {}

    await _sessionService.clearSession();

    _user = null;
    _loading = false;
    notifyListeners();
  }
}