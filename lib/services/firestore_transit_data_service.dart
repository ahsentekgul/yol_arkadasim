import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';

class FirestoreTransitDataService {
  Future<List<Stop>> fetchStops() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('stops').get();

      final List<Stop> stops = <Stop>[];

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final Stop? stop = _toStop(doc.id, doc.data());
        if (stop != null) {
          stops.add(stop);
        }
      }

      return stops;
    } catch (_) {
      return <Stop>[];
    }
  }

  Future<List<TransitRoute>> fetchTransitRoutes() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('routes').get();

      final List<TransitRoute> routes = <TransitRoute>[];

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final TransitRoute? route = _toTransitRoute(doc.id, doc.data());
        if (route != null) {
          routes.add(route);
        }
      }

      return routes;
    } catch (_) {
      return <TransitRoute>[];
    }
  }

  Stop? _toStop(String docId, Map<String, dynamic> data) {
    final Object? name = data['name'];
    final Object? latitude = data['latitude'];
    final Object? longitude = data['longitude'];

    if (name is! String) {
      return null;
    }
    if (latitude is! num || longitude is! num) {
      return null;
    }

    return Stop(
      id: docId,
      name: name,
      location: AppLocation(
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      ),
    );
  }

  TransitRoute? _toTransitRoute(String docId, Map<String, dynamic> data) {
    final Object? name = data['name'];
    final Object? directionName = data['directionName'];
    final Object? estimatedMinutes = data['estimatedMinutes'];
    final Object? stopIds = data['stopIds'];

    if (name is! String || directionName is! String) {
      return null;
    }
    if (estimatedMinutes is! num) {
      return null;
    }
    if (stopIds is! List) {
      return null;
    }

    final List<String> parsedStopIds = <String>[];
    for (final Object? stopId in stopIds) {
      if (stopId is! String) {
        return null;
      }
      parsedStopIds.add(stopId);
    }

    return TransitRoute(
      id: docId,
      name: name,
      directionName: directionName,
      stopIds: parsedStopIds,
      estimatedMinutes: estimatedMinutes.round(),
    );
  }
}
