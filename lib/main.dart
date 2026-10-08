import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_colors.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/group_provider.dart';
import 'providers/withdrawal_provider.dart';
import 'providers/bonus_provider.dart';
import 'providers/admin_bonus_provider.dart';
import 'providers/admin_user_provider.dart';
import 'providers/admin_withdrawal_provider.dart';

import 'pages/home_page.dart';
import 'pages/public_home_page.dart';
import 'pages/admin/admin_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia untuk DateFormat('...', 'id_ID')
  await initializeDateFormatting('id_ID');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => GroupProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => WithdrawalProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => BonusProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AdminBonusProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AdminUserProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AdminWithdrawalProvider(),
        ),
      ],
      child: const AgandaApp(),
    ),
  );
}

class AgandaApp extends StatelessWidget {
  const AgandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AGANDA',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BonusProvider>().fetchBonus();
      context.read<GroupProvider>().fetchGroups();
      context.read<WithdrawalProvider>().fetchWithdrawals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryDark,
          ),
        ),
      );
    }

    if (!auth.isLoggedIn) {
      return const PublicHomePage();
    }

    if (auth.user!.role == 'admin') {
      return AdminHomePage(
        user: auth.user!,
      );
    }

    return HomePage(
      user: auth.user!,
    );
  }
}