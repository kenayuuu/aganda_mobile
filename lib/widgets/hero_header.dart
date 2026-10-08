import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class HeroHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final VoidCallback onLoginPressed;

  HeroHeaderDelegate({
    required this.topPadding,
    required this.onLoginPressed,
  });

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  double get maxExtent => 240 + topPadding;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double maxScroll = maxExtent - minExtent;
    final double progress = (shrinkOffset / maxScroll).clamp(0.0, 1.0);

    // Perhitungan opacity transisi
    final double expandedOpacity = (1 - progress * 2.2).clamp(0.0, 1.0);
    final double collapsedOpacity = ((progress - 0.4) * 2.2).clamp(0.0, 1.0);

    // Perhitungan dinamis lengkung bawah (24px saat top, 0px saat sticky)
    final double bottomRadius = 24.0 * (1.0 - progress);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Tampilan Hero saat posisi paling atas (Expanded)
          if (expandedOpacity > 0)
            Opacity(
              opacity: expandedOpacity,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.hub_rounded,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AGANDA',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  Text(
                                    'Sistem Jaringan Terintegrasi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.aganda200,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primaryDark,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Jelajahi Peluang & Kelola Jaringan Anda',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Semua kemudahan pengelolaan keanggotaan dan bonus dalam satu platform.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.aganda100,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Tampilan Sticky Header Bar saat di-scroll ke bawah (Collapsed)
          if (collapsedOpacity > 0)
            Opacity(
              opacity: collapsedOpacity,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, topPadding, 20, 0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.hub_rounded,
                          color: AppColors.white,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AGANDA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryDark,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HeroHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding;
  }
}