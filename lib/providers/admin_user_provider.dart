import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../models/admin_user_model.dart';

class AdminUserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AdminUserResponse? _data;
  bool _loading = false;
  String? _error;

  AdminUserResponse? get data => _data;

  List<AdminUserModel> get users => _data?.users ?? [];

  AdminUserPagination? get pagination => _data?.pagination;

  int get totalUsers {
    return _data?.pagination?.total ?? _data?.users.length ?? 0;
  }

  bool get loading => _loading;

  String? get error => _error;

  Future<void> fetchUsers({
    String? search,
    int page = 1,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      final queryString = Uri(
        queryParameters: queryParameters,
      ).query;

      final response = await _apiService.get(
        '/admin/users?$queryString',
        authenticated: true,
      );

      _data = AdminUserResponse.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchUsers(
      page: 1,
    );
  }
}