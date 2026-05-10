import 'package:flutter/material.dart';

import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';

import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static final List<Map<String, String>> mockFavorites = [
    {'id': '1', 'name': 'İş Yeri', 'address': 'Levent Metro İstasyonu'},
    {'id': '2', 'name': 'Ev', 'address': 'Kadıköy İskelesi'},
  ];

  Widget _buildFavoritesView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'Favorileriniz',
            style: AppTextStyles.screenTitle,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: mockFavorites.map((fav) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AppButton(
                onPressed: () =>
                    debugPrint('Favori seçildi: ${fav['name']} (demo)'),
                semanticsLabel: 'Favori seç: ${fav['name']}',
                fullWidth: true,
                size: 'custom',
                minHeight: 110,
                backgroundColor: AppColors.orange600,
                borderRadius: AppRadius.rounded2xl,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 36, color: Colors.white),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fav['name']!,
                          style: AppTextStyles.screenTitle.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          fav['address']!,
                          style: AppTextStyles.screenSubtitle.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p6),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _buildFavoritesView(context),
            ),
          ),
        ),
      ),
    );
  }
}
