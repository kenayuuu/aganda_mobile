import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/bonus_history_model.dart';

class BonusHistoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<BonusHistoryModel> _histories = [];
  bool _loading = false;
  String? _error;

  List<BonusHistoryModel> get histories => _histories;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/bonus/history',
        authenticated: true,
      );

      final data = response['data'];

      if (data is List) {
        _histories = data
            .whereType<Map>()
            .map(
              (item) => BonusHistoryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      } else if (response['bonus'] is List) {
        _histories = (response['bonus'] as List)
            .whereType<Map>()
            .map(
              (item) => BonusHistoryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      } else {
        _histories = [];
      }
    } catch (e) {
      _histories = [];
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchHistory();
  }
}