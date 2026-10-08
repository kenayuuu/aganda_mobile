import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/structure_model.dart';

class StructureProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  StructureResponseModel? _data;
  bool _loading = false;
  bool _pairing = false;
  String? _error;

  StructureResponseModel? get data => _data;
  bool get loading => _loading;
  bool get pairing => _pairing;
  String? get error => _error;

  Future<void> fetchStructure(int groupId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/groups/$groupId/structure',
        authenticated: true,
      );

      _data = StructureResponseModel.fromJson(response);
    } catch (e) {
      _data = null;
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> pairMembers({
    required int groupId,
    required int leftMemberId,
    required int rightMemberId,
  }) async {
    _pairing = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.post(
        '/groups/$groupId/pairing',
        authenticated: true,
        body: {
          'left_member_id': leftMemberId,
          'right_member_id': rightMemberId,
        },
      );

      await fetchStructure(groupId);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _pairing = false;
      notifyListeners();
    }
  }

  Future<void> refresh(int groupId) async {
    await fetchStructure(groupId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}