import 'package:flutter/material.dart';

import 'package:yol_arkadasim/business/journey_detail/journey_detail_screen.dart';
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
      _showMessage('Favori kaldırılamadı.');
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
      _showMessage('Favori kaldırılamadı.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
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
    );
  }

  Widget _buildEmptyState() {
    return Padding(
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
    );
  }

  Widget _buildRouteNotFoundState() {
    final PlaceCandidate place = _routeErrorPlace!;
    final String placeName = place.name;
    final String placeAddress = place.address;

    return Semantics(
      container: true,
      liveRegion: true,
      label:
          'Aktarmasız rota bulunamadı. Seçilen hedef: $placeName, $placeAddress. '
          'Bu favori hedef için şu an sistemde uygun aktarmasız rota bulunamadı.',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExcludeSemantics(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.orange600,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceX3),
                Expanded(
                  child: Text(
                    'Aktarmasız rota bulunamadı',
                    style: AppTextStyles.buttonLabel.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceY4),
            Container(
              padding: const EdgeInsets.all(AppSpacing.p6),
              decoration: BoxDecoration(
                color: AppColors.gray800,
                borderRadius: BorderRadius.circular(AppRadius.roundedXl),
                border: Border.all(color: AppColors.gray700, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seçilen hedef',
                    style: AppTextStyles.screenSubtitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray300,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceX3),
                  Text(
                    placeName,
                    style: AppTextStyles.buttonLabel.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceX3),
                  Text(
                    placeAddress,
                    style: AppTextStyles.screenSubtitle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray300,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceY4),
            Text(
              'Bu favori hedef için şu an sistemde uygun aktarmasız rota bulunamadı.',
              style: AppTextStyles.screenSubtitle.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.gray300,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.p8),
            AppButton(
              fullWidth: true,
              semanticsLabel: 'Favorilere geri dön',
              onPressed: () {
                setState(() {
                  _routeErrorPlace = null;
                });
              },
              child: const Text('Favorilere geri dön'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, PlaceCandidate place) {
    return Material(
      color: AppColors.gray800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.roundedXl),
        side: const BorderSide(color: AppColors.gray700, width: 1.2),
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
        overflow: TextOverflow.ellipsis,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'Favorileriniz',
            style: AppTextStyles.screenTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.p6),
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
