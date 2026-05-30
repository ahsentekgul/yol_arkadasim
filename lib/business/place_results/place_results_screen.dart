import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:yol_arkadasim/business/journey_detail/journey_detail_screen.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/demo/demo_locations.dart';
import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/services/dummy_place_search_service.dart';
import 'package:yol_arkadasim/services/favorite_places_service.dart';
import 'package:yol_arkadasim/services/firestore_place_search_service.dart';
import 'package:yol_arkadasim/services/firestore_transit_data_service.dart';
import 'package:yol_arkadasim/services/route_planner_service.dart';

class PlaceResultsScreen extends StatefulWidget {
  const PlaceResultsScreen({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  State<PlaceResultsScreen> createState() => _PlaceResultsScreenState();
}

class _PlaceResultsScreenState extends State<PlaceResultsScreen> {
  RoutePlannerService _routePlannerService = RoutePlannerService(
    userLocation: DemoLocations.userLocation,
  );
  final FirestorePlaceSearchService _firestorePlaceSearchService =
      FirestorePlaceSearchService();
  final FirestoreTransitDataService _firestoreTransitDataService =
      FirestoreTransitDataService();
  final DummyPlaceSearchService _dummyPlaceSearchService =
      DummyPlaceSearchService();
  final FavoritePlacesService _favoritePlacesService = FavoritePlacesService();

  List<PlaceCandidate> _places = <PlaceCandidate>[];
  Set<String> _favoritePlaceIds = <String>{};
  bool _isPlacesLoading = true;
  bool _isTransitDataLoading = true;
  bool get _isLoading => _isPlacesLoading || _isTransitDataLoading;
  PlaceCandidate? _routeErrorPlace;
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _loadTransitData();
  }

  Future<void> _loadPlaces() async {
    List<PlaceCandidate> places = await _firestorePlaceSearchService
        .searchPlaces(widget.searchQuery);

    if (places.isEmpty) {
      places = _dummyPlaceSearchService.searchPlaces(widget.searchQuery);
    }

    final Set<String> favoritePlaceIds = await _loadFavoritePlaceIds();

    if (!mounted) {
      return;
    }

    setState(() {
      _places = places;
      _favoritePlaceIds = favoritePlaceIds;
      _isPlacesLoading = false;
    });
  }

  String _normalizedPlaceId(PlaceCandidate place) {
    return place.placeId.trim();
  }

  bool _isFavorite(PlaceCandidate place) {
    final String placeId = _normalizedPlaceId(place);
    if (placeId.isEmpty) {
      return false;
    }
    return _favoritePlaceIds.contains(placeId);
  }

  Future<Set<String>> _loadFavoritePlaceIds() async {
    try {
      final favorites = await _favoritePlacesService.getFavorites();
      final Set<String> placeIds = <String>{};
      for (final PlaceCandidate favorite in favorites) {
        final String placeId = _normalizedPlaceId(favorite);
        if (placeId.isNotEmpty) {
          placeIds.add(placeId);
        }
      }
      return placeIds;
    } catch (_) {
      return <String>{};
    }
  }

  void _announceFeedback(String message) {
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      SemanticsService.announce(message, Directionality.of(context));
    });
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
    _announceFeedback(message);
  }

  Future<void> _toggleFavorite(PlaceCandidate place) async {
    final String placeId = _normalizedPlaceId(place);
    if (placeId.isEmpty) {
      _showFeedback('Favori işlemi yapılamadı.', isError: true);
      return;
    }

    try {
      final bool added = await _favoritePlacesService.toggleFavorite(place);
      if (!mounted) {
        return;
      }

      final String message = added
          ? '${place.name} favorilere eklendi.'
          : '${place.name} favorilerden çıkarıldı.';

      setState(() {
        if (added) {
          _favoritePlaceIds.add(placeId);
        } else {
          _favoritePlaceIds.remove(placeId);
        }
        _feedbackMessage = message;
        _feedbackIsError = false;
      });
      _announceFeedback(message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showFeedback('Favori işlemi tamamlanamadı.', isError: true);
    }
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

  void _createRouteForPlace(BuildContext context, PlaceCandidate place) {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rota verileri yükleniyor. Lütfen birkaç saniye sonra tekrar deneyin.',
          ),
        ),
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

  Widget _buildLoadingState() {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Konum ve rota verileri yükleniyor.',
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
                  'Konum ve rota verileri yükleniyor.',
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
      container: true,
      label: 'Bu arama için konum sonucu bulunamadı.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
          child: Text(
            'Bu arama için konum sonucu bulunamadı.',
            textAlign: TextAlign.center,
            style: AppTextStyles.screenSubtitle.copyWith(
              fontSize: 18,
              color: AppColors.gray300,
            ),
          ),
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
            _buildPlaceInfo(place, resultNumber),
            const SizedBox(height: AppSpacing.spaceY4),
            _buildPlaceActions(context, place),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceInfo(PlaceCandidate place, int resultNumber) {
    return Semantics(
      label:
          '$resultNumber. sonuç. ${place.name}. Adres: ${place.address}.',
      child: ExcludeSemantics(
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
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceActions(BuildContext context, PlaceCandidate place) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRouteActionButton(context, place),
        const SizedBox(height: AppSpacing.spaceY4),
        _buildFavoriteActionButton(place),
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
      onPressed: () => _createRouteForPlace(context, place),
      child: const Text(
        'Rota Oluştur',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFavoriteActionButton(PlaceCandidate place) {
    final bool isFavorite = _isFavorite(place);

    return AppButton(
      fullWidth: true,
      size: 'large',
      minHeight: 64,
      backgroundColor: AppColors.orange600,
      semanticsLabel: isFavorite
          ? '${place.name} hedefini favorilerden çıkar'
          : '${place.name} hedefini favorilere ekle',
      onPressed: () => _toggleFavorite(place),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceX3),
          Flexible(
            child: Text(
              isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.buttonLabel.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteNotFoundState(BuildContext context) {
    final PlaceCandidate place = _routeErrorPlace!;
    final String placeName = place.name;
    final String placeAddress = place.address;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          liveRegion: true,
          label:
              'Aktarmasız rota bulunamadı. Seçilen hedef: $placeName, $placeAddress. '
              'Bu hedef için şu an sistemde uygun aktarmasız rota bulunamadı. '
              'Daha doğru yönlendirme için ilgili ulaşım birimiyle iletişime geçebilirsiniz. '
              'Kayseri Ulaşım Belediye iletişim bilgisi: Resmi numara eklenecek.',
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
                    border: Border.all(
                      color: AppColors.borderBlue500,
                      width: 1.2,
                    ),
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
                  'Bu hedef için şu an sistemde uygun aktarmasız rota bulunamadı.\n'
                  'Daha doğru yönlendirme için ilgili ulaşım birimiyle iletişime geçebilirsiniz.',
                  style: AppTextStyles.screenSubtitle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray300,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceY4),
                Text(
                  'Kayseri Ulaşım / Belediye iletişim bilgisi: Resmi numara eklenecek.',
                  style: AppTextStyles.screenSubtitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.borderOrange500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        AppButton(
          fullWidth: true,
          semanticsLabel: 'Sonuçlara geri dön',
          onPressed: () {
            setState(() {
              _routeErrorPlace = null;
            });
          },
          child: const Text('Sonuçlara geri dön'),
        ),
        const SizedBox(height: AppSpacing.spaceY4),
        AppButton(
          fullWidth: true,
          variant: 'secondary',
          semanticsLabel: 'Yeni arama yap',
          onPressed: () => Navigator.maybePop(context),
          child: const Text('Yeni arama yap'),
        ),
      ],
    );
  }

  Widget _buildFeedbackBanner() {
    if (_feedbackMessage == null) {
      return const SizedBox.shrink();
    }

    final Color borderColor = _feedbackIsError
        ? AppColors.borderOrange500
        : AppColors.borderGreen500;
    final IconData icon = _feedbackIsError
        ? Icons.error_outline
        : Icons.check_circle_outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceY4),
      child: Semantics(
        container: true,
        label: _feedbackMessage,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.p6),
          decoration: BoxDecoration(
            color: AppColors.gray800,
            borderRadius: BorderRadius.circular(AppRadius.roundedXl),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(icon, color: borderColor, size: 26),
              ),
              const SizedBox(width: AppSpacing.spaceX3),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    _feedbackMessage!,
                    style: AppTextStyles.screenSubtitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.35,
                    ),
                    softWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    return Semantics(
      label:
          '"${widget.searchQuery}" araması için ${_places.length} konum sonucu bulundu. '
          'Sonuç kartlarında rota oluşturabilir veya hedefi favorilere ekleyebilirsiniz.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.p6),
          child: Text(
            '${_places.length} sonuç bulundu',
            style: AppTextStyles.buttonLabel.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
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
        _buildFeedbackBanner(),
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
    if (_routeErrorPlace != null) {
      return _buildRouteNotFoundState(context);
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
