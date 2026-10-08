import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../models/admin_bonus_model.dart';

class AdminBonusProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AdminBonusModel? _data;
  bool _loading = false;
  String? _error;

  AdminBonusModel? get data => _data;

  AdminBonusSummary? get summary => _data?.summary;

  List<AdminBonusItem> get users => _data?.data ?? [];

  AdminBonusPagination? get pagination => _data?.pagination;

  bool get loading => _loading;

  String? get error => _error;

  Future<void> fetchBonus({
    String? search,
    int page = 1,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final query = <String, String>{
        'page': page.toString(),
      };

      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }

      final queryString = Uri(
        queryParameters: query,
      ).query;

      final response = await _apiService.get(
        '/admin/bonus?$queryString',
        authenticated: true,
      );

      debugPrint('ADMIN BONUS RESPONSE: $response');

      _data = AdminBonusModel.fromJson(response);

      _data = AdminBonusModel.fromJson(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchBonus();
  }
}