import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/user_model.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'group_page.dart';

class HomePage extends StatefulWidget {
  final UserModel user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<Widget> get _pages {
    switch (widget.user.role) {
      case 'admin':
        return [
          DashboardPage(user: widget.user),
          const _MenuPlaceholder(title: 'Pengguna'),
          const _MenuPlaceholder(title: 'Bonus'),
          const _MenuPlaceholder(title: 'Withdraw'),
          const ProfilePage(),
        ];

      case 'karyawan':
        return [
          DashboardPage(user: widget.user),
          const GroupPage(),
          const _MenuPlaceholder(title: 'Struktur'),
          const _MenuPlaceholder(title: 'Bonus'),
          const ProfilePage(),
        ];

      case 'member':
        return [
          DashboardPage(user: widget.user),
          const GroupPage(),
          const _MenuPlaceholder(title: 'Struktur'),
          const _MenuPlaceholder(title: 'Bonus'),
          const ProfilePage(),
        ];

      default:
        return [
          const _MenuPlaceholder(title: 'Dashboard'),
        ];
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
            label: 'Bonus',
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
            label: 'Bonus',
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
            label: 'Bonus',
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
    final pages = _pages;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 12,
        items: _navigationItems,
      ),
    );
  }
}

class _MenuPlaceholder extends StatelessWidget {
  final String title;

  const _MenuPlaceholder({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}