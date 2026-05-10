import 'package:flutter/material.dart';

import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/business/nearby/nearby_screen.dart';
import 'package:yol_arkadasim/business/search/search_screen.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/business/favorites/favorites_screen.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _homeActionIconSize = 50;
  static const double _homeActionIconTextGap = 8;
  static const double _homeActionBorderRadius = 12;

  void handleVoiceResult(String text) {
    debugPrint('Sesli komut alındı (demo): $text');
    // TODO: speak('$text alındı') - voice announcement (UI-only)
    // TODO: vibrate short
  }

  void handleSearchDestination() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    // TODO: announce navigation
  }

  void handleNearbyStops() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NearbyScreen()),
    );
  }

  void handleButtonPress(String action) {
    // short visual feedback only
    switch (action) {
      case 'search':
        handleSearchDestination();
        break;
      case 'favorites':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
        );
        break;
      case 'nearby':
        handleNearbyStops();
        break;
    }
  }

  Widget _buildColoredMainCard({
    required Color color,
    required VoidCallback onPressed,
    required String semanticsLabel,
    required double minHeight,
    required IconData icon,
    required String title,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool expandedTitle = true,
  }) {
    return AppButton(
      onPressed: onPressed,
      semanticsLabel: semanticsLabel,
      fullWidth: true,
      size: 'custom',
      variant: 'custom',
      backgroundColor: color,
      borderRadius: _homeActionBorderRadius,
      minHeight: minHeight,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Icon(icon, size: _homeActionIconSize, color: Colors.white),
          SizedBox(width: _homeActionIconTextGap),
          if (expandedTitle)
            Expanded(
              child: Text(title, style: AppTextStyles.buttonLabel),
            )
          else
            Text(title, style: AppTextStyles.buttonLabel),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Erişilebilir ulaşım yardımcınız',
            style: AppTextStyles.screenSubtitle,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildColoredMainCard(
                  color: const Color(0xFF2F6BEE),
                  onPressed: () => handleButtonPress('search'),
                  semanticsLabel: 'Hedef bul - Ana arama fonksiyonu',
                  minHeight: 0,
                  icon: Icons.search,
                  title: 'Hedef Bul',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 3,
                child: _buildColoredMainCard(
                  color: const Color(0xFF23A957),
                  onPressed: () => handleButtonPress('favorites'),
                  semanticsLabel: 'Favori yerler - kayıtlı konumları görüntüle',
                  minHeight: 0,
                  icon: Icons.favorite,
                  title: 'Favori Yerler',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 3,
                child: _buildColoredMainCard(
                  color: const Color(0xFF9638E8),
                  onPressed: () => handleButtonPress('nearby'),
                  semanticsLabel: 'Yakın duraklar - çevredeki durakları bul',
                  minHeight: 0,
                  icon: Icons.place,
                  title: 'Yakın Duraklar',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 2,
                child: _buildColoredMainCard(
                  color: const Color(0xFFD0911B),
                  onPressed: () => handleVoiceResult('İstiklal Caddesi'),
                  semanticsLabel: 'Sesli komut - sesle hedef belirle',
                  minHeight: 0,
                  icon: Icons.mic_none,
                  title: 'Sesli Komut',
                  mainAxisAlignment: MainAxisAlignment.center,
                  expandedTitle: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.home(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Semantics(
                container: true,
                label: 'YolArkadaşım ana ekranı. Erişilebilir ulaşım yardımcınız.',
                child: _buildMainView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
