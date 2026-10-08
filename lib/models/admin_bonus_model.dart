class AdminBonusModel {
  final AdminBonusSummary summary;
  final List<AdminBonusItem> data;
  final AdminBonusPagination pagination;

  AdminBonusModel({
    required this.summary,
    required this.data,
    required this.pagination,
  });

  factory AdminBonusModel.fromJson(Map<String, dynamic> json) {
    return AdminBonusModel(
      summary: AdminBonusSummary.fromJson(
        json['summary'] ?? {},
      ),
      data: (json['data'] as List? ?? [])
          .map(
            (item) => AdminBonusItem.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
      pagination: AdminBonusPagination.fromJson(
        json['pagination'] ?? {},
      ),
    );
  }
}

class AdminBonusSummary {
  final int totalUsers;
  final double totalBonus;
  final double totalAvailableBonus;

  AdminBonusSummary({
    required this.totalUsers,
    required this.totalBonus,
    required this.totalAvailableBonus,
  });

  factory AdminBonusSummary.fromJson(Map<String, dynamic> json) {
    return AdminBonusSummary(
      totalUsers: _toInt(json['total_users']),
      totalBonus: _toDouble(json['total_bonus']),
      totalAvailableBonus: _toDouble(
        json['total_available_bonus'],
      ),
    );
  }
}

class AdminBonusItem {
  final AdminBonusUser user;
  final double packagePrice;
  final double deposit;
  final double initialRemaining;
  final double remainingPackage;
  final int line1Count;
  final double line1Bonus;
  final int line2Count;
  final double line2Bonus;
  final double totalBonus;
  final double packagePayment;
  final double availableBonus;

  AdminBonusItem({
    required this.user,
    required this.packagePrice,
    required this.deposit,
    required this.initialRemaining,
    required this.remainingPackage,
    required this.line1Count,
    required this.line1Bonus,
    required this.line2Count,
    required this.line2Bonus,
    required this.totalBonus,
    required this.packagePayment,
    required this.availableBonus,
  });

  factory AdminBonusItem.fromJson(Map<String, dynamic> json) {
    return AdminBonusItem(
      user: AdminBonusUser.fromJson(
        json['user'] ?? {},
      ),
      packagePrice: _toDouble(
        json['package_price'],
      ),
      deposit: _toDouble(
        json['deposit'],
      ),
      initialRemaining: _toDouble(
        json['initial_remaining'],
      ),
      remainingPackage: _toDouble(
        json['remaining_package'],
      ),
      line1Count: _toInt(
        json['line1_count'],
      ),
      line1Bonus: _toDouble(
        json['line1_bonus'],
      ),
      line2Count: _toInt(
        json['line2_count'],
      ),
      line2Bonus: _toDouble(
        json['line2_bonus'],
      ),
      totalBonus: _toDouble(
        json['total_bonus'],
      ),
      packagePayment: _toDouble(
        json['package_payment'],
      ),
      availableBonus: _toDouble(
        json['available_bonus'],
      ),
    );
  }
}

class AdminBonusUser {
  final int id;
  final String name;
  final String email;
  final String? memberId;
  final String role;
  final String? avatar;

  AdminBonusUser({
    required this.id,
    required this.name,
    required this.email,
    required this.memberId,
    required this.role,
    required this.avatar,
  });

  factory AdminBonusUser.fromJson(Map<String, dynamic> json) {
    return AdminBonusUser(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      memberId: json['member_id']?.toString(),
      role: json['role']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  String get avatarUrl {
    if (avatar == null || avatar!.isEmpty) {
      return '';
    }

    if (avatar!.startsWith('http')) {
      return avatar!;
    }

    return 'http://10.0.2.2:8000/storage/$avatar';
  }
}

class AdminBonusPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  AdminBonusPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory AdminBonusPagination.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminBonusPagination(
      currentPage: _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']),
      perPage: _toInt(json['per_page']),
      total: _toInt(json['total']),
      from: _toInt(json['from']),
      to: _toInt(json['to']),
    );
  }
}

double _toDouble(dynamic value) {
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

int _toInt(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
    value.toString(),
  ) ??
      0;
}