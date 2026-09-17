import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  bool _loading = false;
  bool _updating = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get updating => _updating;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/profile',
        authenticated: true,
      );

      final data = response['user'];

      if (data is Map<String, dynamic>) {
        _user = UserModel.fromJson(data);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    _updating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        '/profile',
        authenticated: true,
        body: {
          'name': name,
          'phone': phone,
          'address': address,
        },
      );

      final data = response['user'];

      if (data is Map<String, dynamic>) {
        _user = UserModel.fromJson(data);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _updating = false;
      notifyListeners();
    }
  }
}