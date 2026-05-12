import 'package:yol_arkadasim/data/models/place_candidate.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';

class DummyPlaceSearchService {
  static final List<PlaceCandidate> _places = List<PlaceCandidate>.unmodifiable(
    <PlaceCandidate>[
      const PlaceCandidate(
        id: 'place_erciyes_university',
        placeId: 'dummy_place_erciyes_university',
        name: 'Erciyes Üniversitesi',
        address: 'Talas Bulvarı, Erciyes Üniversitesi Kampüsü, Kayseri',
        location: AppLocation(latitude: 38.7078, longitude: 35.5290),
      ),
      const PlaceCandidate(
        id: 'place_sehir_hastanesi',
        placeId: 'dummy_place_sehir_hastanesi',
        name: 'Kayseri Şehir Hastanesi',
        address: 'Hastane Caddesi, Kayseri',
        location: AppLocation(latitude: 38.7168, longitude: 35.5035),
      ),
      const PlaceCandidate(
        id: 'place_mevlana_firini',
        placeId: 'dummy_place_mevlana_firini',
        name: 'Mevlana Fırını',
        address: 'Mevlana Mahallesi, Talas, Kayseri',
        location: AppLocation(latitude: 38.7212, longitude: 35.4908),
      ),
      const PlaceCandidate(
        id: 'place_mevlana_mahallesi',
        placeId: 'dummy_place_mevlana_mahallesi',
        name: 'Mevlana Mahallesi',
        address: 'Talas, Kayseri',
        location: AppLocation(latitude: 38.7204, longitude: 35.4916),
      ),
      const PlaceCandidate(
        id: 'place_mevlana_parki',
        placeId: 'dummy_place_mevlana_parki',
        name: 'Mevlana Parkı',
        address: 'Mevlana Mahallesi Park Alanı, Talas, Kayseri',
        location: AppLocation(latitude: 38.7197, longitude: 35.4931),
      ),
    ],
  );

  List<PlaceCandidate> searchPlaces(String query) {
    final String normalizedQuery = _normalizeText(query);
    if (normalizedQuery.isEmpty) {
      return <PlaceCandidate>[];
    }

    final List<PlaceCandidate> matches = _places.where((PlaceCandidate place) {
      final String normalizedName = _normalizeText(place.name);
      final String normalizedAddress = _normalizeText(place.address);
      return normalizedName.contains(normalizedQuery) ||
          normalizedAddress.contains(normalizedQuery);
    }).toList();

    return List<PlaceCandidate>.from(matches);
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