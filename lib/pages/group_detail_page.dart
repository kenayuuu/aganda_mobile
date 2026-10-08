import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/group_detail_model.dart';
import '../providers/group_detail_provider.dart';
import 'structure_page.dart';
import '../../core/constants/app_config.dart';

class GroupDetailPage extends StatefulWidget {
  final int groupId;

  const GroupDetailPage({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late final GroupDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = GroupDetailProvider();
    _provider.fetchGroup(widget.groupId);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  String _currency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _initial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'lunas':
      case 'berhasil':
        return Colors.green.shade600;
      case 'pending':
      case 'proses':
        return Colors.orange.shade700;
      case 'cancelled':
      case 'batal':
        return Colors.red.shade600;
      default:
        return AppColors.aganda600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Detail Group',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _provider,
        builder: (context, child) {
          if (_provider.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (_provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 180,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _provider.fetchGroup(widget.groupId);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final group = _provider.group;

          if (group == null) {
            return const Center(
              child: Text(
                'Data group tidak ditemukan.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _provider.refresh(widget.groupId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _groupHeader(group),
                const SizedBox(height: 16),
                _buildLeaderCard(group),
                const SizedBox(height: 16),
                _buildStructureButton(group.id),
                const SizedBox(height: 16),
                _packageCard(group),
                const SizedBox(height: 16),
                _memberCard(group),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _groupHeader(GroupDetailModel group) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.aganda500,
            AppColors.aganda700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.aganda900.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: AppColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${group.totalMembers} Anggota',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructureButton(int groupId) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.aganda600.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StructurePage(groupId: groupId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.aganda600,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.account_tree_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Lihat Struktur Group',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderCard(GroupDetailModel group) {
    String? avatarUrl;

    final avatar = group.ownerAvatar?.trim();

    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('http://') ||
          avatar.startsWith('https://')) {
        avatarUrl = avatar;
      } else if (avatar.startsWith('/storage/')) {
        avatarUrl = '${AppConfig.storageUrl}${avatar.substring(8)}';
      } else if (avatar.startsWith('storage/')) {
        avatarUrl = '${AppConfig.storageUrl}/${avatar.substring(8)}';
      } else if (avatar.startsWith('/')) {
        avatarUrl = '${AppConfig.storageUrl}$avatar';
      } else {
        avatarUrl = '${AppConfig.storageUrl}/$avatar';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.aganda200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.aganda900.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.aganda100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: avatarUrl != null
                ? Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const Icon(
                  Icons.person,
                  color: AppColors.aganda600,
                  size: 28,
                );
              },
            )
                : const Icon(
              Icons.person,
              color: AppColors.aganda600,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ketua Group',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  group.ownerName ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.aganda50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              size: 18,
              color: AppColors.aganda600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageCard(GroupDetailModel group) {
    final statusColor = _getStatusColor(group.status);

    return _sectionCard(
      title: 'Informasi Paket',
      icon: Icons.card_travel_rounded,
      children: [
        _infoRow('Nama Paket', group.packageName ?? '-'),
        const Divider(height: 20, color: AppColors.aganda100),
        _infoRow(
          'Harga Paket',
          _currency(group.packagePrice),
          valueStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(height: 20, color: AppColors.aganda100),
        _infoRow(
          'DP (Uang Muka)',
          _currency(group.deposit),
          valueStyle: const TextStyle(
            color: AppColors.aganda700,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(height: 20, color: AppColors.aganda100),
        _infoRow('Tanggal Paket', group.packageDate ?? '-'),
        const Divider(height: 20, color: AppColors.aganda100),
        _infoRowWidget(
          'Status',
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              group.status ?? '-',
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _memberCard(GroupDetailModel group) {
    return _sectionCard(
      title: 'Daftar Anggota',
      icon: Icons.people_alt_rounded,
      children: [
        if (group.members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum ada anggota terdaftar.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...group.members.asMap().entries.map(
                (entry) => _memberItem(
              entry.key + 1,
              entry.value,
            ),
          ),
      ],
    );
  }

  Widget _memberItem(int number, GroupMemberModel member) {
    final statusColor = _getStatusColor(member.status);

    String? getAvatarUrl() {
      final avatar = member.avatar?.trim();

      if (avatar == null || avatar.isEmpty) {
        return null;
      }

      if (avatar.startsWith('http://') ||
          avatar.startsWith('https://')) {
        return avatar;
      }

      if (avatar.startsWith('/storage/')) {
        return '${AppConfig.storageUrl}${avatar.substring(8)}';
      }

      if (avatar.startsWith('storage/')) {
        return '${AppConfig.storageUrl}/${avatar.substring(8)}';
      }

      if (avatar.startsWith('/')) {
        return '${AppConfig.storageUrl}$avatar';
      }

      return '${AppConfig.storageUrl}/$avatar';
    }

    final avatarUrl = getAvatarUrl();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.aganda200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.aganda900.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Icon(
                    Icons.person,
                    size: 24,
                    color: AppColors.grey,
                  );
                },
              )
                  : const Icon(
                Icons.person,
                size: 24,
                color: AppColors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        member.phone ?? member.email ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                if (member.registeredByName != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.aganda50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Direkrut oleh: ${member.registeredByName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.aganda600,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (member.status != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.status!,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.aganda200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.aganda900.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.aganda50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.aganda600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
      String label,
      String value, {
        TextStyle? valueStyle,
      }) {
    return _infoRowWidget(
      label,
      Text(
        value,
        textAlign: TextAlign.end,
        style: valueStyle ??
            const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _infoRowWidget(String label, Widget child) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        child,
      ],
    );
  }
}