import 'package:flutter/material.dart';

import 'package:yol_arkadasim/business/journey_detail/journey_detail_screen.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/services/dummy_place_search_service.dart';
import 'package:yol_arkadasim/services/firestore_place_search_service.dart';
import 'package:yol_arkadasim/services/route_planner_service.dart';

class PlaceResultsScreen extends StatefulWidget {
  const PlaceResultsScreen({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  State<PlaceResultsScreen> createState() => _PlaceResultsScreenState();
}

class _PlaceResultsScreenState extends State<PlaceResultsScreen> {
  final RoutePlannerService _routePlannerService = RoutePlannerService();
  final FirestorePlaceSearchService _firestorePlaceSearchService =
      FirestorePlaceSearchService();
  final DummyPlaceSearchService _dummyPlaceSearchService =
      DummyPlaceSearchService();

  List<PlaceCandidate> _places = <PlaceCandidate>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    List<PlaceCandidate> places = await _firestorePlaceSearchService
        .searchPlaces(widget.searchQuery);

    if (places.isEmpty) {
      places = _dummyPlaceSearchService.searchPlaces(widget.searchQuery);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _places = places;
      _isLoading = false;
    });
  }

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
      MaterialPageRoute(builder: (_) => JourneyDetailScreen(journeyPlan: plan)),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.p8),
      child: Center(child: CircularProgressIndicator()),
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

  Widget _buildPlaceCard(
    BuildContext context,
    PlaceCandidate place,
    int index,
  ) {
    final int resultNumber = index + 1;

    return Semantics(
      button: true,
      label: '$resultNumber. sonuç. ${place.name}. ${place.address}.',
      hint: 'Bu hedef için rota oluşturmak için çift dokunun.',
      onTap: () => _createRouteForPlace(context, place),
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.gray800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.roundedXl),
            side: const BorderSide(color: AppColors.gray700, width: 1.2),
          ),
          child: InkWell(
            onTap: () => _createRouteForPlace(context, place),
            borderRadius: BorderRadius.circular(AppRadius.roundedXl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 150),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$resultNumber. sonuç',
                            style: AppTextStyles.screenSubtitle.copyWith(
                              fontSize: 16,
                              color: AppColors.gray300,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceX3),
                          Text(
                            place.name,
                            style: AppTextStyles.buttonLabel.copyWith(
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceX3),
                          Text(
                            place.address,
                            style: AppTextStyles.screenSubtitle.copyWith(
                              fontSize: 18,
                              color: AppColors.gray300,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceY4),
                          Text(
                            'Hedefi seç',
                            style: AppTextStyles.screenSubtitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.borderBlue500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceX3),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.gray300,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    return Semantics(
      label:
          '"${widget.searchQuery}" için ${_places.length} konum sonucu bulundu. Hedef kartına dokunarak seçin.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.p6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${widget.searchQuery}" için ${_places.length} konum sonucu bulundu',
                style: AppTextStyles.buttonLabel.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceX3),
              Text(
                'Hedef kartına dokunarak seçin.',
                style: AppTextStyles.screenSubtitle.copyWith(
                  fontSize: 17,
                  color: AppColors.gray300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResultsSummary(),
        ..._places.asMap().entries.map((entry) {
          final int index = entry.key;
          final PlaceCandidate place = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spaceY4),
            child: _buildPlaceCard(context, place, index),
          );
        }),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }
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
