import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/bonus_model.dart';
import '../providers/bonus_provider.dart';
import '../providers/withdrawal_provider.dart';

class BonusPage extends StatefulWidget {
  const BonusPage({super.key});

  @override
  State<BonusPage> createState() => _BonusPageState();
}

class _BonusPageState extends State<BonusPage> with WidgetsBindingObserver {
  int _historyCurrentPage = 1;

  static const int _historyItemsPerPage = 5;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final bonusProvider = context.read<BonusProvider>();
    final withdrawalProvider = context.read<WithdrawalProvider>();

    await Future.wait([
      bonusProvider.fetchBonus(),
      withdrawalProvider.fetchWithdrawals(),
    ]);

    if (!mounted) return;

    setState(() {
      _historyCurrentPage = 1;
    });
  }

  Future<void> _refresh() async {
    await _loadData();
  }

  String _currency(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '0') ?? 0;

    return _currencyFormat.format(amount);
  }

  String _date(String? date) {
    if (date == null || date.isEmpty) {
      return '-';
    }

    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) {
      return date;
    }

    return DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ).format(parsedDate.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          backgroundColor: AppColors.white,
          child: Consumer2<BonusProvider, WithdrawalProvider>(
            builder: (context, bonusProvider, withdrawalProvider, child) {
              if (bonusProvider.loading && bonusProvider.bonus == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (bonusProvider.error != null && bonusProvider.bonus == null) {
                return _buildErrorView(bonusProvider.error!);
              }

              final bonus = bonusProvider.bonus;

              if (bonus == null) {
                return const Center(
                  child: Text(
                    'Data bonus belum tersedia.',
                    style: TextStyle(color: AppColors.grey),
                  ),
                );
              }

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildTotalBonusCard(bonus),
                  const SizedBox(height: 20),
                  _buildBonusDetailCard(bonus),
                  const SizedBox(height: 20),
                  _buildWithdrawalCard(withdrawalProvider),
                  const SizedBox(height: 24),
                  _buildHistorySection(bonus, withdrawalProvider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Bonus',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Bonus & Komisi',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          elevation: 1,
          shadowColor: AppColors.primaryDark.withOpacity(0.08),
          child: InkWell(
            onTap: _refresh,
            borderRadius: BorderRadius.circular(14),
            splashColor: AppColors.primary.withOpacity(0.15),
            highlightColor: AppColors.primary.withOpacity(0.08),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryDark,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBonusCard(BonusModel bonus) {
    final availableBonus = bonus.availableBonus;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.aganda400,
            AppColors.aganda500,
            AppColors.aganda700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold300.withOpacity(0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 16,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Total Akumulasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currency(availableBonus),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold300.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tersedia: '
                        '${_currency(availableBonus)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
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

  Widget _buildBonusDetailCard(BonusModel bonus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.03),
            blurRadius: 12,
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
                  color: AppColors.aganda100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rincian Komisi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailItem(
            'Bonus Line 1',
            _currency(bonus.line1Bonus),
            icon: Icons.group_add_outlined,
          ),
          _buildDetailItem(
            'Bonus Line 2',
            _currency(bonus.line2Bonus),
            icon: Icons.groups_outlined,
          ),
          _buildDetailItem(
            'Bonus Penyesuaian',
            _currency(bonus.adjustmentBonus),
            icon: Icons.tune_rounded,
          ),
          _buildDetailItem(
            'Bonus Dialokasikan',
            _currency(bonus.totalAllocated),
            icon: Icons.pie_chart_outline_rounded,
            isDeduction: true,
          ),
          _buildDetailItem(
            'Pembayaran Paket',
            _currency(bonus.packagePayment),
            icon: Icons.card_travel_rounded,
            isDeduction: true,
          ),
          _buildDetailItem(
            'Pencairan Bonus',
            _currency(bonus.withdrawalAllocation),
            icon: Icons.outbox_rounded,
            isDeduction: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.aganda50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Sisa Bonus',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _currency(bonus.availableBonus),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String title,
    String value, {
    required IconData icon,
    bool isDeduction = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.grey,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDeduction
                    ? AppColors.error
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildWithdrawalCard(WithdrawalProvider provider) {
    final available = provider.availableForWithdrawal;

    final canWithdraw = provider.canWithdraw;

    final pendingWithdrawal = provider.pendingWithdrawal;

    final isPackagePaidOff = provider.isPackagePaidOff;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pencairan Bonus',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.aganda100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.aganda50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.aganda100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bonus Siap Dicairkan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currency(available),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (pendingWithdrawal > 0) ...[
            _buildInfoBanner(
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
              text:
                  'Pengajuan pencairan sebesar '
                  '${_currency(pendingWithdrawal)} '
                  'sedang diverifikasi oleh admin.',
            ),
            const SizedBox(height: 14),
          ],
          if (!canWithdraw &&
              !isPackagePaidOff &&
              pendingWithdrawal <= 0 &&
              available > 0) ...[
            _buildInfoBanner(
              icon: Icons.lock_clock_rounded,
              color: AppColors.gold600,
              text:
                  'Pencairan bonus akan terbuka setelah '
                  'paket Umroh Anda dinyatakan lunas.',
            ),
            const SizedBox(height: 14),
          ],
          if (available <= 0 && pendingWithdrawal <= 0) ...[
            _buildInfoBanner(
              icon: Icons.info_outline_rounded,
              color: AppColors.grey,
              text:
                  'Belum ada saldo bonus yang memenuhi '
                  'syarat pencairan.',
            ),
            const SizedBox(height: 14),
          ],
          if (canWithdraw)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: provider.submitting
                    ? null
                    : () => _showWithdrawalDialog(context, provider, available),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.aganda300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: provider.submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ajukan Pencairan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    final isGold = color == AppColors.warning || color == AppColors.gold600;

    final backgroundColor = isGold
        ? AppColors.gold300.withOpacity(0.18)
        : color.withOpacity(0.08);

    final borderColor = isGold
        ? AppColors.gold400.withOpacity(0.5)
        : color.withOpacity(0.25);

    final iconColor = isGold ? AppColors.gold700 : color;

    final textColor = isGold ? AppColors.gold700 : color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    BonusModel bonus,
    WithdrawalProvider withdrawalProvider,
  ) {
    final histories = <_HistoryItem>[];

    for (final item in bonus.bonusHistory) {
      histories.add(
        _HistoryItem(
          date: item.createdAt,
          title: 'Bonus Masuk',
          subtitle: item.description ?? 'Bonus diterima',
          amount: item.amount,
          positive: true,
        ),
      );
    }

    for (final item in bonus.allocationHistory) {
      histories.add(
        _HistoryItem(
          date: item.createdAt,
          title: _allocationTitle(item.type),
          subtitle: item.notes ?? 'Bonus dialokasikan',
          amount: item.amount,
          positive: false,
        ),
      );
    }

    for (final withdrawal in withdrawalProvider.withdrawals) {
      final isPaid = withdrawal.status.toLowerCase() == 'paid';

      if (isPaid) {
        continue;
      }

      histories.add(
        _HistoryItem(
          date: withdrawal.requestedAt != null
              ? withdrawal.requestedAt!.toIso8601String()
              : withdrawal.processedAt?.toIso8601String(),
          title: 'Pengajuan Pencairan',
          subtitle: 'Status: ${withdrawal.statusLabel}',
          amount: withdrawal.amount,
          positive: false,
          isPending: true,
        ),
      );
    }

    histories.sort((a, b) {
      final aDate = a.date != null ? DateTime.tryParse(a.date!) : null;

      final bDate = b.date != null ? DateTime.tryParse(b.date!) : null;

      final safeA = aDate ?? DateTime(2000);

      final safeB = bDate ?? DateTime(2000);

      return safeB.compareTo(safeA);
    });

    final totalPages = (histories.length / _historyItemsPerPage).ceil();

    if (totalPages == 0) {
      if (_historyCurrentPage != 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          setState(() {
            _historyCurrentPage = 1;
          });
        });
      }
    } else if (_historyCurrentPage > totalPages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _historyCurrentPage = totalPages;
        });
      });
    }

    final startIndex = (_historyCurrentPage - 1) * _historyItemsPerPage;

    final safeStartIndex = startIndex.clamp(0, histories.length);

    final safeEndIndex = (safeStartIndex + _historyItemsPerPage).clamp(
      0,
      histories.length,
    );

    final currentHistories = histories.isEmpty
        ? <_HistoryItem>[]
        : histories.sublist(safeStartIndex, safeEndIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        if (histories.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 40,
                  color: AppColors.aganda300,
                ),
                SizedBox(height: 10),
                Text(
                  'Belum ada riwayat transaksi.',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentHistories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildHistoryCard(currentHistories[index]);
            },
          ),
          if (totalPages > 1) ...[
            const SizedBox(height: 18),
            _buildHistoryPagination(totalPages),
          ],
        ],
      ],
    );
  }

  Widget _buildHistoryPagination(int totalPages) {
    final pages = <int>[];

    if (totalPages <= 5) {
      pages.addAll(
        List.generate(totalPages, (index) => index + 1),
      );
    } else {
      pages.add(1);

      if (_historyCurrentPage > 3) {
        pages.add(-1);
      }

      final start = (_historyCurrentPage - 1).clamp(2, totalPages - 2);
      final end = (_historyCurrentPage + 1).clamp(3, totalPages - 1);

      for (int page = start; page <= end; page++) {
        if (!pages.contains(page)) {
          pages.add(page);
        }
      }

      if (_historyCurrentPage < totalPages - 2) {
        pages.add(-1);
      }

      if (!pages.contains(totalPages)) {
        pages.add(totalPages);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageButton(
          icon: Icons.chevron_left_rounded,
          enabled: _historyCurrentPage > 1,
          onTap: _historyCurrentPage > 1
              ? () {
            setState(() {
              _historyCurrentPage--;
            });
          }
              : null,
        ),

        const SizedBox(width: 6),

        ...pages.map(
              (page) {
            if (page == -1) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _buildPageNumber(
                page: page,
                isActive: page == _historyCurrentPage,
                onTap: () {
                  if (_historyCurrentPage == page) return;

                  setState(() {
                    _historyCurrentPage = page;
                  });
                },
              ),
            );
          },
        ),

        const SizedBox(width: 6),

        _buildPageButton(
          icon: Icons.chevron_right_rounded,
          enabled: _historyCurrentPage < totalPages,
          onTap: _historyCurrentPage < totalPages
              ? () {
            setState(() {
              _historyCurrentPage++;
            });
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildPageNumber({
    required int page,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Material(
        color: isActive ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              page.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Material(
        color: enabled ? AppColors.surface : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: enabled ? AppColors.textPrimary : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }

  String _allocationTitle(String type) {
    switch (type) {
      case 'package_payment':
        return 'Pembayaran Paket';
      case 'withdrawal':
        return 'Pencairan Bonus';
      default:
        return 'Alokasi Bonus';
    }
  }

  Widget _buildHistoryCard(_HistoryItem item) {
    final iconBackground = item.positive
        ? AppColors.aganda100
        : item.isPending
        ? AppColors.gold300.withOpacity(0.22)
        : AppColors.aganda50;

    final iconColor = item.positive
        ? AppColors.primary
        : item.isPending
        ? AppColors.gold700
        : AppColors.primaryDark;

    final amountColor = item.positive
        ? AppColors.primary
        : item.isPending
        ? AppColors.gold700
        : AppColors.textPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.positive
                  ? Icons.south_west_rounded
                  : item.isPending
                  ? Icons.hourglass_top_rounded
                  : Icons.north_east_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Bagian informasi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _date(item.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.aganda300,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Nominal dipindahkan ke bawah agar tidak overflow
                const SizedBox(height: 6),
                Text(
                  '${item.positive ? '+' : '-'}${_currency(item.amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Gagal Memuat Data',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.grey, fontSize: 14),
        ),
        const SizedBox(height: 28),
        Center(
          child: ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showWithdrawalDialog(
    BuildContext context,
    WithdrawalProvider provider,
    double available,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _WithdrawalDialog(
          available: available,
          currency: _currency,
          onSubmit: (amount) async {
            final success = await provider.createWithdrawal(amount);

            if (!context.mounted) return;

            if (success) {
              Navigator.of(context).pop();

              await Future.wait([
                context.read<BonusProvider>().fetchBonus(),
                context.read<WithdrawalProvider>().fetchWithdrawals(),
              ]);

              if (!context.mounted) return;

              setState(() {
                _historyCurrentPage = 1;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Pengajuan pencairan berhasil dikirim.'),
                  backgroundColor: AppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error ?? 'Pengajuan pencairan gagal.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _WithdrawalDialog extends StatefulWidget {
  final double available;
  final String Function(dynamic) currency;
  final Future<void> Function(double amount) onSubmit;

  const _WithdrawalDialog({
    required this.available,
    required this.currency,
    required this.onSubmit,
  });

  @override
  State<_WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<_WithdrawalDialog> {
  final TextEditingController _amountController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount {
    return double.tryParse(
          _amountController.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final amount = _amount;

    if (amount <= 0) {
      _showError('Nominal pencairan harus lebih dari 0.');
      return;
    }

    if (amount > widget.available) {
      _showError('Nominal pencairan melebihi bonus yang tersedia.');
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await widget.onSubmit(amount);
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ajukan Pencairan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textPrimary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.gold300.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold400.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maksimal yang dapat dicairkan',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gold700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.currency(widget.available),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Nominal Penarikan',
                labelStyle: const TextStyle(color: AppColors.grey),
                hintText: '0',
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                suffixIcon: IconButton(
                  icon: const Text(
                    'MAX',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  onPressed: () {
                    _amountController.text = widget.available
                        .toInt()
                        .toString();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.grey,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pengajuan akan ditinjau oleh admin.',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.aganda300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Kirim',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem {
  final String? date;
  final String title;
  final String subtitle;
  final double amount;
  final bool positive;
  final bool isPending;

  _HistoryItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.positive,
    this.isPending = false,
  });
}
