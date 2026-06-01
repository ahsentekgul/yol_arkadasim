import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:yol_arkadasim/business/journey_detail/journey_detail_screen.dart';
import 'package:yol_arkadasim/business/shared/widgets/no_direct_route_state.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/demo/demo_locations.dart';
import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/services/favorite_places_service.dart';
import 'package:yol_arkadasim/services/firestore_transit_data_service.dart';
import 'package:yol_arkadasim/services/route_planner_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritePlacesService _favoritePlacesService = FavoritePlacesService();
  final FirestoreTransitDataService _firestoreTransitDataService =
      FirestoreTransitDataService();
  RoutePlannerService _routePlannerService = RoutePlannerService(
    userLocation: DemoLocations.userLocation,
  );

  List<PlaceCandidate> _favorites = <PlaceCandidate>[];
  bool _isFavoritesLoading = true;
  bool _isTransitDataLoading = true;
  bool get _isLoading => _isFavoritesLoading || _isTransitDataLoading;
  PlaceCandidate? _routeErrorPlace;
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadTransitData();
  }

  Future<void> _loadFavorites() async {
    List<PlaceCandidate> favorites = <PlaceCandidate>[];
    try {
      favorites = await _favoritePlacesService.getFavorites();
    } catch (_) {
      favorites = <PlaceCandidate>[];
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _favorites = favorites;
      _isFavoritesLoading = false;
    });
  }

  Future<void> _loadTransitData() async {
    try {
      final stops = await _firestoreTransitDataService.fetchStops();
      final routes = await _firestoreTransitDataService.fetchTransitRoutes();

      if (!mounted) {
        return;
      }

      setState(() {
        if (stops.isNotEmpty && routes.isNotEmpty) {
          _routePlannerService = RoutePlannerService(
            userLocation: DemoLocations.userLocation,
            stops: stops,
            transitRoutes: routes,
          );
        } else {
          _routePlannerService = RoutePlannerService(
            userLocation: DemoLocations.userLocation,
          );
        }
        _isTransitDataLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _routePlannerService = RoutePlannerService(
          userLocation: DemoLocations.userLocation,
        );
        _isTransitDataLoading = false;
      });
    }
  }

  void _createRouteForFavorite(BuildContext context, PlaceCandidate place) {
    if (_isLoading) {
      _showMessage(
        'Rota verileri yükleniyor. Lütfen birkaç saniye sonra tekrar deneyin.',
      );
      return;
    }

    final plan = _routePlannerService.createJourneyPlanForPlace(place);
    if (plan == null) {
      setState(() {
        _routeErrorPlace = place;
      });
      return;
    }

    setState(() {
      _routeErrorPlace = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JourneyDetailScreen(journeyPlan: plan)),
    );
  }

  Future<void> _removeFavorite(PlaceCandidate place) async {
    if (place.placeId.trim().isEmpty) {
      _showMessage('Favori kaldırılamadı.', isError: true);
      return;
    }

    try {
      await _favoritePlacesService.removeFavorite(place.placeId);
      if (!mounted) {
        return;
      }

      setState(() {
        _favorites.removeWhere((favorite) => favorite.placeId == place.placeId);
        if (_routeErrorPlace?.placeId == place.placeId) {
          _routeErrorPlace = null;
        }
      });

      _showMessage('${place.name} favorilerden çıkarıldı.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Favori kaldırılamadı.', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
    SemanticsService.announce(message, Directionality.of(context));
  }

  Widget _buildFeedbackBanner() {
    if (_feedbackMessage == null) {
      return const SizedBox.shrink();
    }

    final Color borderColor = _feedbackIsError
        ? AppColors.borderOrange500
        : AppColors.borderBlue500;

    return Semantics(
      label: _feedbackMessage,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.p6),
          decoration: BoxDecoration(
            color: AppColors.gray800,
            borderRadius: BorderRadius.circular(AppRadius.roundedXl),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Text(
            _feedbackMessage!,
            style: AppTextStyles.screenSubtitle.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Semantics(
      liveRegion: true,
      label: 'Favoriler ve rota verileri yükleniyor.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.spaceY4),
                Text(
                  'Favoriler ve rota verileri yükleniyor.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenSubtitle.copyWith(
                    fontSize: 16,
                    color: AppColors.gray300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Semantics(
      label:
          'Henüz favori hedefiniz yok. Hedef arama ekranından bir hedefi favorilere eklediğinizde burada görünecek.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Henüz favori hedefiniz yok.',
                textAlign: TextAlign.center,
                style: AppTextStyles.buttonLabel.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceY4),
              Text(
                'Hedef arama ekranından bir hedefi favorilere eklediğinizde burada görünecek.',
                textAlign: TextAlign.center,
                style: AppTextStyles.screenSubtitle.copyWith(
                  fontSize: 17,
                  color: AppColors.gray300,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteNotFoundState() {
    final PlaceCandidate place = _routeErrorPlace!;

    return NoDirectRouteState(
      placeName: place.name,
      placeAddress: place.address,
      primaryButtonText: 'Favorilere geri dön',
      primaryButtonSemanticsLabel: 'Favorilere geri dön',
      onPrimaryPressed: () {
        setState(() {
          _routeErrorPlace = null;
        });
      },
    );
  }

  Widget _buildFavoriteCard(BuildContext context, PlaceCandidate place) {
    return Material(
      color: AppColors.gray800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.roundedXl),
        side: const BorderSide(color: AppColors.borderBlue500, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFavoriteInfo(place),
            const SizedBox(height: AppSpacing.spaceY4),
            _buildFavoriteActions(context, place),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteInfo(PlaceCandidate place) {
    return Semantics(
      label: 'Favori hedef. ${place.name}. Adres: ${place.address}.',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.favorite,
                color: AppColors.orange600,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceX3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteActions(BuildContext context, PlaceCandidate place) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRouteActionButton(context, place),
        const SizedBox(height: AppSpacing.spaceY4),
        _buildRemoveFavoriteButton(place),
      ],
    );
  }

  Widget _buildRouteActionButton(BuildContext context, PlaceCandidate place) {
    return AppButton(
      fullWidth: true,
      size: 'large',
      minHeight: 56,
      backgroundColor: AppColors.blue600,
      semanticsLabel: '${place.name} için rota oluştur',
      onPressed: () => _createRouteForFavorite(context, place),
      child: const Text(
        'Rota Oluştur',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRemoveFavoriteButton(PlaceCandidate place) {
    return AppButton(
      fullWidth: true,
      size: 'large',
      minHeight: 56,
      variant: 'secondary',
      semanticsLabel: '${place.name} hedefini favorilerden çıkar',
      onPressed: () => _removeFavorite(place),
      child: const Text(
        'Favorilerden Çıkar',
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _favorites.map((PlaceCandidate place) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spaceY4),
          child: _buildFavoriteCard(context, place),
        );
      }).toList(),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }
    if (_favorites.isEmpty) {
      return _buildEmptyState();
    }
    if (_routeErrorPlace != null) {
      return _buildRouteNotFoundState();
    }
    return _buildFavoritesList(context);
  }

  Widget _buildFavoritesView(BuildContext context) {
    final bool hasFeedback = _feedbackMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Semantics(
            header: true,
            child: Text(
              'Favori hedefleriniz',
              style: AppTextStyles.screenTitle,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.p6),
        if (hasFeedback) ...[
          _buildFeedbackBanner(),
          const SizedBox(height: AppSpacing.spaceY4),
        ],
        _buildContent(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(title: 'Favori Yerler'),
      body: SafeArea(
        child: SingleChildScrollView(
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
      ),
    );
  }
}
