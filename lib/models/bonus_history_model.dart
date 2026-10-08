class BonusHistoryModel {
  final int id;
  final String type;
  final double amount;
  final String status;
  final String? description;
  final int? sourceUserId;
  final String? sourceUserName;
  final DateTime? createdAt;

  BonusHistoryModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.sourceUserId,
    this.sourceUserName,
    this.createdAt,
  });

  factory BonusHistoryModel.fromJson(Map<String, dynamic> json) {
    final sourceUser = json['source_user'] is Map
        ? Map<String, dynamic>.from(json['source_user'])
        : <String, dynamic>{};

    return BonusHistoryModel(
      id: int.tryParse(
        json['id']?.toString() ?? '0',
      ) ??
          0,
      type: json['type']?.toString() ?? '',
      amount: double.tryParse(
        json['amount']?.toString() ?? '0',
      ) ??
          0,
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString(),
      sourceUserId: json['source_user_id'] == null
          ? null
          : int.tryParse(
        json['source_user_id'].toString(),
      ),
      sourceUserName: sourceUser['name']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(
        json['created_at'].toString(),
      ),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'line_1':
        return 'Bonus Line 1';
      case 'line_2_pairing':
        return 'Bonus Line 2';
      case 'adjustment':
        return 'Penyesuaian';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'pending':
        return 'Menunggu';
      case 'cancelled':
        return 'Dibatalkan';
      case 'reversed':
        return 'Dikembalikan';
      default:
        return status;
    }
  }
}