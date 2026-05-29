import 'package:flutter/material.dart';

import 'package:yol_arkadasim/business/place_results/place_results_screen.dart';
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
  String? _validationMessage;

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

  void _clearValidationMessage() {
    if (_validationMessage != null) {
      setState(() => _validationMessage = null);
    }
  }

  void handleSearchSubmit() {
    final String trimmedQuery = _searchController.text.trim();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _validationMessage = 'Lütfen gitmek istediğiniz konumu yazın.';
      });
      return;
    }

    _clearValidationMessage();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceResultsScreen(searchQuery: trimmedQuery),
      ),
    );
  }

  Widget _buildSearchView() {
    const double formHorizontalPadding = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.spaceY4),
        Center(
          child: Semantics(
            header: true,
            child: Text(
              'Nereye gitmek\nistiyorsunuz?',
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle.copyWith(
                fontSize: 34,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.p6),
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
              label: 'Hedef konumu',
              hint: 'Gitmek istediğiniz yerin adını yazın',
              textField: true,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => handleSearchSubmit(),
                onChanged: (_) => _clearValidationMessage(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.gray800,
                  hintText: 'Hedef girin...',
                  hintStyle: const TextStyle(
                    color: AppColors.gray300,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 38,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                    borderSide: const BorderSide(color: AppColors.gray700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                    borderSide: const BorderSide(
                      color: AppColors.borderBlue500,
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
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 25,
                ),
              ),
            ),
          ),
        ),
        if (_validationMessage != null) ...[
          const SizedBox(height: AppSpacing.spaceX3),
          Semantics(
            liveRegion: true,
            label: _validationMessage,
            child: ExcludeSemantics(
              child: Text(
                _validationMessage!,
                style: AppTextStyles.screenSubtitle.copyWith(
                  color: AppColors.borderOrange500,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.p8),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: formHorizontalPadding,
          ),
          child: AppButton(
            onPressed: handleSearchSubmit,
            semanticsLabel: 'Hedef bul, girilen konum için sonuçları göster',
            fullWidth: true,
            size: 'xl',
            minHeight: 135,
            borderRadius: AppRadius.rounded2xl,
            backgroundColor: AppColors.blue600,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.search,
                      color: AppColors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Hedef Bul'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
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
