import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _data;
  bool _loading = false;
  String? _error;

  Map<String, dynamic>? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/dashboard',
        authenticated: true,
      );

      _data = response;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchDashboard();
  }
}