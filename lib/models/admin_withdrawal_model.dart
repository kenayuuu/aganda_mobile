class AdminWithdrawal {
  final int id;
  final int userId;
  final String userName;
  final String? memberId;
  final String? email;
  final double amount;
  final String status;
  final String? requestedAt;
  final String? processedAt;
  final String? notes;

  AdminWithdrawal({
    required this.id,
    required this.userId,
    required this.userName,
    required this.memberId,
    required this.email,
    required this.amount,
    required this.status,
    required this.requestedAt,
    required this.processedAt,
    required this.notes,
  });

  factory AdminWithdrawal.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'])
        : <String, dynamic>{};

    return AdminWithdrawal(
      id: _toInt(json['id']),
      userId: _toInt(
        json['user_id'] ?? user['id'],
      ),
      userName: (
          json['user_name'] ??
              user['name'] ??
              ''
      ).toString(),
      memberId: (
          json['member_id'] ??
              user['member_id']
      )?.toString(),
      email: (
          json['email'] ??
              user['email']
      )?.toString(),
      amount: _toDouble(json['amount']),
      status: json['status']?.toString() ?? 'pending',
      requestedAt: json['requested_at']?.toString(),
      processedAt: json['processed_at']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}

class AdminWithdrawalSummary {
  final int pendingCount;
  final int approvedCount;
  final int paidCount;
  final double pendingAmount;
  final double approvedAmount;
  final double paidAmount;

  AdminWithdrawalSummary({
    required this.pendingCount,
    required this.approvedCount,
    required this.paidCount,
    required this.pendingAmount,
    required this.approvedAmount,
    required this.paidAmount,
  });

  factory AdminWithdrawalSummary.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminWithdrawalSummary(
      pendingCount: _toInt(json['pending_count']),
      approvedCount: _toInt(json['approved_count']),
      paidCount: _toInt(json['paid_count']),
      pendingAmount: _toDouble(json['pending_amount']),
      approvedAmount: _toDouble(json['approved_amount']),
      paidAmount: _toDouble(json['paid_amount']),
    );
  }
}

class AdminWithdrawalPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  AdminWithdrawalPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory AdminWithdrawalPagination.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminWithdrawalPagination(
      currentPage: _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']),
      perPage: _toInt(json['per_page']),
      total: _toInt(json['total']),
      from: _toInt(json['from']),
      to: _toInt(json['to']),
    );
  }
}

class AdminWithdrawalResponse {
  final List<AdminWithdrawal> withdrawals;
  final AdminWithdrawalSummary summary;
  final AdminWithdrawalPagination? pagination;

  AdminWithdrawalResponse({
    required this.withdrawals,
    required this.summary,
    required this.pagination,
  });

  factory AdminWithdrawalResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    dynamic rawWithdrawals =
        json['withdrawals'] ??
            json['data'] ??
            [];

    final withdrawals = rawWithdrawals is List
        ? rawWithdrawals
        .whereType<Map>()
        .map(
          (item) => AdminWithdrawal.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList()
        : <AdminWithdrawal>[];

    final rawSummary = json['summary'];

    final rawPagination = json['pagination'];

    return AdminWithdrawalResponse(
      withdrawals: withdrawals,
      summary: rawSummary is Map
          ? AdminWithdrawalSummary.fromJson(
        Map<String, dynamic>.from(rawSummary),
      )
          : AdminWithdrawalSummary(
        pendingCount: 0,
        approvedCount: 0,
        paidCount: 0,
        pendingAmount: 0,
        approvedAmount: 0,
        paidAmount: 0,
      ),
      pagination: rawPagination is Map
          ? AdminWithdrawalPagination.fromJson(
        Map<String, dynamic>.from(rawPagination),
      )
          : null,
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

  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString()) ?? 0;
}