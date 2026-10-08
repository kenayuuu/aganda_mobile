import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/group_provider.dart';
import 'group_detail_page.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({
    super.key,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GroupProvider>().fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.aganda500,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Group',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.aganda500,
        onRefresh: provider.refresh,
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(GroupProvider provider) {
    if (provider.loading && provider.groups.isEmpty) {
      return ListView(
        children: const [
          SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.aganda500,
              ),
            ),
          ),
        ],
      );
    }

    if (provider.error != null && provider.groups.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 130),
          const Icon(
            Icons.cloud_off_outlined,
            size: 60,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: provider.fetchGroups,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aganda500,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    if (provider.groups.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Icon(
            Icons.groups_outlined,
            size: 64,
            color: AppColors.aganda300,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Belum ada group',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 6),
          Center(
            child: Text(
              'Group yang tersedia akan tampil di sini.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Container(
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
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: AppColors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Group Saya',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${provider.groups.length} group tersedia',
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
        ),
        const SizedBox(height: 22),
        const Text(
          'Daftar Group',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        ...provider.groups.map(
              (group) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GroupCard(group: group),
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final dynamic group;

  const _GroupCard({
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupDetailPage(
                groupId: group.id,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.aganda200,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.aganda900.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.aganda100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.groups,
                  color: AppColors.aganda600,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (group.ownerName != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Owner: ${group.ownerName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 15,
                          color: AppColors.aganda500,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${group.memberCount} member',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right,
                color: AppColors.aganda500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}