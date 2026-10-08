import 'package:aganda_mobile/pages/admin/admin_bonus_page.dart';
import 'package:aganda_mobile/pages/admin/admin_withdrawal_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/user_model.dart';
import '../providers/group_provider.dart';

import 'dashboard_page.dart';
import 'profile_page.dart';
import 'group_page.dart';
import 'bonus_page.dart';
import 'structure_page.dart';
import 'admin/admin_user_page.dart';

class HomePage extends StatefulWidget {
  final UserModel user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<Widget> _pages = [];

  bool _pagesInitialized = false;
  bool _loadingGroups = false;

  @override
  void initState() {
    super.initState();

    // Buat halaman awal hanya SATU kali.
    _pages = _createPages(null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePages();
    });
  }

  Future<void> _initializePages() async {
    if (!mounted) return;

    // Admin tidak membutuhkan GroupProvider.
    if (widget.user.role == 'admin') {
      if (mounted && !_pagesInitialized) {
        setState(() {
          _pagesInitialized = true;
        });
      }
      return;
    }

    if (_loadingGroups) return;

    _loadingGroups = true;

    try {
      final groupProvider = context.read<GroupProvider>();

      // Ambil group terlebih dahulu supaya StructurePage
      // mendapatkan groupId yang benar.
      await groupProvider.fetchGroups();

      if (!mounted) return;

      final groups = groupProvider.groups;

      final groupId = groups.isNotEmpty ? groups.first.id : null;

      // Ganti halaman SATU KALI setelah group tersedia.
      setState(() {
        _pages = _createPages(groupId);
        _pagesInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;

      // Kalau gagal mengambil group, tetap tampilkan halaman
      // dengan placeholder Struktur.
      setState(() {
        _pages = _createPages(null);
        _pagesInitialized = true;
      });
    } finally {
      _loadingGroups = false;
    }
  }

  List<Widget> _createPages(int? groupId) {
    switch (widget.user.role) {
      case 'admin':
        return [
          DashboardPage(user: widget.user),
          const AdminUserPage(),
          const AdminBonusPage(),
          const AdminWithdrawalPage(),
          const ProfilePage(),
        ];

      case 'karyawan':
        return [
          DashboardPage(user: widget.user),
          const GroupPage(),
          if (groupId != null)
            StructurePage(groupId: groupId)
          else
            const _MenuPlaceholder(title: 'Struktur'),
          const BonusPage(),
          const ProfilePage(),
        ];

      case 'member':
        return [
          DashboardPage(user: widget.user),
          const GroupPage(),
          if (groupId != null)
            StructurePage(groupId: groupId)
          else
            const _MenuPlaceholder(title: 'Struktur'),
          const BonusPage(),
          const ProfilePage(),
        ];

      default:
        return [const _MenuPlaceholder(title: 'Dashboard')];
    }
  }

  List<BottomNavigationBarItem> get _navigationItems {
    switch (widget.user.role) {
      case 'admin':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Pengguna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'Withdraw',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];

      case 'karyawan':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_outlined),
            activeIcon: Icon(Icons.account_tree),
            label: 'Struktur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];

      case 'member':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_outlined),
            activeIcon: Icon(Icons.account_tree),
            label: 'Struktur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];

      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan index selalu valid.
    final safeIndex = _currentIndex >= _pages.length ? 0 : _currentIndex;

    return Scaffold(
      body: _pages.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : IndexedStack(index: safeIndex, children: _pages),

      // BOTTOM NAVBAR TETAP ADA
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (index) {
          if (!mounted) return;

          if (index < 0 || index >= _pages.length) {
            return;
          }

          if (_currentIndex == index) {
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
        items: _navigationItems,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 12,
      ),
    );
  }
}

class _MenuPlaceholder extends StatelessWidget {
  final String title;

  const _MenuPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.primary, title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
