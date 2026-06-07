import 'package:yol_arkadasim/data/models/transit_models.dart';

class PlaceCandidate {
  final String id;
  final String placeId;
  final String name;
  final String address;
  final AppLocation location;

  const PlaceCandidate({
    required this.id,
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
  });
}
