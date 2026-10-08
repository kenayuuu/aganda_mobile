import 'package:flutter/foundation.dart';

import '../core/services/api_service.dart';
import '../models/bonus_model.dart';

class BonusProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  BonusModel? _bonus;
  bool _loading = false;
  String? _error;

  BonusModel? get bonus => _bonus;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchBonus() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/bonus',
        authenticated: true,
      );

      _bonus = BonusModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> allocatePackage() async {
    _error = null;
    notifyListeners();

    try {
      await _apiService.post(
        '/bonus/allocate-package',
        authenticated: true,
      );

      await fetchBonus();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() async {
    await fetchBonus();
  }
}