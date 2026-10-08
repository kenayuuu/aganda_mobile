import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/bonus_history_model.dart';
import '../providers/bonus_history_provider.dart';

class BonusHistoryPage extends StatefulWidget {
  const BonusHistoryPage({super.key});

  @override
  State<BonusHistoryPage> createState() => _BonusHistoryPageState();
}

class _BonusHistoryPageState extends State<BonusHistoryPage> {
  late final BonusHistoryProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = BonusHistoryProvider();
    _provider.fetchHistory();
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

  String _date(DateTime? value) {
    if (value == null) {
      return '-';
    }

    return DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ).format(value.toLocal());
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
          'Riwayat Bonus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _provider,
        builder: (context, child) {
          if (_provider.loading && _provider.histories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (_provider.error != null &&
              _provider.histories.isEmpty) {
            return _errorView();
          }

          if (_provider.histories.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _provider.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text(
                      'Belum ada riwayat bonus.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _provider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _provider.histories.length,
              itemBuilder: (context, index) {
                final history = _provider.histories[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _historyCard(history),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _historyCard(BonusHistoryModel history) {
    final isPositive = history.status == 'confirmed';
    final isReversed = history.status == 'reversed' ||
        history.status == 'cancelled';

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
            color: AppColors.aganda900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isReversed
                      ? AppColors.gold300.withValues(alpha: 0.4)
                      : AppColors.aganda100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isReversed
                      ? Icons.undo
                      : Icons.account_balance_wallet,
                  color: isReversed
                      ? AppColors.gold700
                      : AppColors.aganda600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.typeLabel,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _date(history.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${_currency(history.amount)}',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: isPositive
                      ? AppColors.aganda600
                      : AppColors.gold700,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (history.description != null &&
              history.description!.isNotEmpty) ...[
            const SizedBox(height: 13),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                history.description!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (history.sourceUserName != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sumber: ${history.sourceUserName}',
                style: const TextStyle(
                  color: AppColors.aganda600,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: history.status == 'confirmed'
                    ? AppColors.aganda100
                    : AppColors.gold300.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                history.statusLabel,
                style: TextStyle(
                  color: history.status == 'confirmed'
                      ? AppColors.aganda700
                      : AppColors.gold700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history,
              size: 55,
              color: AppColors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              _provider.error ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _provider.fetchHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}