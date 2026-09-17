import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/session_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  UserModel? _user;
  bool _loading = true;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  Future<void> checkSession() async {
    _loading = true;
    notifyListeners();

    try {
      final loggedIn = await _sessionService.isLoggedIn();

      if (!loggedIn) {
        _user = null;
        return;
      }

      final response = await _apiService.get(
        '/me',
        authenticated: true,
      );

      final userData = response['user'];

      if (userData is Map<String, dynamic>) {
        _user = UserModel.fromJson(userData);
      } else {
        await _sessionService.clearSession();
        _user = null;
      }
    } catch (_) {
      await _sessionService.clearSession();
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String login,
    required String password,
  }) async {
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

      _user = user;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(
        '/logout',
        authenticated: true,
      );
    } catch (_) {}

    await _sessionService.clearSession();

    _user = null;
    notifyListeners();
  }
}