import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';

class FirestorePlaceSearchService {
  Future<List<PlaceCandidate>> searchPlaces(String query) async {
    try {
      final String normalizedQuery = _normalizeText(query);
      if (normalizedQuery.isEmpty) {
        return <PlaceCandidate>[];
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('places').get();

      final List<PlaceCandidate> matches = <PlaceCandidate>[];

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final PlaceCandidate? candidate = _toPlaceCandidate(doc.id, doc.data());
        if (candidate == null) {
          continue;
        }

        final String normalizedName = _normalizeText(candidate.name);
        final String normalizedAddress = _normalizeText(candidate.address);
        if (normalizedName.contains(normalizedQuery) ||
            normalizedAddress.contains(normalizedQuery)) {
          matches.add(candidate);
        }
      }

      return matches;
    } catch (_) {
      return <PlaceCandidate>[];
    }
  }

  PlaceCandidate? _toPlaceCandidate(
    String docId,
    Map<String, dynamic> data,
  ) {
    final Object? name = data['name'];
    final Object? address = data['address'];
    final Object? placeId = data['placeId'];
    final Object? latitude = data['latitude'];
    final Object? longitude = data['longitude'];

    if (name is! String || address is! String) {
      return null;
    }
    if (latitude is! num || longitude is! num) {
      return null;
    }

    return PlaceCandidate(
      id: docId,
      placeId: placeId is String ? placeId : docId,
      name: name,
      address: address,
      location: AppLocation(
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      ),
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
}
