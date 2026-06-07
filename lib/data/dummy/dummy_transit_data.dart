import 'package:yol_arkadasim/data/models/transit_models.dart';

class DummyTransitData {
  static const AppLocation userLocation = AppLocation(
    latitude: 38.7235,
    longitude: 35.4868,
  );

  static const List<Stop> stops = <Stop>[
    Stop(
      id: 'stop_001',
      name: 'Talas Bulvarı Durağı',
      location: AppLocation(latitude: 38.7240, longitude: 35.4873),
    ),
    Stop(
      id: 'stop_002',
      name: 'Mimarsinan Parkı Durağı',
      location: AppLocation(latitude: 38.7209, longitude: 35.4920),
    ),
    Stop(
      id: 'stop_003',
      name: 'Erciyes Üniversitesi Giriş Durağı',
      location: AppLocation(latitude: 38.7084, longitude: 35.5282),
    ),
    Stop(
      id: 'stop_004',
      name: 'Hastane Caddesi Durağı',
      location: AppLocation(latitude: 38.7228, longitude: 35.4891),
    ),
    Stop(
      id: 'stop_005',
      name: 'Şehir Hastanesi Durağı',
      location: AppLocation(latitude: 38.7170, longitude: 35.5030),
    ),
  ];

  static final List<Destination> destinations =
      List.unmodifiable(<Destination>[
    Destination(
      id: 'destination_erciyes_university',
      name: 'Erciyes Üniversitesi',
      location: const AppLocation(latitude: 38.7078, longitude: 35.5290),
      keywords: <String>[
        'erciyes',
        'erciyes üniversitesi',
        'erciyes universitesi',
        'üniversite',
        'universite',
        'kampüs',
        'kampus',
      ],
    ),
    Destination(
      id: 'destination_sehir_hastanesi',
      name: 'Kayseri Şehir Hastanesi',
      location: const AppLocation(latitude: 38.7168, longitude: 35.5035),
      keywords: <String>[
        'hastane',
        'şehir hastanesi',
        'sehir hastanesi',
        'kayseri hastane',
        'hospital',
      ],
    ),
  ]);

  static final List<TransitRoute> transitRoutes =
      List.unmodifiable(<TransitRoute>[
    TransitRoute(
      id: 'route_800_erciyes_direction',
      name: '800',
      directionName: 'Erciyes Üniversitesi',
      stopIds: <String>['stop_001', 'stop_002', 'stop_003'],
      estimatedMinutes: 28,
    ),
    TransitRoute(
      id: 'route_800_city_center_direction',
      name: '800',
      directionName: 'Şehir Merkezi',
      stopIds: <String>['stop_003', 'stop_002', 'stop_001'],
      estimatedMinutes: 30,
    ),
    TransitRoute(
      id: 'route_102_hastane_direction',
      name: '102',
      directionName: 'Şehir Hastanesi',
      stopIds: <String>['stop_004', 'stop_005'],
      estimatedMinutes: 12,
    ),
    TransitRoute(
      id: 'route_102_talas_direction',
      name: '102',
      directionName: 'Talas',
      stopIds: <String>['stop_005', 'stop_004'],
      estimatedMinutes: 12,
    ),
  ]);
}