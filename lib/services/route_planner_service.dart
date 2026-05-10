import 'package:yol_arkadasim/data/models/transit_models.dart';
import 'package:yol_arkadasim/data/dummy/dummy_transit_data.dart';

class RoutePlannerService {
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
            final int totalEstimatedMinutes =
                route.estimatedMinutes + walkToStartMinutes + walkToDestinationMinutes;
            return JourneyPlan(
              destinationName: destination.name,
              routeName: route.name,
              totalDurationText: 'Yaklaşık $totalEstimatedMinutes dakika',
              transferCount: 0,
              startStopName: startStop.name,
              endStopName: endStop.name,
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
                  description: '${destination.name} konumuna doğru devam edin.',
                  durationText: 'Yaklaşık $walkToDestinationMinutes dakika',
                ),
              ],
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
}
