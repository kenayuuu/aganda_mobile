import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/admin_withdrawal_model.dart';
import '../../providers/admin_withdrawal_provider.dart';

class AdminWithdrawalPage extends StatefulWidget {
  const AdminWithdrawalPage({
    super.key,
  });

  @override
  State<AdminWithdrawalPage> createState() =>
      _AdminWithdrawalPageState();
}

class _AdminWithdrawalPageState
    extends State<AdminWithdrawalPage> {
  String _selectedStatus = 'all';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<AdminWithdrawalProvider>()
          .fetchWithdrawals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminWithdrawalProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            color: AppColors.primaryDark,
            onRefresh: provider.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                24,
              ),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSummary(provider),
                const SizedBox(height: 20),
                _buildFilter(),
                const SizedBox(height: 18),
                _buildTitle(provider),
                const SizedBox(height: 12),
                if (provider.loading &&
                    provider.withdrawals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  )
                else if (provider.error != null &&
                    provider.withdrawals.isEmpty)
                  _buildError(provider)
                else if (provider.withdrawals.isEmpty)
                    _buildEmpty()
                  else
                    ...provider.withdrawals.map(
                          (withdrawal) =>
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: _buildWithdrawalCard(
                              withdrawal,
                              provider,
                            ),
                          ),
                    ),
                if (provider.pagination != null)
                  _buildPagination(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: const [
              Text(
                'Withdraw',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola pengajuan pencairan bonus',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.15,
            ),
            borderRadius:
            BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.payments_outlined,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(
      AdminWithdrawalProvider provider,
      ) {
    final summary = provider.summary;

    final pendingCount =
        summary?.pendingCount ?? 0;

    final pendingAmount =
        summary?.pendingAmount ?? 0;

    final paidCount =
        summary?.paidCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryDark.withValues(
              alpha: 0.88,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Pending',
              pendingCount.toString(),
              Icons.hourglass_empty,
            ),
          ),
          Container(
            width: 1,
            height: 45,
            color: Colors.white
                .withValues(alpha: 0.25),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Nominal Pending',
              _formatCurrency(pendingAmount),
              Icons.payments_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 45,
            color: Colors.white
                .withValues(alpha: 0.25),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Paid',
              paidCount.toString(),
              Icons.check_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String title,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 21,
        ),
        const SizedBox(height: 7),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildFilter() {
    final filters = [
      ['all', 'Semua'],
      ['pending', 'Pending'],
      ['approved', 'Approved'],
      ['paid', 'Paid'],
      ['rejected', 'Rejected'],
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, index) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = filters[index][0];
          final label = filters[index][1];
          final selected =
              _selectedStatus == value;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = value;
              });

              context
                  .read<AdminWithdrawalProvider>()
                  .fetchWithdrawals(
                status: value,
              );
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryDark
                    : Colors.white,
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryDark
                      : Colors.grey
                      .withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(
      AdminWithdrawalProvider provider,
      ) {
    final pagination =
        provider.pagination;

    final text = pagination == null
        ? 'Daftar Pengajuan'
        : 'Daftar Pengajuan ${pagination.from}-${pagination.to} dari ${pagination.total}';

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWithdrawalCard(
      AdminWithdrawal withdrawal,
      AdminWithdrawalProvider provider,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(withdrawal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      withdrawal.userName,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      withdrawal.memberId ??
                          withdrawal.email ??
                          'Pengguna',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(
                withdrawal.status,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nominal Withdraw',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatCurrency(
                          withdrawal.amount,
                        ),
                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Diajukan',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(
                        withdrawal.requestedAt,
                      ),
                      style:
                      const TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (withdrawal.notes != null &&
              withdrawal.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                withdrawal.notes!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
          if (withdrawal.status ==
              'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                    provider.loading
                        ? null
                        : () =>
                        _confirmAction(
                          withdrawal,
                          'reject',
                        ),
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      Colors.red,
                      side:
                      const BorderSide(
                        color: Colors.red,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child:
                    const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                    provider.loading
                        ? null
                        : () =>
                        _confirmAction(
                          withdrawal,
                          'approve',
                        ),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.primaryDark,
                      foregroundColor:
                      Colors.white,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child:
                    const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
          if (withdrawal.status ==
              'approved') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                provider.loading
                    ? null
                    : () =>
                    _confirmAction(
                      withdrawal,
                      'paid',
                    ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primaryDark,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child:
                const Text(
                  'Tandai Sudah Dibayar',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(
      AdminWithdrawal withdrawal,
      ) {
    final initial =
    withdrawal.userName.isNotEmpty
        ? withdrawal.userName[0]
        .toUpperCase()
        : '?';

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primary
            .withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: 0.45),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
      String status,
      ) {
    Color background;
    Color foreground;
    String label;

    switch (status) {
      case 'approved':
        background =
            Colors.blue.withValues(
              alpha: 0.1,
            );
        foreground = Colors.blue;
        label = 'APPROVED';
        break;
      case 'paid':
        background =
            AppColors.primary.withValues(
              alpha: 0.2,
            );
        foreground =
            AppColors.primaryDark;
        label = 'PAID';
        break;
      case 'rejected':
        background =
            Colors.red.withValues(
              alpha: 0.1,
            );
        foreground = Colors.red;
        label = 'REJECTED';
        break;
      case 'cancelled':
        background =
            Colors.grey.withValues(
              alpha: 0.15,
            );
        foreground = Colors.grey[700]!;
        label = 'CANCELLED';
        break;
      default:
        background =
            Colors.orange.withValues(
              alpha: 0.12,
            );
        foreground = Colors.orange[800]!;
        label = 'PENDING';
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding:
      const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.payments_outlined,
            size: 58,
            color: Colors.grey
                .withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada pengajuan withdraw',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      AdminWithdrawalProvider provider,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed:
            provider.refresh,
            child:
            const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(
      AdminWithdrawalProvider provider,
      ) {
    final pagination =
    provider.pagination!;

    if (pagination.lastPage <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
      const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
            pagination.currentPage > 1 &&
                !provider.loading
                ? () {
              provider
                  .fetchWithdrawals(
                status:
                _selectedStatus,
                page: pagination
                    .currentPage -
                    1,
              );
            }
                : null,
            icon: const Icon(
              Icons.chevron_left,
            ),
          ),
          Text(
            '${pagination.currentPage} / ${pagination.lastPage}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed:
            pagination.currentPage <
                pagination.lastPage &&
                !provider.loading
                ? () {
              provider
                  .fetchWithdrawals(
                status:
                _selectedStatus,
                page: pagination
                    .currentPage +
                    1,
              );
            }
                : null,
            icon: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAction(
      AdminWithdrawal withdrawal,
      String action,
      ) async {
    final isReject = action == 'reject';

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isReject
                ? 'Tolak Withdraw'
                : action == 'approve'
                ? 'Setujui Withdraw'
                : 'Konfirmasi Pembayaran',
          ),
          content: Text(
            isReject
                ? 'Apakah pengajuan withdraw ${withdrawal.userName} ingin ditolak?'
                : action == 'approve'
                ? 'Apakah pengajuan withdraw ${withdrawal.userName} ingin disetujui?'
                : 'Apakah withdraw ${withdrawal.userName} sudah dibayarkan?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    false,
                  ),
              child:
              const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    true,
                  ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                isReject
                    ? Colors.red
                    : AppColors
                    .primaryDark,
                foregroundColor:
                Colors.white,
              ),
              child: Text(
                isReject
                    ? 'Tolak'
                    : action == 'approve'
                    ? 'Setujui'
                    : 'Ya, Sudah Dibayar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    final provider =
    context.read<
        AdminWithdrawalProvider>();

    try {
      if (action == 'approve') {
        await provider.approve(
          withdrawal.id,
        );
      } else if (action == 'reject') {
        await provider.reject(
          withdrawal.id,
        );
      } else {
        await provider.markPaid(
          withdrawal.id,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isReject
                ? 'Withdraw berhasil ditolak.'
                : action == 'approve'
                ? 'Withdraw berhasil disetujui.'
                : 'Withdraw berhasil ditandai sudah dibayar.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  String _formatCurrency(double value) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(
        r'\B(?=(\d{3})+(?!\d))',
      ),
          (match) => '.',
    );

    return 'Rp $formatted';
  }

  String _formatDate(String? value) {
    if (value == null ||
        value.isEmpty) {
      return '-';
    }

    try {
      final date =
      DateTime.parse(value).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }
}