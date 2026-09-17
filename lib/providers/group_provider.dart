import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/group_model.dart';

class GroupProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<GroupModel> _groups = [];
  bool _loading = false;
  String? _error;

  List<GroupModel> get groups => _groups;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchGroups() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/groups',
        authenticated: true,
      );

      final data = response['groups'];

      if (data is List) {
        _groups = data
            .whereType<Map>()
            .map(
              (item) => GroupModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      } else {
        _groups = [];
      }
    } catch (e) {
      _groups = [];
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchGroups();
  }
}