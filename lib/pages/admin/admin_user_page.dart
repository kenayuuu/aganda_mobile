import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/admin_user_model.dart';
import '../../providers/admin_user_provider.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminUserProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'karyawan':
        return Colors.blue.shade700;
      case 'member':
        return Colors.green.shade700;
      default:
        return AppColors.aganda600;
    }
  }

  String _roleName(String role) {
    switch (role) {
      case 'karyawan':
        return 'Karyawan';
      case 'member':
        return 'Member';
      default:
        return role;
    }
  }

  void _search() {
    context.read<AdminUserProvider>().fetchUsers(
      search: _searchController.text.trim(),
    );
  }

  void _resetSearch() {
    _searchController.clear();
    context.read<AdminUserProvider>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            children: [
              _header(),
              const SizedBox(height: 20),
              _totalCard(provider),
              const SizedBox(height: 16),
              _searchCard(),
              const SizedBox(height: 20),
              if (provider.loading && provider.data == null)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (provider.error != null && provider.data == null)
                _errorView(provider.error!)
              else if (provider.users.isEmpty)
                  _emptyView()
                else ...[
                    _listHeader(provider),
                    const SizedBox(height: 12),
                    ...provider.users.map(_userCard),
                    const SizedBox(height: 10),
                    _pagination(provider),
                  ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Pengguna',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Daftar member dan karyawan terdaftar',
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
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.people_alt_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _totalCard(AdminUserProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.aganda600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
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
              Icons.groups_rounded,
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
                  'Total Terdaftar',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.totalUsers} Pengguna',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Member & Karyawan',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              style: const TextStyle(fontSize: 13),
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
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    color: AppColors.grey,
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

  Widget _listHeader(AdminUserProvider provider) {
    final pagination = provider.pagination;
    String subtitle = 'Daftar pengguna';

    if (pagination != null && pagination.total > 0) {
      subtitle = '${pagination.from}–${pagination.to} dari ${pagination.total}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Daftar Pengguna',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _userCard(AdminUserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.04),
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
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
              _roleBadge(user.role),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                if (user.memberId != null && user.memberId!.isNotEmpty) ...[
                  Flexible(
                    child: Text(
                      user.memberId!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    user.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 10,
                    ),
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
            const Divider(height: 16, thickness: 0.8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.email_outlined,
                    'Email',
                    user.email,
                  ),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    _detailRow(
                      Icons.phone_outlined,
                      'No. HP',
                      user.phone!,
                    ),
                  if (user.address != null && user.address!.isNotEmpty)
                    _detailRow(
                      Icons.location_on_outlined,
                      'Alamat',
                      user.address!,
                    ),
                  if (user.parent != null)
                    _detailRow(
                      Icons.person_outline,
                      'Upline',
                      user.parent!.name,
                    ),
                  if (user.parent?.memberId != null)
                    _detailRow(
                      Icons.badge_outlined,
                      'ID Upline',
                      user.parent!.memberId!,
                    ),
                  _detailRow(
                    Icons.groups_outlined,
                    'Anggota di bawah',
                    '${user.totalChildren} pengguna',
                    isLast: true,
                  ),
                ],
              ),
            ),
            if (user.calon != null) ...[
              const SizedBox(height: 10),
              _calonCard(user.calon!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avatar(AdminUserModel user) {
    final roleColor = _roleColor(user.role);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: roleColor.withValues(alpha: 0.12),
        border: Border.all(
          color: roleColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: user.avatarUrl.isNotEmpty
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

  Widget _avatarInitial(AdminUserModel user) {
    final roleColor = _roleColor(user.role);
    final initial = user.name.trim().isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : '?';

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: roleColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    final roleColor = _roleColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _roleName(role).toUpperCase(),
        style: TextStyle(
          color: roleColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detailRow(
      IconData icon,
      String label,
      String value, {
        bool isLast = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.grey,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calonCard(AdminUserCalon calon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.amber.shade900,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Data Calon Member',
                style: TextStyle(
                  color: Colors.amber.shade900,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 14, thickness: 0.8),
          if (calon.name.isNotEmpty)
            _detailRow(
              Icons.person_outline,
              'Nama',
              calon.name,
            ),
          if (calon.nik != null && calon.nik!.isNotEmpty)
            _detailRow(
              Icons.credit_card_outlined,
              'NIK',
              calon.nik!,
            ),
          if (calon.noHp != null && calon.noHp!.isNotEmpty)
            _detailRow(
              Icons.phone_outlined,
              'No. HP',
              calon.noHp!,
            ),
          if (calon.alamat != null && calon.alamat!.isNotEmpty)
            _detailRow(
              Icons.location_on_outlined,
              'Alamat',
              calon.alamat!,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _pagination(AdminUserProvider provider) {
    final pagination = provider.pagination;

    if (pagination == null || pagination.lastPage <= 1) {
      return const SizedBox.shrink();
    }

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
              provider.fetchUsers(
                search: _searchController.text,
                page: pagination.currentPage - 1,
              );
            }
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.black,
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
            onPressed: pagination.currentPage < pagination.lastPage
                ? () {
              provider.fetchUsers(
                search: _searchController.text,
                page: pagination.currentPage + 1,
              );
            }
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.black,
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            color: AppColors.grey,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada pengguna',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Data member dan karyawan belum tersedia.',
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
                    color: Colors.red,
                    size: 44,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gagal memuat data pengguna',
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
                      context.read<AdminUserProvider>().fetchUsers();
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
                      style: TextStyle(fontWeight: FontWeight.bold),
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