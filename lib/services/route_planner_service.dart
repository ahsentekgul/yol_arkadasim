import 'dart:math' as math;

import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';
import 'package:yol_arkadasim/data/dummy/dummy_transit_data.dart';

class RoutePlannerService {
  static const double _maxWalkingDistanceMeters = 500;

  final AppLocation userLocation;
  final List<Stop> stops;
  final List<Destination> destinations;
  final List<TransitRoute> transitRoutes;

  RoutePlannerService({
    AppLocation? userLocation,
    List<Stop>? stops,
    List<Destination>? destinations,
    List<TransitRoute>? transitRoutes,
  })  : userLocation = userLocation ?? DummyTransitData.userLocation,
        stops = List.unmodifiable(stops ?? DummyTransitData.stops),
        destinations =
            List.unmodifiable(destinations ?? DummyTransitData.destinations),
        transitRoutes =
            List.unmodifiable(transitRoutes ?? DummyTransitData.transitRoutes);

  JourneyPlan? createJourneyPlan(String query) {
    final String normalizedQuery = _normalizeText(query);
    if (normalizedQuery.isEmpty) return null;

    final Destination? destination = _findDestination(normalizedQuery);
    if (destination == null) return null;

    final List<Stop> startCandidates =
        _sortStopsByDistance(userLocation, stops);
    final List<Stop> endCandidates =
        _sortStopsByDistance(destination.location, stops);

    if (startCandidates.isEmpty || endCandidates.isEmpty) return null;

    for (final Stop startStop in startCandidates) {
      for (final Stop endStop in endCandidates) {
        if (startStop.id == endStop.id) continue;

        for (final TransitRoute route in transitRoutes) {
          final int startIndex = route.stopIds.indexOf(startStop.id);
          final int endIndex = route.stopIds.indexOf(endStop.id);

          if (startIndex >= 0 && endIndex >= 0 && startIndex < endIndex) {
            const int walkToStartMinutes = 5;
            const int walkToDestinationMinutes = 3;
            return _buildJourneyPlan(
              destinationName: destination.name,
              route: route,
              startStop: startStop,
              endStop: endStop,
              walkToStartMinutes: walkToStartMinutes,
              walkToDestinationMinutes: walkToDestinationMinutes,
              navigationMetadata: JourneyNavigationMetadata(
                routeId: route.id,
                startStopId: startStop.id,
                startStopLocation: startStop.location,
                endStopId: endStop.id,
                endStopLocation: endStop.location,
                destinationAddress: null,
                destinationLocation: destination.location,
                placeId: null,
              ),
            );
          }
        }
      }
    }

    return null;
  }

  JourneyPlan? createJourneyPlanForPlace(PlaceCandidate place) {
    final List<Stop> startCandidates =
        _findStopsWithinWalkingDistance(userLocation);
    final List<Stop> endCandidates =
        _findStopsWithinWalkingDistance(place.location);

    if (startCandidates.isEmpty || endCandidates.isEmpty) return null;

    for (final Stop startStop in startCandidates) {
      for (final Stop endStop in endCandidates) {
        if (startStop.id == endStop.id) continue;

        for (final TransitRoute route in transitRoutes) {
          final int startIndex = route.stopIds.indexOf(startStop.id);
          final int endIndex = route.stopIds.indexOf(endStop.id);

          if (startIndex >= 0 && endIndex >= 0 && startIndex < endIndex) {
            final int walkToStartMinutes = _estimateWalkingMinutes(
              _distanceInMeters(userLocation, startStop.location),
            );
            final int walkToDestinationMinutes = _estimateWalkingMinutes(
              _distanceInMeters(endStop.location, place.location),
            );

            return _buildJourneyPlan(
              destinationName: place.name,
              route: route,
              startStop: startStop,
              endStop: endStop,
              walkToStartMinutes: walkToStartMinutes,
              walkToDestinationMinutes: walkToDestinationMinutes,
              navigationMetadata: JourneyNavigationMetadata(
                routeId: route.id,
                startStopId: startStop.id,
                startStopLocation: startStop.location,
                endStopId: endStop.id,
                endStopLocation: endStop.location,
                destinationAddress: place.address,
                destinationLocation: place.location,
                placeId: place.placeId,
              ),
            );
          }
        }
      }
    }

    return null;
  }

  Destination? _findDestination(String normalizedQuery) {
    for (final Destination destination in destinations) {
      final String normalizedName = _normalizeText(destination.name);
      if (normalizedName.contains(normalizedQuery) ||
          normalizedQuery.contains(normalizedName)) {
        return destination;
      }

      for (final String keyword in destination.keywords) {
        final String normalizedKeyword = _normalizeText(keyword);
        if (normalizedKeyword.contains(normalizedQuery) ||
            normalizedQuery.contains(normalizedKeyword)) {
          return destination;
        }
      }
    }
    return null;
  }

  List<Stop> _sortStopsByDistance(AppLocation reference, List<Stop> source) {
    final List<Stop> sorted = List<Stop>.from(source);
    sorted.sort((Stop a, Stop b) {
      final double aScore = _distanceScore(reference, a.location);
      final double bScore = _distanceScore(reference, b.location);
      return aScore.compareTo(bScore);
    });
    return sorted;
  }

  List<Stop> _findStopsWithinWalkingDistance(AppLocation reference) {
    final List<Stop> candidates = stops.where((Stop stop) {
      return _distanceInMeters(reference, stop.location) <=
          _maxWalkingDistanceMeters;
    }).toList();

    candidates.sort((Stop a, Stop b) {
      final double aDistance = _distanceInMeters(reference, a.location);
      final double bDistance = _distanceInMeters(reference, b.location);
      return aDistance.compareTo(bDistance);
    });

    return candidates;
  }

  JourneyPlan _buildJourneyPlan({
    required String destinationName,
    required TransitRoute route,
    required Stop startStop,
    required Stop endStop,
    required int walkToStartMinutes,
    required int walkToDestinationMinutes,
    required JourneyNavigationMetadata navigationMetadata,
  }) {
    final int totalEstimatedMinutes =
        route.estimatedMinutes + walkToStartMinutes + walkToDestinationMinutes;

    return JourneyPlan(
      destinationName: destinationName,
      routeName: route.name,
      totalDurationText: 'Yaklaşık $totalEstimatedMinutes dakika',
      transferCount: 0,
      startStopName: startStop.name,
      endStopName: endStop.name,
      navigationMetadata: navigationMetadata,
      steps: <JourneyStep>[
        JourneyStep(
          title: 'Durağa git',
          description: 'En yakın uygun durak: ${startStop.name}.',
          durationText: 'Yaklaşık $walkToStartMinutes dakika',
        ),
        JourneyStep(
          title: 'Araca bin',
          description: '${route.name} - ${route.directionName} yönüne binin.',
          durationText: 'Yaklaşık ${route.estimatedMinutes} dakika',
        ),
        JourneyStep(
          title: 'Durakta in',
          description: '${endStop.name} konumunda inin.',
          durationText: 'Varış',
        ),
        JourneyStep(
          title: 'Hedefe ilerle',
          description: '$destinationName konumuna doğru devam edin.',
          durationText: 'Yaklaşık $walkToDestinationMinutes dakika',
        ),
      ],
    );
  }

  int _estimateWalkingMinutes(double distanceInMeters) {
    const double averageWalkingSpeedMetersPerMinute = 80;
    return math.max(
      1,
      (distanceInMeters / averageWalkingSpeedMetersPerMinute).ceil(),
    );
  }

  String _normalizeText(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('\u0307', '')
        .replaceAll('ı', 'i')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g');
  }

  double _distanceScore(AppLocation a, AppLocation b) {
    final double latitudeDifference = a.latitude - b.latitude;
    final double longitudeDifference = a.longitude - b.longitude;
    return (latitudeDifference * latitudeDifference) +
        (longitudeDifference * longitudeDifference);
  }

  double _distanceInMeters(AppLocation a, AppLocation b) {
    const double earthRadiusMeters = 6371000;

    final double latitude1 = _degreesToRadians(a.latitude);
    final double latitude2 = _degreesToRadians(b.latitude);
    final double deltaLatitude = _degreesToRadians(b.latitude - a.latitude);
    final double deltaLongitude = _degreesToRadians(b.longitude - a.longitude);

    final double haversine =
        math.sin(deltaLatitude / 2) * math.sin(deltaLatitude / 2) +
            math.cos(latitude1) *
                math.cos(latitude2) *
                math.sin(deltaLongitude / 2) *
                math.sin(deltaLongitude / 2);

    final double arc =
        2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));

    return earthRadiusMeters * arc;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
