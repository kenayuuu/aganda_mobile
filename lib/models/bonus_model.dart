class BonusModel {
  final double totalBonus;
  final double line1Bonus;
  final double line2Bonus;
  final double adjustmentBonus;
  final double totalAllocated;
  final double packagePayment;
  final double withdrawalAllocation;
  final double availableBonus;
  final int line1Count;
  final int line2Count;

  final BonusPackageModel? package;
  final List<BonusHistoryModel> bonusHistory;
  final List<BonusAllocationModel> allocationHistory;

  BonusModel({
    required this.totalBonus,
    required this.line1Bonus,
    required this.line2Bonus,
    required this.adjustmentBonus,
    required this.totalAllocated,
    required this.packagePayment,
    required this.withdrawalAllocation,
    required this.availableBonus,
    required this.line1Count,
    required this.line2Count,
    this.package,
    required this.bonusHistory,
    required this.allocationHistory,
  });

  factory BonusModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final summaryData =
    json['summary'] is Map
        ? Map<String, dynamic>.from(
      json['summary'] as Map,
    )
        : <String, dynamic>{};

    final packageData =
    json['package'] is Map
        ? Map<String, dynamic>.from(
      json['package'] as Map,
    )
        : null;

    final bonusHistoryData =
    json['bonus_history'] is List
        ? json['bonus_history'] as List
        : <dynamic>[];

    final allocationHistoryData =
    json['allocation_history'] is List
        ? json['allocation_history'] as List
        : <dynamic>[];

    return BonusModel(
      totalBonus: _toDouble(
        summaryData['total_bonus'],
      ),
      line1Bonus: _toDouble(
        summaryData['line_1_bonus'],
      ),
      line2Bonus: _toDouble(
        summaryData['line_2_bonus'],
      ),
      adjustmentBonus: _toDouble(
        summaryData['adjustment_bonus'],
      ),
      totalAllocated: _toDouble(
        summaryData['total_allocated'],
      ),
      packagePayment: _toDouble(
        summaryData['package_payment'],
      ),
      withdrawalAllocation: _toDouble(
        summaryData['withdrawal_allocation'],
      ),
      availableBonus: _toDouble(
        summaryData['available_bonus'],
      ),
      line1Count: _toInt(
        summaryData['line_1_count'],
      ),
      line2Count: _toInt(
        summaryData['line_2_count'],
      ),
      package: packageData == null
          ? null
          : BonusPackageModel.fromJson(
        packageData,
      ),
      bonusHistory: bonusHistoryData
          .whereType<Map>()
          .map(
            (item) =>
            BonusHistoryModel.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
      )
          .toList(),
      allocationHistory: allocationHistoryData
          .whereType<Map>()
          .map(
            (item) =>
            BonusAllocationModel.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
      )
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    ) ??
        0;
  }
}


// ============================================================
// PACKAGE
// ============================================================

class BonusPackageModel {
  final int? id;
  final String? name;
  final double price;
  final double deposit;
  final double paidDp;
  final double paidPackage;
  final double remainingPackage;

  BonusPackageModel({
    this.id,
    this.name,
    required this.price,
    required this.deposit,
    required this.paidDp,
    required this.paidPackage,
    required this.remainingPackage,
  });

  factory BonusPackageModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BonusPackageModel(
      id: _toNullableInt(
        json['package_id'],
      ),
      name: json['package_name']?.toString(),
      price: _toDouble(
        json['package_price'],
      ),
      deposit: _toDouble(
        json['deposit'],
      ),
      paidDp: _toDouble(
        json['paid_dp'],
      ),
      paidPackage: _toDouble(
        json['paid_package'],
      ),
      remainingPackage: _toDouble(
        json['remaining_package'],
      ),
    );
  }

  static int? _toNullableInt(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static double _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }
}


// ============================================================
// BONUS HISTORY
// ============================================================

class BonusHistoryModel {
  final int id;
  final String type;
  final double amount;
  final String status;
  final String? description;
  final String? groupCode;
  final String? sourceUserName;
  final String? sourceMemberId;
  final String? createdAt;

  BonusHistoryModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.groupCode,
    this.sourceUserName,
    this.sourceMemberId,
    this.createdAt,
  });

  factory BonusHistoryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final groupData =
    json['group'] is Map
        ? Map<String, dynamic>.from(
      json['group'] as Map,
    )
        : <String, dynamic>{};

    final sourceUserData =
    json['source_user'] is Map
        ? Map<String, dynamic>.from(
      json['source_user'] as Map,
    )
        : <String, dynamic>{};

    return BonusHistoryModel(
      id: _toInt(
        json['id'],
      ),
      type: json['type']?.toString() ?? '',
      amount: _toDouble(
        json['amount'],
      ),
      status: json['status']?.toString() ?? '',
      description:
      json['description']?.toString(),
      groupCode:
      groupData['kode_group']?.toString(),
      sourceUserName:
      sourceUserData['name']?.toString(),
      sourceMemberId:
      sourceUserData['member_id']?.toString(),
      createdAt:
      json['created_at']?.toString(),
    );
  }

  static int _toInt(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    ) ??
        0;
  }

  static double _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }
}


// ============================================================
// BONUS ALLOCATION HISTORY
// ============================================================

class BonusAllocationModel {
  final int id;
  final int? bonusTransactionId;
  final String type;
  final double amount;
  final int? referenceId;
  final String? notes;
  final String? createdAt;

  BonusAllocationModel({
    required this.id,
    this.bonusTransactionId,
    required this.type,
    required this.amount,
    this.referenceId,
    this.notes,
    this.createdAt,
  });

  factory BonusAllocationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BonusAllocationModel(
      id: _toInt(
        json['id'],
      ),
      bonusTransactionId:
      _toNullableInt(
        json['bonus_transaction_id'],
      ),
      type:
      json['allocation_type']
          ?.toString() ??
          '',
      amount: _toDouble(
        json['amount'],
      ),
      referenceId:
      _toNullableInt(
        json['reference_id'],
      ),
      notes:
      json['notes']?.toString(),
      createdAt:
      json['created_at']?.toString(),
    );
  }

  static int _toInt(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    ) ??
        0;
  }

  static int? _toNullableInt(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static double _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }
}