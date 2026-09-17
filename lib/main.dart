import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'pages/auth/login_page.dart';
import 'pages/home_page.dart';
import 'providers/dashboard_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/group_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkSession(),
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

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryDark,
          ),
        ),
      );
    }

    if (!auth.isLoggedIn) {
      return const LoginPage();
    }

    return HomePage(user: auth.user!);
  }
}