class WithdrawalModel {
  final int id;
  final int userId;
  final double amount;
  final String status;
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String? notes;
  final String? userName;

  WithdrawalModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    this.requestedAt,
    this.processedAt,
    this.notes,
    this.userName,
  });

  factory WithdrawalModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(
      json['user'],
    )
        : <String, dynamic>{};

    return WithdrawalModel(
      id: int.tryParse(
        json['id']?.toString() ?? '0',
      ) ??
          0,

      userId: int.tryParse(
        json['user_id']?.toString() ?? '0',
      ) ??
          0,

      amount: double.tryParse(
        json['amount']?.toString() ?? '0',
      ) ??
          0,

      status: json['status']?.toString() ?? '',

      requestedAt:
      _parseDateTime(
        json['requested_at'],
      ),

      processedAt:
      _parseDateTime(
        json['processed_at'],
      ),

      notes: json['notes']?.toString(),

      userName: user['name']?.toString(),
    );
  }

  static DateTime? _parseDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  // =========================
  // STATUS LABEL
  // =========================

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';

      case 'approved':
        return 'Disetujui';

      case 'rejected':
        return 'Ditolak';

      case 'paid':
        return 'Sudah Dibayar';

      case 'cancelled':
        return 'Dibatalkan';

      default:
        return status;
    }
  }
}