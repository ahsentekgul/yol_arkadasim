import 'package:flutter/material.dart';

import 'package:yol_arkadasim/business/routes/routes_screen.dart';
import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/services/dummy_place_search_service.dart';
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
  final DummyPlaceSearchService _dummyPlaceSearchService =
      DummyPlaceSearchService();

  List<PlaceCandidate> _suggestions = <PlaceCandidate>[];
  PlaceCandidate? _selectedPlace;
  bool _isApplyingSuggestionChange = false;

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
    if (_selectedPlace == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Lütfen gitmek istediğiniz konumu listeden seçin.'),
        ),
      );
      return;
    }

    final plan = _routePlannerService.createJourneyPlanForPlace(
      _selectedPlace!,
    );
    if (plan == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Bu hedef için aktarmasız uygun rota bulunamadı.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoutesScreen(journeyPlan: plan)),
    );
  }

  void _handleQueryChanged(String value) {
    if (_isApplyingSuggestionChange) return;

    final String trimmedQuery = value.trim();
    final List<PlaceCandidate> nextSuggestions = trimmedQuery.isEmpty
        ? <PlaceCandidate>[]
        : _dummyPlaceSearchService.searchPlaces(trimmedQuery);

    setState(() {
      _selectedPlace = null;
      _suggestions = nextSuggestions;
    });
  }

  void _handleSuggestionTap(PlaceCandidate place) {
    _isApplyingSuggestionChange = true;
    _searchController.value = TextEditingValue(
      text: place.name,
      selection: TextSelection.collapsed(offset: place.name.length),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isApplyingSuggestionChange = false;
    });

    setState(() {
      _selectedPlace = place;
      _suggestions = <PlaceCandidate>[];
    });
  }

  Widget _buildSelectedPlaceCard() {
    final PlaceCandidate? selectedPlace = _selectedPlace;
    if (selectedPlace == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: BorderRadius.circular(AppRadius.roundedXl),
          border: Border.all(color: AppColors.borderBlue500, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seçilen konum',
              style: AppTextStyles.screenSubtitle.copyWith(
                fontSize: 13,
                color: AppColors.gray300,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selectedPlace.name,
              style: AppTextStyles.buttonLabel.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              selectedPlace.address,
              style: AppTextStyles.screenSubtitle.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: BorderRadius.circular(AppRadius.roundedXl),
          border: Border.all(color: AppColors.gray700, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Öneriler',
              style: AppTextStyles.buttonLabel.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 8),
            ..._suggestions.asMap().entries.map((entry) {
              final int index = entry.key;
              final PlaceCandidate place = entry.value;
              final bool isLastItem = index == _suggestions.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLastItem ? 0 : 8),
                child: GestureDetector(
                  onTap: () => _handleSuggestionTap(place),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.roundedXl),
                      border: Border.all(color: AppColors.gray700),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: AppTextStyles.buttonLabel.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place.address,
                          style: AppTextStyles.screenSubtitle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
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
                onChanged: _handleQueryChanged,
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
        _buildSelectedPlaceCard(),
        _buildSuggestionsList(),
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
