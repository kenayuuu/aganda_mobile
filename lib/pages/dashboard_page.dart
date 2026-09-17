import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_helper.dart';
import '../models/user_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_stat_card.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;

  const DashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  String _stringValue(dynamic value) {
    if (value == null) {
      return '0';
    }

    return value.toString();
  }

  double _numberValue(dynamic value) {
    if (value == null) {
      return 0;
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String _currency(dynamic value) {
    return CurrencyHelper.format(_numberValue(value));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final data = provider.data ?? {};

    final summary = data['summary'] is Map
        ? Map<String, dynamic>.from(data['summary'])
        : <String, dynamic>{};

    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'])
        : <String, dynamic>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: provider.loading && provider.data == null
            ?  ListView(
          children: [
            SizedBox(
              height: 400,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        )
            : provider.error != null && provider.data == null
            ? ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 150),
            const Icon(
              Icons.cloud_off,
              size: 60,
              color: AppColors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: provider.fetchDashboard,
              child: const Text('Coba Lagi'),
            ),
          ],
        )
            : ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 55, 20, 30),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang 👋',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['name']?.toString() ??
                            widget.user.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.role == 'admin'
                        ? 'Dashboard Admin'
                        : widget.user.role == 'karyawan'
                        ? 'Dashboard Karyawan'
                        : 'Dashboard Member',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currency(
                      summary['available_bonus'] ??
                          data['available_bonus'] ??
                          data['bonus'],
                    ),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Bonus Tersedia',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Ringkasan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            if (widget.user.role == 'admin') ...[
              DashboardStatCard(
                title: 'Total Pengguna',
                value: _stringValue(
                  summary['total_users'] ??
                      data['total_users'] ??
                      data['users_count'],
                ),
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 12),
              DashboardStatCard(
                title: 'Total Group',
                value: _stringValue(
                  summary['total_groups'] ??
                      data['total_groups'] ??
                      data['groups_count'],
                ),
                icon: Icons.groups_outlined,
              ),
              const SizedBox(height: 12),
              DashboardStatCard(
                title: 'Total Bonus',
                value: _currency(
                  summary['total_bonus'] ??
                      data['total_bonus'],
                ),
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 12),
              DashboardStatCard(
                title: 'Withdrawal Pending',
                value: _stringValue(
                  summary['pending_withdrawals'] ??
                      data['pending_withdrawals'],
                ),
                icon: Icons.pending_actions_outlined,
              ),
            ] else if (widget.user.role == 'karyawan') ...[
              DashboardStatCard(
                title: 'Total Group',
                value: _stringValue(
                  summary['total_groups'] ??
                      data['total_groups'] ??
                      data['groups_count'],
                ),
                icon: Icons.groups_outlined,
              ),
              const SizedBox(height: 12),
              DashboardStatCard(
                title: 'Total Member',
                value: _stringValue(
                  summary['total_members'] ??
                      data['total_members'] ??
                      data['members_count'],
                ),
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 12),
              DashboardStatCard(
                title: 'Total Bonus',
                value: _currency(
                  summary['total_bonus'] ??
                      data['total_bonus'],
                ),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ] else ...[
              DashboardStatCard(
                title: 'Total Bonus',
                value: _currency(
                  summary['total_bonus'] ??
                      data['total_bonus'],
                ),
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 12),
              DashboardStatCard(
                title: 'Bonus Line 1',
                value: _currency(
                  summary['line_1_bonus'] ??
                      data['line_1_bonus'],
                ),
                icon: Icons.person_add_alt_1_outlined,
              ),
              const SizedBox(height: 12),
              DashboardStatCard(
                title: 'Bonus Line 2',
                value: _currency(
                  summary['line_2_bonus'] ??
                      data['line_2_bonus'],
                ),
                icon: Icons.account_tree_outlined,
              ),
              const SizedBox(height: 12),
              DashboardStatCard(
                title: 'Bonus Tersedia',
                value: _currency(
                  summary['available_bonus'] ??
                      data['available_bonus'],
                ),
                icon: Icons.payments_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}