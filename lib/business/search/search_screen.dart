import 'package:flutter/material.dart';

import 'package:yol_arkadasim/business/routes/routes_screen.dart';
import 'package:yol_arkadasim/services/route_planner_service.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';

import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  final RoutePlannerService _routePlannerService = RoutePlannerService();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void handleSearchSubmit() {
    final String trimmedQuery = _searchController.text.trim();
    if (trimmedQuery.isEmpty) return;

    final plan = _routePlannerService.createJourneyPlan(trimmedQuery);
    if (plan == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Bu hedef için uygun rota bulunamadı.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoutesScreen(journeyPlan: plan)),
    );
  }

  Widget _buildSearchView() {
    const double formHorizontalPadding = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 2),
        const Center(
          child: Text(
            'Nereye gitmek\nistiyorsunuz?',
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle,
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: formHorizontalPadding,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.borderBlue500,
                  blurRadius: 6,
                  spreadRadius: 0.2,
                ),
              ],
            ),
            child: Semantics(
              label: 'Hedef konumu giriş alanı',
              hint: 'Gitmek istediğiniz konumu yazın',
              textField: true,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.gray800,
                  hintText: 'Hedef girin...',
                  hintStyle: const TextStyle(
                    color: AppColors.gray300,
                    fontSize: 20.0,
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                    borderSide: const BorderSide(color: AppColors.gray700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                    borderSide: const BorderSide(
                      color: AppColors.gray700,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                    borderSide: const BorderSide(
                      color: AppColors.borderBlue500,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: formHorizontalPadding,
          ),
          child: AppButton(
            onPressed: handleSearchSubmit,
            semanticsLabel: 'Rota ara - girilen hedef için',
            fullWidth: true,
            size: 'xl',
            minHeight: 115,
            borderRadius: AppRadius.rounded2xl,
            backgroundColor: AppColors.blue600,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, color: Colors.white, size: 34),
                  SizedBox(width: 8),
                  Text('Rota Ara'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: formHorizontalPadding,
          ),
          child: AppButton(
            onPressed: () => debugPrint('Sesli arama (demo)'),
            semanticsLabel: 'Sesli arama - hedefi sesle söyleyin',
            fullWidth: true,
            size: 'xl',
            minHeight: 115,
            borderRadius: AppRadius.rounded2xl,
            backgroundColor: AppColors.yellow500,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic_none, color: Colors.white, size: 34),
                  SizedBox(width: 8),
                  Text('Sesli Arama'),
                ],
              ),
            ),
          ),
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
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p6),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildSearchView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
