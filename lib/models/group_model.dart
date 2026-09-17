class GroupModel {
  final int id;
  final String name;
  final String? description;
  final int? ownerId;
  final String? ownerName;
  final int memberCount;
  final String? kodeGroup;
  final String? status;
  final Map<String, dynamic>? package;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.ownerId,
    this.ownerName,
    required this.memberCount,
    this.kodeGroup,
    this.status,
    this.package,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final ownerData = json['owner'];
    final packageData = json['package'];

    Map<String, dynamic>? owner;
    Map<String, dynamic>? package;

    if (ownerData is Map) {
      owner = Map<String, dynamic>.from(ownerData);
    }

    if (packageData is Map) {
      package = Map<String, dynamic>.from(packageData);
    }

    return GroupModel(
      id: int.tryParse(
        json['id']?.toString() ?? '0',
      ) ??
          0,
      name: json['kode_group']?.toString() ?? 'Group',
      description: json['description']?.toString() ??
          json['deskripsi']?.toString(),
      ownerId: owner?['id'] == null
          ? null
          : int.tryParse(owner!['id'].toString()),
      ownerName: owner?['name']?.toString(),
      memberCount: int.tryParse(
        json['total_members']?.toString() ?? '0',
      ) ??
          0,
      kodeGroup: json['kode_group']?.toString(),
      status: json['status']?.toString(),
      package: package,
    );
  }
}