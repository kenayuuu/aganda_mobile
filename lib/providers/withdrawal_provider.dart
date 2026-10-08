import 'package:flutter/foundation.dart';

import '../core/services/api_service.dart';
import '../models/withdrawal_model.dart';

class WithdrawalProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<WithdrawalModel> _withdrawals = [];

  bool _loading = false;
  bool _submitting = false;

  String? _error;

  // =========================
  // BONUS
  // =========================

  double _totalBonus = 0;
  double _allocatedBonus = 0;
  double _availableBonus = 0;
  double _pendingWithdrawal = 0;
  double _availableForWithdrawal = 0;

  // =========================
  // PACKAGE
  // =========================

  double _packagePrice = 0;
  double _totalPaid = 0;
  double _remainingPackage = 0;
  bool _isPackagePaidOff = false;

  bool _canWithdraw = false;

  // =========================
  // GETTERS
  // =========================

  List<WithdrawalModel> get withdrawals => _withdrawals;

  bool get loading => _loading;

  bool get submitting => _submitting;

  String? get error => _error;

  double get totalBonus => _totalBonus;

  double get allocatedBonus => _allocatedBonus;

  double get availableBonus => _availableBonus;

  double get pendingWithdrawal => _pendingWithdrawal;

  double get availableForWithdrawal => _availableForWithdrawal;

  double get packagePrice => _packagePrice;

  double get totalPaid => _totalPaid;

  double get remainingPackage => _remainingPackage;

  bool get isPackagePaidOff => _isPackagePaidOff;

  bool get canWithdraw => _canWithdraw;

  // =========================
  // FETCH DATA
  // =========================

  Future<void> fetchWithdrawals() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      final response = await _apiService.get(
        '/bonus/withdrawals',
        authenticated: true,
      );

      // =========================
      // BONUS
      // =========================

      final bonusData = response['bonus'];

      if (bonusData is Map) {
        final bonus = Map<String, dynamic>.from(bonusData);

        _totalBonus = _toDouble(bonus['total']);

        _allocatedBonus = _toDouble(bonus['allocated']);

        _availableBonus = _toDouble(bonus['available']);

        _pendingWithdrawal = _toDouble(bonus['pending_withdrawal']);

        _availableForWithdrawal = _toDouble(bonus['available_for_withdrawal']);
      } else {
        _resetBonus();
      }

      // =========================
      // PACKAGE
      // =========================

      final packageData = response['package'];

      if (packageData is Map) {
        final package = Map<String, dynamic>.from(packageData);

        _packagePrice = _toDouble(package['price']);

        _totalPaid = _toDouble(package['total_paid']);

        _remainingPackage = _toDouble(package['remaining']);

        _isPackagePaidOff = package['is_paid_off'] == true;
      } else {
        _resetPackage();
      }

      // =========================
      // CAN WITHDRAW
      // =========================

      _canWithdraw = response['can_withdraw'] == true;

      // =========================
      // WITHDRAWAL HISTORY
      // =========================

      final withdrawalsData = response['withdrawals'];

      if (withdrawalsData is List) {
        _withdrawals = withdrawalsData
            .whereType<Map>()
            .map(
              (item) =>
                  WithdrawalModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      } else {
        _withdrawals = [];
      }
    } catch (e) {
      _error = e.toString();

      _withdrawals = [];

      _resetBonus();
      _resetPackage();

      _canWithdraw = false;
    } finally {
      _loading = false;

      notifyListeners();
    }
  }

  // =========================
  // CREATE WITHDRAWAL
  // =========================

  Future<bool> createWithdrawal(double amount) async {
    if (amount <= 0) {
      _error = 'Nominal pencairan harus lebih dari 0.';
      notifyListeners();
      return false;
    }

    if (!_canWithdraw) {
      _error =
          'Pencairan belum dapat dilakukan. Pastikan bonus tersedia dan memenuhi syarat pencairan.';
      notifyListeners();
      return false;
    }

    if (amount > _availableForWithdrawal) {
      _error = 'Nominal pencairan melebihi bonus yang tersedia.';
      notifyListeners();
      return false;
    }

    _submitting = true;
    _error = null;

    notifyListeners();

    try {
      await _apiService.post(
        '/bonus/withdrawals',
        authenticated: true,
        body: {'amount': amount},
      );

      // Setelah pengajuan berhasil:
      // - withdrawal menjadi pending
      // - bonus belum berkurang
      // - pending withdrawal bertambah
      // - availableForWithdrawal berkurang
      //
      // Ambil ulang data dari backend agar seluruh angka
      // mengikuti sumber data yang sebenarnya.
      await fetchWithdrawals();

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _submitting = false;

      notifyListeners();
    }
  }

  // =========================
  // REFRESH
  // =========================

  Future<void> refresh() async {
    await fetchWithdrawals();
  }

  // =========================
  // RESET BONUS
  // =========================

  void _resetBonus() {
    _totalBonus = 0;
    _allocatedBonus = 0;
    _availableBonus = 0;
    _pendingWithdrawal = 0;
    _availableForWithdrawal = 0;
  }

  // =========================
  // RESET PACKAGE
  // =========================

  void _resetPackage() {
    _packagePrice = 0;
    _totalPaid = 0;
    _remainingPackage = 0;
    _isPackagePaidOff = false;
  }

  // =========================
  // HELPER
  // =========================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
