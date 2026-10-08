class GroupDetailModel {
  final int id;
  final String name;
  final String? status;
  final int? ownerId;
  final String? ownerName;
  final String? ownerMemberId;
  final String? ownerRole;
  final String? ownerAvatar;
  final int? packageId;
  final String? packageName;
  final double packagePrice;
  final double deposit;
  final String? packageDate;
  final int totalMembers;
  final String? createdAt;
  final List<GroupMemberModel> members;

  GroupDetailModel({
    required this.id,
    required this.name,
    this.status,
    this.ownerId,
    this.ownerName,
    this.ownerAvatar,
    this.ownerMemberId,
    this.ownerRole,
    this.packageId,
    this.packageName,
    required this.packagePrice,
    required this.deposit,
    this.packageDate,
    required this.totalMembers,
    this.createdAt,
    required this.members,
  });

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    final groupData = json['group'] is Map
        ? Map<String, dynamic>.from(json['group'])
        : <String, dynamic>{};

    final ownerData = groupData['owner'] is Map
        ? Map<String, dynamic>.from(groupData['owner'])
        : <String, dynamic>{};

    final packageData = groupData['package'] is Map
        ? Map<String, dynamic>.from(groupData['package'])
        : <String, dynamic>{};

    final membersData = json['members'] is List
        ? json['members'] as List
        : <dynamic>[];

    return GroupDetailModel(
      id: _toInt(groupData['id']),
      name: groupData['name']?.toString() ??
          groupData['kode_group']?.toString() ??
          'Group',
      status: groupData['status']?.toString(),
      ownerId: ownerData['id'] == null
          ? null
          : int.tryParse(ownerData['id'].toString()),
      ownerName: ownerData['name']?.toString(),
      ownerAvatar: ownerData['avatar']?.toString(),
      ownerMemberId: ownerData['member_id']?.toString(),
      ownerRole: ownerData['role']?.toString(),
      packageId: _toNullableInt(packageData['id']),
      packageName: packageData['name']?.toString(),
      packagePrice: _toDouble(packageData['harga']),
      deposit: _toDouble(packageData['deposit']),
      packageDate: packageData['tanggal_berlangsung']?.toString(),
      totalMembers: _toInt(groupData['total_members']),
      createdAt: groupData['created_at']?.toString(),
      members: membersData
          .whereType<Map>()
          .map(
            (item) => GroupMemberModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
}

class GroupMemberModel {
  final int id;
  final int? calonId;
  final String? status;
  final int? registeredBy;
  final String? registeredByName;
  final String? name;
  final String? email;
  final String? phone;
  final String? memberId;
  final String? avatar;

  GroupMemberModel({
    required this.id,
    this.calonId,
    this.status,
    this.registeredBy,
    this.registeredByName,
    this.name,
    this.email,
    this.phone,
    this.memberId,
    this.avatar,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final calonData = json['calon'] is Map
        ? Map<String, dynamic>.from(json['calon'])
        : <String, dynamic>{};

    final registeredByData = json['registered_by_user'] is Map
        ? Map<String, dynamic>.from(json['registered_by_user'])
        : <String, dynamic>{};

    return GroupMemberModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      calonId: json['calon_id'] == null
          ? null
          : int.tryParse(json['calon_id'].toString()),
      status: json['status']?.toString(),
      registeredBy: json['registered_by'] == null
          ? null
          : int.tryParse(json['registered_by'].toString()),
      registeredByName: registeredByData['name']?.toString(),
      name: calonData['nama_lengkap']?.toString() ??
          calonData['nama']?.toString() ??
          calonData['name']?.toString(),
      email: calonData['email']?.toString(),
      phone: calonData['no_telepon']?.toString() ??
          calonData['no_hp']?.toString() ??
          calonData['phone']?.toString(),
      memberId: calonData['member_id']?.toString(),
      avatar: calonData['avatar']?.toString(),
    );
  }
}