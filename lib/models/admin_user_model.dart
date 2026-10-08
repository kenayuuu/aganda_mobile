import '../core/constants/app_config.dart';

class AdminUserModel {
  final int id;
  final String name;
  final String email;
  final String? memberId;
  final String role;
  final String? phone;
  final String? address;
  final String? avatar;
  final AdminUserParent? parent;
  final int totalChildren;
  final AdminUserCalon? calon;
  final String createdAt;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.memberId,
    required this.role,
    required this.phone,
    required this.address,
    required this.avatar,
    required this.parent,
    required this.totalChildren,
    required this.calon,
    required this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      memberId: json['member_id']?.toString(),
      role: json['role']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      avatar: json['avatar']?.toString(),
      parent: json['parent'] is Map
          ? AdminUserParent.fromJson(
        Map<String, dynamic>.from(json['parent']),
      )
          : null,
      totalChildren: _toInt(json['total_children']),
      calon: json['calon'] is Map
          ? AdminUserCalon.fromJson(
        Map<String, dynamic>.from(json['calon']),
      )
          : null,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  String get avatarUrl {
    if (avatar == null || avatar!.isEmpty) {
      return '';
    }

    if (avatar!.startsWith('http')) {
      return avatar!;
    }

    return '${AppConfig.storageUrl}/$avatar';
  }
}

class AdminUserParent {
  final int id;
  final String name;
  final String? memberId;
  final String role;

  AdminUserParent({
    required this.id,
    required this.name,
    required this.memberId,
    required this.role,
  });

  factory AdminUserParent.fromJson(Map<String, dynamic> json) {
    return AdminUserParent(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      memberId: json['member_id']?.toString(),
      role: json['role']?.toString() ?? '',
    );
  }
}

class AdminUserCalon {
  final int id;
  final String name;
  final String? nik;
  final String? noHp;
  final String? alamat;

  AdminUserCalon({
    required this.id,
    required this.name,
    required this.nik,
    required this.noHp,
    required this.alamat,
  });

  factory AdminUserCalon.fromJson(Map<String, dynamic> json) {
    return AdminUserCalon(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      nik: json['nik']?.toString(),
      noHp: json['no_hp']?.toString(),
      alamat: json['alamat']?.toString(),
    );
  }
}

class AdminUserPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  AdminUserPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory AdminUserPagination.fromJson(Map<String, dynamic> json) {
    return AdminUserPagination(
      currentPage: _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']),
      perPage: _toInt(json['per_page']),
      total: _toInt(json['total']),
      from: _toInt(json['from']),
      to: _toInt(json['to']),
    );
  }
}

class AdminUserResponse {
  final List<AdminUserModel> users;
  final AdminUserPagination? pagination;

  AdminUserResponse({
    required this.users,
    required this.pagination,
  });

  factory AdminUserResponse.fromJson(Map<String, dynamic> json) {
    final rawUsers = json['users'];

    final users = rawUsers is List
        ? rawUsers
        .whereType<Map>()
        .map(
          (item) => AdminUserModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList()
        : <AdminUserModel>[];

    final rawPagination = json['pagination'];

    return AdminUserResponse(
      users: users,
      pagination: rawPagination is Map
          ? AdminUserPagination.fromJson(
        Map<String, dynamic>.from(rawPagination),
      )
          : null,
    );
  }
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