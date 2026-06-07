class AppLocation {
  final double latitude;
  final double longitude;

  const AppLocation({
    required this.latitude,
    required this.longitude,
  });
}

class Stop {
  final String id;
  final String name;
  final AppLocation location;

  const Stop({
    required this.id,
    required this.name,
    required this.location,
  });
}

class Destination {
  final String id;
  final String name;
  final AppLocation location;
  final List<String> keywords;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required List<String> keywords,
  }) : keywords = List.unmodifiable(keywords);
}

class TransitRoute {
  final String id;
  final String name;
  final String directionName;
  final List<String> stopIds;
  final int estimatedMinutes;

  TransitRoute({
    required this.id,
    required this.name,
    required this.directionName,
    required List<String> stopIds,
    required this.estimatedMinutes,
  }) : stopIds = List.unmodifiable(stopIds);
}

class JourneyStep {
  final String title;
  final String description;
  final String durationText;

  const JourneyStep({
    required this.title,
    required this.description,
    required this.durationText,
  });
}

class JourneyNavigationMetadata {
  final String routeId;
  final String startStopId;
  final AppLocation startStopLocation;
  final String endStopId;
  final AppLocation endStopLocation;
  final String? destinationAddress;
  final AppLocation destinationLocation;
  final String? placeId;

  const JourneyNavigationMetadata({
    required this.routeId,
    required this.startStopId,
    required this.startStopLocation,
    required this.endStopId,
    required this.endStopLocation,
    required this.destinationLocation,
    this.destinationAddress,
    this.placeId,
  });
}

class JourneyPlan {
  final String destinationName;
  final String routeName;
  final String totalDurationText;
  final int transferCount;
  final String startStopName;
  final String endStopName;
  final JourneyNavigationMetadata navigationMetadata;
  final List<JourneyStep> steps;

  JourneyPlan({
    required this.destinationName,
    required this.routeName,
    required this.totalDurationText,
    required this.transferCount,
    required this.startStopName,
    required this.endStopName,
    required this.navigationMetadata,
    required List<JourneyStep> steps,
  }) : steps = List.unmodifiable(steps);
}
