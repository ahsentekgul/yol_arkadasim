import 'package:flutter/material.dart';

import 'package:yol_arkadasim/business/journey_detail/journey_detail_screen.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/services/dummy_place_search_service.dart';
import 'package:yol_arkadasim/services/route_planner_service.dart';

class PlaceResultsScreen extends StatelessWidget {
  PlaceResultsScreen({super.key, required this.searchQuery})
      : _places = DummyPlaceSearchService().searchPlaces(searchQuery);

  final String searchQuery;
  final List<PlaceCandidate> _places;
  final RoutePlannerService _routePlannerService = RoutePlannerService();

  void _createRouteForPlace(BuildContext context, PlaceCandidate place) {
    final plan = _routePlannerService.createJourneyPlanForPlace(place);
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
      MaterialPageRoute(
        builder: (_) => JourneyDetailScreen(journeyPlan: plan),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
      child: Text(
        'Bu arama için konum sonucu bulunamadı.',
        textAlign: TextAlign.center,
        style: AppTextStyles.screenSubtitle.copyWith(
          fontSize: 18,
          color: AppColors.gray300,
        ),
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, PlaceCandidate place) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(AppRadius.roundedXl),
        border: Border.all(color: AppColors.gray700, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            place.name,
            style: AppTextStyles.buttonLabel.copyWith(fontSize: 20),
          ),
          const SizedBox(height: AppSpacing.spaceX3),
          Text(
            place.address,
            style: AppTextStyles.screenSubtitle.copyWith(
              fontSize: 16,
              color: AppColors.gray300,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceY4),
          AppButton(
            onPressed: () => _createRouteForPlace(context, place),
            semanticsLabel: '${place.name} konumu için rota oluştur',
            fullWidth: true,
            size: 'large',
            minHeight: 56,
            borderRadius: AppRadius.roundedXl,
            child: const Text('Bu hedef için rota oluştur'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _places
          .map(
            (PlaceCandidate place) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spaceY4),
              child: _buildPlaceCard(context, place),
            ),
          )
          .toList(),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_places.isEmpty) {
      return _buildEmptyState();
    }
    return _buildResultsList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(title: 'Konum Sonuçları'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p6),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
