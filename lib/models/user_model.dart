import '../core/constants/app_config.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final String? phone;
  final String? address;
  final int? parentId;
  final int? calonId;
  final String? memberId;

  UserModel({
    required this.id,
    required this.name,
    this.avatar,
    required this.role,
    this.phone,
    this.address,
    this.parentId,
    this.calonId,
    this.memberId, required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(
        json['id']?.toString() ?? '0',
      ) ??
          0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString() ?? 'member',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      parentId: json['parent_id'] == null
          ? null
          : int.tryParse(
        json['parent_id'].toString(),
      ),
      calonId: json['calon_id'] == null
          ? null
          : int.tryParse(
        json['calon_id'].toString(),
      ),
      memberId: json['member_id']?.toString(),
    );
  }

  String? get avatarUrl {
    if (avatar == null || avatar!.isEmpty) {
      return null;
    }

    if (avatar!.startsWith('http://') ||
        avatar!.startsWith('https://')) {
      return avatar;
    }

    if (avatar!.startsWith('/storage/')) {
      return '${AppConfig.storageUrl}${avatar!.substring(8)}';
    }

    if (avatar!.startsWith('storage/')) {
      return '${AppConfig.storageUrl}/${avatar!.substring(8)}';
    }

    if (avatar!.startsWith('/')) {
      return '${AppConfig.storageUrl}${avatar!}';
    }

    return '${AppConfig.storageUrl}/$avatar';
  }
}