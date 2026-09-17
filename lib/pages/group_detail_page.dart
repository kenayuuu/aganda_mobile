import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/group_detail_model.dart';
import '../providers/group_detail_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Detail Group',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
                    const Icon(
                      Icons.cloud_off,
                      size: 55,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _provider.fetchGroup(widget.groupId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Coba Lagi'),
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
              children: [
                _groupHeader(group),
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
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.aganda900.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${group.totalMembers} anggota',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageCard(GroupDetailModel group) {
    return _sectionCard(
      title: 'Informasi Paket',
      icon: Icons.card_travel,
      children: [
        _infoRow(
          'Paket',
          group.packageName ?? '-',
        ),
        _infoRow(
          'Harga Paket',
          _currency(group.packagePrice),
        ),
        _infoRow(
          'DP',
          _currency(group.deposit),
        ),
        _infoRow(
          'Tanggal',
          group.packageDate ?? '-',
        ),
        _infoRow(
          'Status',
          group.status ?? '-',
        ),
      ],
    );
  }

  Widget _memberCard(GroupDetailModel group) {
    return _sectionCard(
      title: 'Anggota Group',
      icon: Icons.people,
      children: [
        if (group.members.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Belum ada anggota.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
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

  Widget _memberItem(
      int number,
      GroupMemberModel member,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.aganda50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.aganda200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.aganda100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppColors.aganda700,
                  fontWeight: FontWeight.bold,
                ),
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  member.phone ?? member.email ?? '-',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (member.registeredByName != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Didaftarkan oleh ${member.registeredByName}',
                    style: const TextStyle(
                      color: AppColors.aganda600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (member.status != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.aganda100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                member.status!,
                style: const TextStyle(
                  color: AppColors.aganda700,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.aganda200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.aganda900.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.aganda600,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}