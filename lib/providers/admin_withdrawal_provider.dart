import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/admin_withdrawal_model.dart';

class AdminWithdrawalProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AdminWithdrawalResponse? _data;
  bool _loading = false;
  String? _error;

  AdminWithdrawalResponse? get data => _data;

  List<AdminWithdrawal> get withdrawals =>
      _data?.withdrawals ?? [];

  AdminWithdrawalSummary? get summary =>
      _data?.summary;

  AdminWithdrawalPagination? get pagination =>
      _data?.pagination;

  bool get loading => _loading;

  String? get error => _error;

  Future<void> fetchWithdrawals({
    String? status,
    int page = 1,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final query = <String, String>{
        'page': page.toString(),
      };

      if (status != null &&
          status.isNotEmpty &&
          status != 'all') {
        query['status'] = status;
      }

      final queryString = Uri(
        queryParameters: query,
      ).query;

      final response = await _apiService.get(
        '/admin/withdrawals?$queryString',
        authenticated: true,
      );

      _data = AdminWithdrawalResponse.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> approve(int id) async {
    await _updateStatus(
      id,
      'approve',
    );
  }

  Future<void> reject(int id) async {
    await _updateStatus(
      id,
      'reject',
    );
  }

  Future<void> markPaid(int id) async {
    await _updateStatus(
      id,
      'paid',
    );
  }

  Future<void> _updateStatus(
      int id,
      String action,
      ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.put(
        '/admin/withdrawals/$id/$action',
        body: {},
        authenticated: true,
      );

      await fetchWithdrawals();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchWithdrawals();
  }
}