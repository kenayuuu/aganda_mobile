import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/group_detail_model.dart';

class GroupDetailProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  GroupDetailModel? _group;
  bool _loading = false;
  String? _error;

  GroupDetailModel? get group => _group;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchGroup(int groupId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/groups/$groupId',
        authenticated: true,
      );

      _group = GroupDetailModel.fromJson(response);
    } catch (e) {
      _group = null;
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(int groupId) async {
    await fetchGroup(groupId);
  }
}