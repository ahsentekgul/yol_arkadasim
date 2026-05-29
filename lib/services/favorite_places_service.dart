import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';

class FavoritePlacesService {
  static const String _favoritesKey = 'favorite_places';

  Future<List<PlaceCandidate>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_favoritesKey);
      if (jsonString == null || jsonString.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return [];
      }

      final favorites = <PlaceCandidate>[];
      for (final item in decoded) {
        final map = _asStringKeyMap(item);
        if (map == null) {
          continue;
        }
        final place = _mapToPlaceCandidate(map);
        if (place != null) {
          favorites.add(place);
        }
      }
      return favorites;
    } catch (_) {
      return [];
    }
  }

  Future<bool> isFavorite(String? placeId) async {
    if (placeId == null) {
      return false;
    }
    if (placeId.trim().isEmpty) {
      return false;
    }

    final favorites = await getFavorites();
    return favorites.any((favorite) => favorite.placeId == placeId);
  }

  Future<void> addFavorite(PlaceCandidate place) async {
    if (place.placeId.trim().isEmpty) {
      return;
    }

    final favorites = await getFavorites();
    if (favorites.any((favorite) => favorite.placeId == place.placeId)) {
      return;
    }

    favorites.add(place);
    await _saveFavorites(favorites);
  }

  Future<void> removeFavorite(String? placeId) async {
    if (placeId == null) {
      return;
    }
    if (placeId.trim().isEmpty) {
      return;
    }

    final favorites = await getFavorites();
    final updated =
        favorites.where((favorite) => favorite.placeId != placeId).toList();
    if (updated.length == favorites.length) {
      return;
    }

    await _saveFavorites(updated);
  }

  Future<bool> toggleFavorite(PlaceCandidate place) async {
    if (place.placeId.trim().isEmpty) {
      return false;
    }

    final alreadyFavorite = await isFavorite(place.placeId);
    if (alreadyFavorite) {
      await removeFavorite(place.placeId);
      return false;
    }

    await addFavorite(place);
    return true;
  }

  Future<void> _saveFavorites(List<PlaceCandidate> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map(_placeCandidateToMap).toList();
    await prefs.setString(_favoritesKey, jsonEncode(jsonList));
  }

  Map<String, dynamic> _placeCandidateToMap(PlaceCandidate place) {
    return <String, dynamic>{
      'id': place.id,
      'placeId': place.placeId,
      'name': place.name,
      'address': place.address,
      'latitude': place.location.latitude,
      'longitude': place.location.longitude,
    };
  }

  PlaceCandidate? _mapToPlaceCandidate(Map<String, dynamic> map) {
    final id = map['id'];
    final placeId = map['placeId'];
    final name = map['name'];
    final address = map['address'];
    final latitude = map['latitude'];
    final longitude = map['longitude'];

    if (id is! String) {
      return null;
    }
    if (placeId is! String) {
      return null;
    }
    if (name is! String) {
      return null;
    }
    if (address is! String) {
      return null;
    }
    if (latitude is! num) {
      return null;
    }
    if (longitude is! num) {
      return null;
    }
    if (placeId.trim().isEmpty) {
      return null;
    }

    return PlaceCandidate(
      id: id,
      placeId: placeId,
      name: name,
      address: address,
      location: AppLocation(
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      ),
    );
  }

  Map<String, dynamic>? _asStringKeyMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    }
    if (item is Map) {
      return item.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }
}
