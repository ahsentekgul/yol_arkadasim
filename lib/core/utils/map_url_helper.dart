import 'package:yol_arkadasim/data/models/transit_models.dart';

Uri buildWalkingDirectionsUri(AppLocation destination) {
  return Uri.https(
    'www.google.com',
    '/maps/dir/',
    <String, String>{
      'api': '1',
      'destination': '${destination.latitude},${destination.longitude}',
      'travelmode': 'walking',
    },
  );
}
