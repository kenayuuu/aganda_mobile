import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aganda_mobile/models/admin_bonus_model.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_bonus_provider.dart';

class AdminBonusPage extends StatefulWidget {
  const AdminBonusPage({super.key});

  @override
  State<AdminBonusPage> createState() => _AdminBonusPageState();
}

class _AdminBonusPageState extends State<AdminBonusPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminBonusProvider>().fetchBonus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _currency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _number(double value) {
    return NumberFormat.decimalPattern('id_ID').format(value);
  }

  Future<void> _search() async {
    await context.read<AdminBonusProvider>().fetchBonus(
      search: _searchController.text.trim(),
    );
  }

  Future<void> _resetSearch() async {
    _searchController.clear();
    await context.read<AdminBonusProvider>().fetchBonus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBonusProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () {
            return provider.fetchBonus(
              search: _searchController.text.trim(),
            );
          },
          child: provider.loading && provider.data == null
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          )
              : provider.error != null && provider.data == null
              ? _errorView(provider.error!)
              : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            children: [
              _pageHeader(),
              const SizedBox(height: 20),
              _searchCard(),
              const SizedBox(height: 16),
              if (provider.summary != null)
                _summarySection(provider.summary!),
              const SizedBox(height: 20),
              _dataHeader(provider),
              const SizedBox(height: 12),
              if (provider.users.isEmpty)
                _emptyView()
              else
                ...provider.users.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _userBonusCard(item),
                  ),
                ),
              if (provider.pagination != null &&
                  provider.pagination!.lastPage > 1)
                _pagination(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Bonus',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ringkasan komisi member dan karyawan',
              style: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.aganda600,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _searchCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Cari nama, email, atau ID...',
                hintStyle: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.grey,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.grey,
                  ),
                )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _search,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(width: 6),
            Material(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _resetSearch,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: AppColors.aganda600,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summarySection(AdminBonusSummary summary) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.aganda600,
                AppColors.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.aganda600.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saldo Tersedia',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currency(summary.totalAvailableBonus),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Pengguna Active',
                value: _number(summary.totalUsers.toDouble()),
                icon: Icons.people_alt_rounded,
                iconColor: AppColors.aganda600,
                bgColor: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                title: 'Total Akumulasi Komisi',
                value: _currency(summary.totalBonus),
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.aganda600,
                bgColor: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataHeader(AdminBonusProvider provider) {
    final pagination = provider.pagination;
    String subtitle = 'Daftar rincian bonus';

    if (pagination != null && pagination.total > 0) {
      subtitle =
      '${pagination.from}–${pagination.to} dari ${pagination.total}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Rincian Pengguna',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.aganda600,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _userBonusCard(AdminBonusItem item) {
    final user = item.user;
    final isKaryawan = user.role == 'karyawan';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            14,
            0,
            14,
            14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: _avatar(user),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _roleBadge(user.role, isKaryawan),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user.memberId?.isNotEmpty == true
                        ? user.memberId!
                        : user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  _currency(item.availableBonus),
                  style: TextStyle(
                    color: AppColors.aganda600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey,
            size: 20,
          ),
          children: [
            const Divider(
              height: 16,
              thickness: 0.8,
            ),
            _bonusUserContent(item),
          ],
        ),
      ),
    );
  }

  Widget _avatar(AdminBonusUser user) {
    final isKaryawan = user.role == 'karyawan';

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.16),
        border: Border.all(
          color: AppColors.aganda600.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: user.avatar != null && user.avatar!.isNotEmpty
          ? ClipOval(
        child: Image.network(
          user.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _avatarInitial(user),
        ),
      )
          : _avatarInitial(user),
    );
  }

  Widget _avatarInitial(AdminBonusUser user) {
    return Center(
      child: Text(
        user.name.isNotEmpty
            ? user.name.substring(0, 1).toUpperCase()
            : '?',
        style: const TextStyle(
          color: AppColors.aganda600,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _roleBadge(String role, bool isKaryawan) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: AppColors.aganda600,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _bonusUserContent(AdminBonusItem item) {
    final isKaryawan = item.user.role == 'karyawan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isKaryawan) ...[
          Row(
            children: [
              Expanded(
                child: _detailAmount(
                  title: 'Paket',
                  value: _currency(item.packagePrice),
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _detailAmount(
                  title: 'DP',
                  value: _currency(item.deposit),
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _remainingPackageCard(item),
          const SizedBox(height: 12),
        ] else
          _karyawanPackageInfo(),
        Row(
          children: [
            Expanded(
              child: _lineCard(
                title: 'Line 1',
                subtitle: '${item.line1Count} orang',
                amount: item.line1Bonus,
                icon: Icons.people_outline,
                color: AppColors.aganda600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _lineCard(
                title: 'Line 2',
                subtitle: '${item.line2Count} pairing',
                amount: item.line2Bonus,
                icon: Icons.link_rounded,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _amountInfoRow(
                title: 'Total Bonus Diproses',
                amount: item.totalBonus,
                color: AppColors.black,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(height: 1),
              ),
              _amountInfoRow(
                title: 'Bonus Terpakai',
                amount: item.packagePayment,
                color: AppColors.aganda600,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(height: 1),
              ),
              _amountInfoRow(
                title: 'Saldo Bonus Tersedia',
                amount: item.availableBonus,
                color: AppColors.aganda600,
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailAmount({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.aganda600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 9,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _remainingPackageCard(AdminBonusItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.aganda600.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.hourglass_bottom_rounded,
                color: AppColors.aganda600,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sisa Paket',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            _currency(item.remainingPackage),
            style: const TextStyle(
              color: AppColors.aganda600,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _karyawanPackageInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.aganda600.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.aganda600,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'Karyawan tidak memiliki paket pribadi.',
            style: TextStyle(
              color: AppColors.aganda600,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineCard({
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _currency(amount),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountInfoRow({
    required String title,
    required double amount,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isBold ? AppColors.black : AppColors.grey,
            fontSize: 10,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          _currency(amount),
          style: TextStyle(
            color: color,
            fontSize: isBold ? 12 : 11,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _pagination(AdminBonusProvider provider) {
    final pagination = provider.pagination!;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: pagination.currentPage > 1
                ? () {
              provider.fetchBonus(
                page: pagination.currentPage - 1,
                search: _searchController.text.trim(),
              );
            }
                : null,
            icon: const Icon(
              Icons.chevron_left_rounded,
            ),
            color: AppColors.aganda600,
          ),
          Text(
            'Halaman ${pagination.currentPage} dari ${pagination.lastPage}',
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed:
            pagination.currentPage < pagination.lastPage
                ? () {
              provider.fetchBonus(
                page: pagination.currentPage + 1,
                search: _searchController.text.trim(),
              );
            }
                : null,
            icon: const Icon(
              Icons.chevron_right_rounded,
            ),
            color: AppColors.aganda600,
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.grey,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada data bonus',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Data bonus akan muncul secara otomatis di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.aganda600,
                    size: 44,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gagal memuat data bonus',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<AdminBonusProvider>()
                          .fetchBonus(
                        search: _searchController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}