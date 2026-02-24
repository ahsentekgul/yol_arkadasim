import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_radius.dart';
import '../widgets/navigation_header.dart';
import 'notifications_screen.dart';
import '../widgets/voice_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentView = 'main'; // 'main' | 'search' | 'routes' | 'favorites' | 'nearby'
  String searchQuery = '';
  List<Map<String, dynamic>> searchResults = [];

  // Mock data
  final List<Map<String, String>> mockFavorites = [
    {'id': '1', 'name': 'İş Yeri', 'address': 'Levent Metro İstasyonu'},
    {'id': '2', 'name': 'Ev', 'address': 'Kadıköy İskelesi'},
  ];

  final List<Map<String, dynamic>> mockNearbyStops = [
    {
      'id': '1',
      'name': 'Taksim Meydanı',
      'distance': '0.2 km uzakta',
      'accessible': true,
      'audio': true
    },
    {
      'id': '2',
      'name': 'Şişli Metro',
      'distance': '0.5 km uzakta',
      'accessible': true,
      'audio': false
    },
  ];

  final List<Map<String, dynamic>> mockRoutes = [
    {
      'id': 1,
      'routeName': 'Metro M2 Hattı',
      'duration': '25 dakika',
      'transfers': 0,
      'accessibility': true,
      'steps': [
        {'type': 'walk', 'description': "Taksim Metro'ya yürü", 'duration': '3 dk'},
        {'type': 'metro', 'description': "M2 Metro - Hacıosman yönü", 'duration': '18 dk'},
        {'type': 'walk', 'description': "Levent Metro'dan hedefe yürü", 'duration': '4 dk'}
      ]
    },
    {
      'id': 2,
      'routeName': 'Otobüs 42T + Metro',
      'duration': '32 dakika',
      'transfers': 1,
      'accessibility': true,
      'steps': [
        {'type': 'walk', 'description': 'Otobüs durağına yürü', 'duration': '2 dk'},
        {'type': 'bus', 'description': '42T Otobüsü - Mecidiyeköy', 'duration': '15 dk'},
        {'type': 'walk', 'description': "Metro'ya transfer", 'duration': '3 dk'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    // UI-only: no timers, no backend
  }

  void handleVoiceResult(String text) {
    setState(() {
      searchQuery = text;
    });
    // TODO: speak('$text alındı') - voice announcement (UI-only)
    // TODO: vibrate short
  }

  void handleVoiceSearch(String query) {
    setState(() {
      searchQuery = query;
      // simulate search results
      searchResults = mockRoutes;
      currentView = 'routes';
    });
    // TODO: speak('$query aranıyor')
    // TODO: vibrate short
  }

  void handleSearchDestination() {
    setState(() {
      currentView = 'search';
    });
    // TODO: announce navigation
  }

  void handleFavoritePlaces() {
    setState(() {
      currentView = 'favorites';
    });
    // TODO: announce navigation
  }

  void handleNearbyStops() {
    setState(() {
      currentView = 'nearby';
    });
    // TODO: announce navigation
  }

  void handleSearchSubmit() {
    if (searchQuery.trim().isEmpty) return;
    setState(() {
      searchResults = mockRoutes;
      currentView = 'routes';
    });
    // TODO: speak('Rota bulundu')
  }

  void handleButtonPress(String action) {
    // short visual feedback only
    switch (action) {
      case 'search':
        handleSearchDestination();
        break;
      case 'favorites':
        handleFavoritePlaces();
        break;
      case 'nearby':
        handleNearbyStops();
        break;
      case 'back':
        setState(() {
          currentView = 'main';
          searchQuery = '';
          searchResults = [];
        });
        break;
    }
  }

  void handleRouteSelect(Map<String, dynamic> route) {
    // UI-only: simulate starting navigation
    debugPrint('Navigasyon başlatıldı (demo): ${route['routeName']}');
    // TODO: speak('${route['routeName']} ile navigasyon başladı')
    // TODO: vibrate pattern
    // Navigation to NotificationsScreen or live navigation is not implemented (UI-only)
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'YolArkadaşım',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Erişilebilir ulaşım yardımcınız',
              style: TextStyle(color: AppColors.gray300, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Hedef Bul (large card)
          AppButton(
            child: Row(
              children: [
                const Icon(Icons.search, size: 32, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Hedef Bul')),
              ],
            ),
            onPressed: () => handleButtonPress('search'),
            semanticsLabel: 'Hedef bul - Ana arama fonksiyonu',
            fullWidth: true,
            size: 'custom',
            minHeight: 120,
          ),
          const SizedBox(height: 12),

          // Favorites and Nearby
          Column(
            children: [
              AppButton(
                child: Row(
                  children: [
                    const Icon(Icons.favorite, size: 24, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Favori Yerler')),
                  ],
                ),
                onPressed: () => handleButtonPress('favorites'),
                semanticsLabel: 'Favori yerler - kayıtlı konumları görüntüle',
                fullWidth: true,
                size: 'custom',
                minHeight: 100,
              ),
              const SizedBox(height: 8),
              AppButton(
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 24, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Yakındaki Duraklar')),
                  ],
                ),
                onPressed: () => handleButtonPress('nearby'),
                semanticsLabel: 'Yakındaki duraklar - çevredeki durakları bul',
                fullWidth: true,
                size: 'custom',
                minHeight: 100,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Voice Button
          VoiceButton(
            onVoiceResult: handleVoiceResult,
            semanticsLabel: 'Sesli komut - sesle hedef belirle',
          ),
          const SizedBox(height: 12),

          AppButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.notifications, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text('Bildirim Demo'),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            semanticsLabel: 'Bildirim demo - yolculuk bildirimlerini görüntüle',
            fullWidth: true,
            size: 'custom',
            minHeight: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          controller: TextEditingController(text: searchQuery),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.gray800,
            hintText: 'Hedef girin...',
            hintStyle: const TextStyle(color: AppColors.gray300),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
              borderSide: BorderSide(color: AppColors.gray700),
            ),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),
        AppButton(
          child: const Text('Rota Ara'),
          onPressed: handleSearchSubmit,
          semanticsLabel: 'Rota ara - girilen hedef için',
          fullWidth: true,
        ),
        const SizedBox(height: 8),
        AppButton(
          child: const Text('Sesli Arama'),
          onPressed: () => debugPrint('Sesli arama (demo)'),
          semanticsLabel: 'Sesli arama - hedefi sesle söyleyin',
          fullWidth: true,
        ),
        const SizedBox(height: 8),
        AppButton(
          child: const Text('Ana Menüye Dön'),
          onPressed: () => handleButtonPress('back'),
          semanticsLabel: 'Ana menüye dön',
        ),
      ],
    );
  }

  Widget _buildRoutesView() {
    return Column(
      children: [
        Text(
          '$searchQuery için Rotalar',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Column(
          children: searchResults.map((route) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: AppButton(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(route['routeName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('${route['duration']} • ${route['transfers']} aktarma', style: const TextStyle(color: AppColors.gray300)),
                  ],
                ),
                onPressed: () => handleRouteSelect(route),
                fullWidth: true,
                size: 'custom',
                minHeight: 120,
                semanticsLabel: '${route['routeName']} rotası',
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        AppButton(
          child: const Text('Ana Menüye Dön'),
          onPressed: () => handleButtonPress('back'),
          semanticsLabel: 'Ana menüye dön',
        ),
      ],
    );
  }

  Widget _buildFavoritesView() {
    return Column(
      children: [
        const Text('Favorileriniz', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Column(
          children: mockFavorites.map((fav) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AppButton(
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 28, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fav['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(fav['address']!, style: const TextStyle(color: AppColors.gray300)),
                        ],
                      ),
                    )
                  ],
                ),
                onPressed: () => debugPrint('Favori seçildi: ${fav['name']} (demo)'),
                semanticsLabel: 'Favori seç: ${fav['name']}',
                fullWidth: true,
                size: 'custom',
                minHeight: 200,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        AppButton(
          child: const Text('Ana Menüye Dön'),
          onPressed: () => handleButtonPress('back'),
          semanticsLabel: 'Ana menüye dön',
        ),
      ],
    );
  }

  Widget _buildNearbyView() {
    return Column(
      children: [
        const Text('Yakındaki Duraklar', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Column(
          children: mockNearbyStops.map((stop) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AppButton(
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 32, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(stop['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              if (stop['accessible'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.borderGreen500, borderRadius: BorderRadius.circular(12)),
                                  child: const Text('Erişilebilir', style: TextStyle(color: Colors.white, fontSize: 12)),
                                )
                              ]
                            ],
                          ),
                          Text(stop['distance'], style: const TextStyle(color: AppColors.gray300)),
                        ],
                      ),
                    )
                  ],
                ),
                onPressed: () => debugPrint('Durak seçildi: ${stop['name']} (demo)'),
                semanticsLabel: 'Durak seç: ${stop['name']}',
                fullWidth: true,
                size: 'custom',
                minHeight: 200,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        AppButton(
          child: const Text('Ana Menüye Dön'),
          onPressed: () => handleButtonPress('back'),
          semanticsLabel: 'Ana menüye dön',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (currentView) {
      case 'search':
        content = _buildSearchView();
        break;
      case 'routes':
        content = _buildRoutesView();
        break;
      case 'favorites':
        content = _buildFavoritesView();
        break;
      case 'nearby':
        content = _buildNearbyView();
        break;
      default:
        content = _buildMainView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const NavigationHeader(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

