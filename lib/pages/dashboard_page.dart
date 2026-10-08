import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/currency_helper.dart';
import '../models/user_model.dart';
import '../providers/bonus_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/group_provider.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<DashboardProvider>().fetchDashboard();
      context.read<BonusProvider>().fetchBonus();

      if (widget.user.role == 'karyawan') {
        context.read<GroupProvider>().fetchGroups();
      }
    });
  }

  String _stringValue(dynamic value) {
    if (value == null) return '0';

    return value.toString();
  }

  double _numberValue(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String _currency(dynamic value) {
    return CurrencyHelper.format(_numberValue(value));
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Dashboard Admin';
      case 'karyawan':
        return 'Dashboard Karyawan';
      default:
        return 'Dashboard Member';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final bonusProvider = context.watch<BonusProvider>();
    final groupProvider = context.watch<GroupProvider>();

    final data = provider.data ?? {};

    final summary = data['summary'] is Map
        ? Map<String, dynamic>.from(data['summary'])
        : <String, dynamic>{};

    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'])
        : <String, dynamic>{};

    final bonus = bonusProvider.bonus;

    final totalBonus = bonus?.totalBonus ?? 0;
    final availableBonus = bonus?.availableBonus ?? 0;

    final karyawanTotalGroup = groupProvider.groups.length;

    final karyawanTotalMember = groupProvider.groups.fold<int>(
      0,
      (total, group) => total + group.memberCount,
    );

    final List<_StatItem> statItems = _getStatItems(
      summary: summary,
      data: data,
      totalBonus: totalBonus,
      availableBonus: availableBonus,
      karyawanTotalGroup: karyawanTotalGroup,
      karyawanTotalMember: karyawanTotalMember,
    );

    final isInitialLoading =
        provider.loading &&
        provider.data == null &&
        bonusProvider.loading &&
        bonusProvider.bonus == null;

    final hasDashboardError = provider.error != null && provider.data == null;

    final hasBonusError =
        bonusProvider.error != null && bonusProvider.bonus == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            provider.refresh(),
            bonusProvider.fetchBonus(),
            if (widget.user.role == 'karyawan') groupProvider.refresh(),
          ]);
        },
        color: AppColors.primary,
        child: SafeArea(
          child: isInitialLoading
              ? const _LoadingState()
              : hasDashboardError
              ? _ErrorState(
                  error: provider.error!,
                  onRetry: () async {
                    await provider.fetchDashboard();
                    await bonusProvider.fetchBonus();

                    if (widget.user.role == 'karyawan') {
                      await groupProvider.fetchGroups();
                    }
                  },
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _buildHeader(user['name']?.toString() ?? widget.user.name),
                    const SizedBox(height: 20),
                    _buildHeroCard(
                      roleLabel: _getRoleLabel(widget.user.role),
                      bonusValue: _currency(availableBonus),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Ringkasan Aktivitas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (hasBonusError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Data bonus belum dapat diperbarui.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: statItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.25,
                          ),
                      itemBuilder: (context, index) {
                        return _buildStatCard(statItems[index]);
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<_StatItem> _getStatItems({
    required Map<String, dynamic> summary,
    required Map<String, dynamic> data,
    required double totalBonus,
    required double availableBonus,
    required int karyawanTotalGroup,
    required int karyawanTotalMember,
  }) {
    if (widget.user.role == 'admin') {
      return [
        _StatItem(
          title: 'Total Pengguna',
          value: _stringValue(
            summary['total_users'] ??
                data['total_users'] ??
                data['users_count'],
          ),
          icon: Icons.people_outline_rounded,
        ),
        _StatItem(
          title: 'Total Group',
          value: _stringValue(
            summary['total_group'] ??
                data['total_group'] ??
                data['total_groups'] ??
                data['groups_count'],
          ),
          icon: Icons.grid_view_rounded,
        ),
        _StatItem(
          title: 'Total Bonus',
          value: _currency(totalBonus),
          icon: Icons.account_balance_wallet_outlined,
        ),
        _StatItem(
          title: 'Withdrawal Pending',
          value: _stringValue(
            summary['pending_withdrawals'] ?? data['pending_withdrawals'],
          ),
          icon: Icons.pending_actions_rounded,
        ),
      ];
    }

    if (widget.user.role == 'karyawan') {
      return [
        _StatItem(
          title: 'Total Group',
          value: karyawanTotalGroup.toString(),
          icon: Icons.grid_view_rounded,
        ),
        _StatItem(
          title: 'Total Member',
          value: karyawanTotalMember.toString(),
          icon: Icons.people_outline_rounded,
        ),
        _StatItem(
          title: 'Total Bonus',
          value: _currency(totalBonus),
          icon: Icons.account_balance_wallet_outlined,
        ),
        _StatItem(
          title: 'Bonus Tersedia',
          value: _currency(availableBonus),
          icon: Icons.payments_outlined,
        ),
      ];
    }

    return [
      _StatItem(
        title: 'Total Bonus',
        value: _currency(totalBonus),
        icon: Icons.account_balance_wallet_outlined,
      ),
      _StatItem(
        title: 'Bonus Line 1',
        value: _currency(context.read<BonusProvider>().bonus?.line1Bonus ?? 0),
        icon: Icons.person_add_alt_1_outlined,
      ),
      _StatItem(
        title: 'Bonus Line 2',
        value: _currency(context.read<BonusProvider>().bonus?.line2Bonus ?? 0),
        icon: Icons.account_tree_outlined,
      ),
      _StatItem(
        title: 'Bonus Tersedia',
        value: _currency(availableBonus),
        icon: Icons.payments_outlined,
      ),
    ];
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang 👋',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.text,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard({
    required String roleLabel,
    required String bonusValue,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      roleLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Bonus Tersedia',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      bonusValue,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;

  _StatItem({required this.title, required this.value, required this.icon});
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
