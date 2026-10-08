import 'dart:async';
import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import '../core/constants/app_colors.dart';
import '../widgets/hero_header.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  final PageController _brochureController = PageController();
  Timer? _autoPlayTimer;

  int _currentBrochure = 0;

  final List<String> _brochures = [
    'assets/images/landscape1.jpg',
    'assets/images/landscape2.jpg',
    'assets/images/landscape3.jpg',
    'assets/images/landscape4.jpg',
    'assets/images/landscape5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoPlay();
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (!mounted || !_brochureController.hasClients || _brochures.isEmpty) {
          return;
        }

        final nextPage = (_currentBrochure + 1) % _brochures.length;

        _brochureController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _brochureController.dispose();
    super.dispose();
  }

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Sticky Collapsing Header
          SliverPersistentHeader(
            pinned: true,
            delegate: HeroHeaderDelegate(
              topPadding: topPadding,
              onLoginPressed: _openLogin,
            ),
          ),

          // Floating Quick Menu (Layanan Utama)
          SliverToBoxAdapter(
            child: _buildQuickMenu(),
          ),

          // Section Brosur Carousel
          SliverToBoxAdapter(
            child: _buildBrochureSection(),
          ),

          // Section Tentang
          SliverToBoxAdapter(
            child: _buildAboutSection(),
          ),

          // Section Cara Bergabung
          SliverToBoxAdapter(
            child: _buildHowToJoinSection(),
          ),

          // Section Info Sistem
          SliverToBoxAdapter(
            child: _buildSystemInfoSection(),
          ),

          // Section Banner CTA
          SliverToBoxAdapter(
            child: _buildCtaSection(),
          ),

          // Section Footer
          SliverToBoxAdapter(
            child: _buildFooterSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    final features = [
      _FeatureData(
        icon: Icons.groups_rounded,
        title: 'Keanggotaan',
        color: AppColors.primary,
      ),
      _FeatureData(
        icon: Icons.account_tree_rounded,
        title: 'Jaringan',
        color: AppColors.primaryDark,
      ),
      _FeatureData(
        icon: Icons.card_travel_rounded,
        title: 'Paket Umroh',
        color: AppColors.gold600,
      ),
      _FeatureData(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Bonus',
        color: AppColors.gold500,
      ),
    ];

    return Transform.translate(
      offset: const Offset(0, -26),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.aganda900.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: features.map((item) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBrochureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'Informasi & Promo Terbaru',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _brochureController,
            itemCount: _brochures.length,
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentBrochure = index;
                });
              }
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.aganda900.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      _brochures[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.lightGrey,
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 36,
                                color: AppColors.grey,
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Gambar brosur tidak ditemukan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _brochures.length,
                (index) {
              final active = index == _currentBrochure;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
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
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tentang AGANDA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'AGANDA merupakan sistem keagenan Agent Ganda Asia Andalas Wisata yang menggabungkan pemasaran produk perjalanan dengan sistem bonus dan reward untuk memberikan peluang berkembang bagi setiap agen.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToJoinSection() {
    final steps = const [
      _StepData(
        number: '1',
        title: 'Pendaftaran Akun',
        text: 'Isi formulir pendaftaran singkat untuk memulai.',
      ),
      _StepData(
        number: '2',
        title: 'Pilih Paket Kegiatan',
        text: 'Tentukan paket keanggotaan sesuai kebutuhan Anda.',
      ),
      _StepData(
        number: '3',
        title: 'Konfirmasi Pembayaran',
        text: 'Lakukan pembayaran DP dengan sistem yang aman.',
      ),
      _StepData(
        number: '4',
        title: 'Aktivasi & Nikmati Layanan',
        text: 'Akses penuh ke seluruh jaringan dan sistem bonus AGANDA.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cara Bergabung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '4 langkah mudah menjadi bagian dari AGANDA',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 14),
          ...steps.map(
                (step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.aganda100,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        step.number,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.text,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.aganda900,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.gold400,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Keunggulan Sistem AGANDA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white.withOpacity(0.95),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Arsitektur platform yang cepat, terpercaya, dan dirancang khusus '
                  'untuk mendukung operasional member, karyawan, serta pengelolaan bonus.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.white.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSystemBadge('Manajemen Member'),
                _buildSystemBadge('Hirarki Jaringan'),
                _buildSystemBadge('Kalkulasi Bonus'),
                _buildSystemBadge('Real-time Report'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withOpacity(0.15),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildCtaSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gold300,
              AppColors.gold500,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold500.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Siap Mengembangkan Jaringan Anda?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.aganda900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Masuk sekarang untuk mengakses dashboard dan fitur lengkap AGANDA.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.aganda800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aganda900,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Masuk ke Akun Saya',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AGANDA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '© 2026 AGANDA. All rights reserved.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final Color color;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.color,
  });
}

class _StepData {
  final String number;
  final String title;
  final String text;

  const _StepData({
    required this.number,
    required this.title,
    required this.text,
  });
}