import '../core/constants/app_config.dart';
class StructureModel {
    final StructureUserModel user;
    final int line;
    final String type;
    final StructureBonusModel bonus;
    final StructureRewardModel reward;
    StructurePairModel? pair;
    final List<StructureModel> children;
    final double commission;
    final bool pairable;
    final bool adminClickable;
    final bool adminView;
    final String? adminUrl;
    final String? recruiterName;
  
    StructureModel({
      required this.user,
      required this.line,
      required this.type,
      required this.bonus,
      required this.reward,
      this.pair,
      required this.children,
      required this.commission,
      required this.pairable,
      required this.adminClickable,
      required this.adminView,
      this.adminUrl,
      this.recruiterName,
    });
  
    factory StructureModel.fromJson(
        Map<String, dynamic> json,
        ) {
      final userData = json['user'] is Map
          ? Map<String, dynamic>.from(
        json['user'] as Map,
      )
          : <String, dynamic>{};
  
      final bonusData = json['bonus'] is Map
          ? Map<String, dynamic>.from(
        json['bonus'] as Map,
      )
          : <String, dynamic>{};
  
      final rewardData = json['reward'] is Map
          ? Map<String, dynamic>.from(
        json['reward'] as Map,
      )
          : <String, dynamic>{};
  
      final pairData = json['pair'] is Map
          ? Map<String, dynamic>.from(
        json['pair'] as Map,
      )
          : null;
  
      final recruiterData =
      json['recruiter'] is Map
          ? Map<String, dynamic>.from(
        json['recruiter'] as Map,
      )
          : null;
  
      final childrenData = json['children'] is List
          ? json['children'] as List
          : <dynamic>[];
  
      return StructureModel(
        user: StructureUserModel.fromJson(
          userData,
        ),
        line: _toInt(
          json['line'],
        ),
        type: _toString(
          json['type'],
          'member',
        ),
        bonus: StructureBonusModel.fromJson(
          bonusData,
        ),
        reward: StructureRewardModel.fromJson(
          rewardData,
        ),
        pair: pairData == null
            ? null
            : StructurePairModel.fromJson(
          pairData,
        ),
        children: childrenData
            .whereType<Map>()
            .map(
              (item) => StructureModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList(),
        commission: _toDouble(
          json['commission'],
        ),
        pairable: _toBool(
          json['pairable'],
        ),
        adminClickable: _toBool(
          json['admin_clickable'],
        ),
        adminView: _toBool(
          json['admin_view'],
        ),
        adminUrl: _nullableString(
          json['admin_url'],
        ),
        recruiterName:
        recruiterData == null
            ? null
            : _nullableString(
          recruiterData['name'],
        ),
      );
    }
  
    static String _toString(
        dynamic value,
        String fallback,
        ) {
      if (value == null) {
        return fallback;
      }
  
      final result = value.toString().trim();
  
      if (result.isEmpty ||
          result.toLowerCase() == 'null') {
        return fallback;
      }
  
      return result;
    }
  
    static String? _nullableString(
        dynamic value,
        ) {
      if (value == null) {
        return null;
      }
  
      final result = value.toString().trim();
  
      if (result.isEmpty ||
          result.toLowerCase() == 'null') {
        return null;
      }
  
      return result;
    }
  
    static int _toInt(dynamic value) {
      if (value == null) {
        return 0;
      }
  
      if (value is int) {
        return value;
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
  
    static bool _toBool(
        dynamic value,
        ) {
      if (value is bool) {
        return value;
      }
  
      if (value is num) {
        return value != 0;
      }
  
      if (value is String) {
        final normalized =
        value.toLowerCase().trim();
  
        return normalized == 'true' ||
            normalized == '1';
      }
  
      return false;
    }
  }

class StructureUserModel {
  final int id;
  final String name;
  final String? memberId;
  final String? email;
  final String? phone;
  final String? role;
  final String? avatar;
  final int? calonId;
  final int? parentId;

  StructureUserModel({
    required this.id,
    required this.name,
    this.memberId,
    this.email,
    this.phone,
    this.role,
    this.avatar,
    this.calonId,
    this.parentId,
  });

  factory StructureUserModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StructureUserModel(
      id: _toInt(
        json['id'],
      ),
      name: _toString(
        json['name'],
        '-',
      ),
      memberId: _nullableString(
        json['member_id'],
      ),
      email: _nullableString(
        json['email'],
      ),
      phone: _nullableString(
        json['phone'],
      ),
      role: _nullableString(
        json['role'],
      ),
      avatar: _nullableString(
        json['avatar'],
      ),
      calonId: _nullableInt(
        json['calon_id'],
      ),
      parentId: _nullableInt(
        json['parent_id'],
      ),
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

  static String _toString(
      dynamic value,
      String fallback,
      ) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    if (result.isEmpty ||
        result.toLowerCase() == 'null') {
      return fallback;
    }

    return result;
  }

  static String? _nullableString(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty ||
        result.toLowerCase() == 'null') {
      return null;
    }

    return result;
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    ) ??
        0;
  }

  static int? _nullableInt(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    return int.tryParse(
      value.toString(),
    );
  }
}
  
  class StructureBonusModel {
    final double total;
    final double line1;
    final double line2Pairing;
  
    StructureBonusModel({
      required this.total,
      required this.line1,
      required this.line2Pairing,
    });
  
    factory StructureBonusModel.fromJson(
        Map<String, dynamic> json,
        ) {
      return StructureBonusModel(
        total: _toDouble(
          json['total'],
        ),
        line1: _toDouble(
          json['line_1'],
        ),
        line2Pairing: _toDouble(
          json['line_2_pairing'],
        ),
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
  
  class StructureRewardModel {
    final double total;
  
    StructureRewardModel({
      required this.total,
    });
  
    factory StructureRewardModel.fromJson(
        Map<String, dynamic> json,
        ) {
      return StructureRewardModel(
        total: _toDouble(
          json['total'],
        ),
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
  
  class StructurePairModel {
    final int id;
    final double bonusAmount;
    final String? position;
    final int? leftMemberId;
    final int? rightMemberId;
  
    StructurePairModel({
      required this.id,
      required this.bonusAmount,
      this.position,
      this.leftMemberId,
      this.rightMemberId,
    });
  
    factory StructurePairModel.fromJson(
        Map<String, dynamic> json,
        ) {
      return StructurePairModel(
        id: _toInt(
          json['id'],
        ),
        bonusAmount: _toDouble(
          json['bonus_amount'],
        ),
        position: _nullableString(
          json['position'],
        ),
        leftMemberId: _nullableInt(
          json['left_member_id'],
        ),
        rightMemberId: _nullableInt(
          json['right_member_id'],
        ),
      );
    }
  
    static int _toInt(dynamic value) {
      if (value == null) {
        return 0;
      }
  
      if (value is int) {
        return value;
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
  
    static String? _nullableString(
        dynamic value,
        ) {
      if (value == null) {
        return null;
      }
  
      final result = value.toString().trim();
  
      if (result.isEmpty ||
          result.toLowerCase() == 'null') {
        return null;
      }
  
      return result;
    }
  
    static int? _nullableInt(
        dynamic value,
        ) {
      if (value == null) {
        return null;
      }
  
      return int.tryParse(
        value.toString(),
      );
    }
  }
  
  class StructureResponseModel {
    final Map<String, dynamic> group;
    final Map<String, dynamic> perspective;
    final StructureModel? structure;
  
    StructureResponseModel({
      required this.group,
      required this.perspective,
      this.structure,
    });
  
    factory StructureResponseModel.fromJson(
        Map<String, dynamic> json,
        ) {
      final groupData = json['group'] is Map
          ? Map<String, dynamic>.from(
        json['group'] as Map,
      )
          : <String, dynamic>{};
  
      final perspectiveData =
      json['perspective'] is Map
          ? Map<String, dynamic>.from(
        json['perspective'] as Map,
      )
          : <String, dynamic>{};
  
      final structureData =
      json['structure'] is Map
          ? Map<String, dynamic>.from(
        json['structure'] as Map,
      )
          : null;
  
      return StructureResponseModel(
        group: groupData,
        perspective: perspectiveData,
        structure: structureData == null
            ? null
            : StructureModel.fromJson(
          structureData,
        ),
      );
    }
  }