import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import NavigationHeader from '../../components/feature/NavigationHeader';
import Button from '../../components/base/Button';
import VoiceButton from '../../components/base/VoiceButton';
import { useVoiceAnnouncement } from '../../hooks/useVoiceAnnouncement';
import { useVibration } from '../../hooks/useVibration';

// Mock data for demonstration
const mockFavorites = [
  { id: 1, name: 'İş Yeri', address: 'Levent Metro İstasyonu' },
  { id: 2, name: 'Ev', address: 'Kadıköy İskelesi' }
];

const mockNearbyStops = [
  { 
    id: 1, 
    name: 'Taksim Meydanı', 
    distance: '0.2 km uzakta',
    accessible: true,
    audio: true
  },
  { 
    id: 2, 
    name: 'Şişli Metro', 
    distance: '0.5 km uzakta',
    accessible: true,
    audio: false
  }
];

// Mock route data for search results
const mockRoutes = [
  {
    id: 1,
    routeName: 'Metro M2 Hattı',
    duration: '25 dakika',
    transfers: 0,
    accessibility: true,
    steps: [
      { type: 'walk', description: 'Taksim Metro\'ya yürü', duration: '3 dk' },
      { type: 'metro', description: 'M2 Metro - Hacıosman yönü', duration: '18 dk' },
      { type: 'walk', description: 'Levent Metro\'dan hedefe yürü', duration: '4 dk' }
    ]
  },
  {
    id: 2,
    routeName: 'Otobüs 42T + Metro',
    duration: '32 dakika',
    transfers: 1,
    accessibility: true,
    steps: [
      { type: 'walk', description: 'Otobüs durağına yürü', duration: '2 dk' },
      { type: 'bus', description: '42T Otobüsü - Mecidiyeköy', duration: '15 dk' },
      { type: 'walk', description: 'Metro\'ya transfer', duration: '3 dk' },
      { type: 'metro', description: 'M2 Metro - Hacıosman yönü', duration: '8 dk' },
      { type: 'walk', description: 'Hedefe yürü', duration: '4 dk' }
    ]
  },
  {
    id: 3,
    routeName: 'Otobüs 54HT',
    duration: '45 dakika',
    transfers: 0,
    accessibility: false,
    steps: [
      { type: 'walk', description: 'Otobüs durağına yürü', duration: '5 dk' },
      { type: 'bus', description: '54HT Otobüsü - Levent', duration: '35 dk' },
      { type: 'walk', description: 'Hedefe yürü', duration: '5 dk' }
    ]
  }
];

export default function HomePage() {
  const navigate = useNavigate();
  const [currentView, setCurrentView] = useState<'main' | 'search' | 'routes' | 'favorites' | 'nearby'>('main');
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<typeof mockRoutes>([]);
  
  // Voice and vibration settings
  const [settings] = useState({
    voiceEnabled: true,
    voiceSpeed: 1,
    vibrationEnabled: true
  });
  
  const { speak, announceNavigation, announceArrival, announceDirection } = useVoiceAnnouncement(settings);
  const { vibrate } = useVibration(settings);

  useEffect(() => {
    // Welcome announcement when app loads
    speak('YolArkadaşım\'a hoş geldiniz. Erişilebilir ulaşım navigasyon uygulamanız.');
  }, [speak]);

  const handleVoiceSearch = (query: string) => {
    setSearchQuery(query);
    speak(`${query} aranıyor`);
    vibrate('short');
    // Simulate search and show routes
    setTimeout(() => {
      setSearchResults(mockRoutes);
      setCurrentView('routes');
      speak(`${query} için ${mockRoutes.length} rota bulundu. Rotaları inceleyebilirsiniz.`);
    }, 1000);
  };

  const handleVoiceResult = (text: string) => {
    setSearchQuery(text);
    speak(`Sesli komut alındı: ${text}`);
    vibrate('short');
  };

  const handleSearchDestination = () => {
    setCurrentView('search');
    announceNavigation('Hedef arama açılıyor');
    vibrate('short');
  };

  const handleFavoritePlaces = () => {
    setCurrentView('favorites');
    announceNavigation('Favori duraklarınız gösteriliyor');
    vibrate('short');
  };

  const handleNearbyStops = () => {
    setCurrentView('nearby');
    announceNavigation('Yakındaki duraklar gösteriliyor');
    vibrate('short');
  };

  const handleSearchSubmit = () => {
    if (searchQuery.trim()) {
      speak(`${searchQuery} için rotalar aranıyor`);
      vibrate('short');
      // Simulate search
      setTimeout(() => {
        setSearchResults(mockRoutes);
        setCurrentView('routes');
        speak(`${searchQuery} için ${mockRoutes.length} rota bulundu. En iyi rotayı seçebilirsiniz.`);
      }, 1000);
    }
  };

  const handleButtonPress = (action: string) => {
    vibrate('short');
    
    switch (action) {
      case 'search':
        setCurrentView('search');
        announceNavigation('Hedef arama açılıyor');
        break;
      case 'favorites':
        setCurrentView('favorites');
        announceNavigation('Favori duraklarınız gösteriliyor');
        break;
      case 'nearby':
        setCurrentView('nearby');
        announceNavigation('Yakındaki duraklar gösteriliyor');
        break;
      case 'back':
        setCurrentView('main');
        setSearchQuery('');
        setSearchResults([]);
        announceNavigation('Ana menüye dönülüyor');
        break;
    }
  };

  const handleRouteSelect = (route: typeof mockRoutes[0]) => {
    speak(`${route.routeName} seçildi. ${route.duration} sürecek. Navigasyona başlanıyor.`);
    vibrate([200, 100, 200]);
    
    // Navigate to notifications page to show journey notifications
    navigate('/notifications');
    
    setTimeout(() => {
      speak(`${route.routeName} ile navigasyon başladı. Yolculuk sırasında bildirimler alacaksınız.`);
    }, 1000);
  };

  const handleDestinationSelect = (destination: string) => {
    speak(`Seçilen hedef: ${destination}. Rotalar aranıyor.`);
    vibrate('pattern');
    // Simulate route search
    setTimeout(() => {
      setSearchResults(mockRoutes);
      setCurrentView('routes');
      speak(`${destination} için ${mockRoutes.length} rota bulundu. En uygun rotayı seçebilirsiniz.`);
    }, 1000);
  };

  const getRouteIcon = (routeName: string) => {
    if (routeName.includes('Metro')) return 'ri-subway-line';
    if (routeName.includes('Otobüs')) return 'ri-bus-line';
    return 'ri-route-line';
  };

  const getStepIcon = (type: string) => {
    switch (type) {
      case 'walk': return 'ri-walk-line';
      case 'metro': return 'ri-subway-line';
      case 'bus': return 'ri-bus-line';
      default: return 'ri-route-line';
    }
  };

  const renderMainView = () => (
    <div className="space-y-4 px-6">
      <div className="text-center mb-6">
        <h1 className="text-3xl font-bold text-white mb-2 tracking-wide leading-relaxed">YolArkadaşım</h1>
        <p className="text-lg text-gray-300 font-medium tracking-wide">Erişilebilir ulaşım yardımcınız</p>
      </div>

      {/* Main Action Buttons */}
      <div className="space-y-3">
        {/* Search Destination Button */}
        <Button
          size="custom"
          fullWidth
          className="w-full bg-blue-600 hover:bg-blue-700 active:bg-blue-800 text-white py-12 px-6 text-xl font-bold rounded-2xl flex items-center justify-start space-x-4 min-h-[120px] shadow-lg border-2 border-blue-500 transition-all duration-200 focus:ring-4 focus:ring-blue-300"
          onClick={handleSearchDestination}
          aria-label="Hedef bul - Ana arama fonksiyonu"
        >
          <div className="w-10 h-10 flex items-center justify-center">
            <i className="ri-search-line text-3xl" aria-hidden="true"></i>
          </div>
          <span className="text-left">Hedef Bul</span>
        </Button>

        {/* Secondary Action Buttons */}
        <div className="grid grid-cols-1 gap-3">
          {/* Favorite Places Button */}
          <Button
            size="custom"
            fullWidth
            className="w-full bg-green-600 hover:bg-green-700 active:bg-green-800 text-white py-10 px-6 text-lg font-bold rounded-2xl flex items-center justify-start space-x-4 min-h-[100px] shadow-lg border-2 border-green-500 transition-all duration-200 focus:ring-4 focus:ring-green-300"
            onClick={handleFavoritePlaces}
            aria-label="Favori yerler - Kayıtlı konumları görüntüle"
          >
            <div className="w-8 h-8 flex items-center justify-center">
              <i className="ri-heart-fill text-2xl" aria-hidden="true"></i>
            </div>
            <span className="text-left">Favori Yerler</span>
          </Button>

          {/* Nearby Stops Button */}
          <Button
            size="custom"
            fullWidth
            className="w-full bg-purple-600 hover:bg-purple-700 active:bg-purple-800 text-white py-10 px-6 text-lg font-bold rounded-2xl flex items-center justify-start space-x-4 min-h-[100px] shadow-lg border-2 border-purple-500 transition-all duration-200 focus:ring-4 focus:ring-purple-300"
            onClick={handleNearbyStops}
            aria-label="Yakındaki duraklar - Çevredeki toplu taşıma duraklarını bul"
          >
            <div className="w-8 h-8 flex items-center justify-center">
              <i className="ri-map-pin-fill text-2xl" aria-hidden="true"></i>
            </div>
            <span className="text-left">Yakındaki Duraklar</span>
          </Button>
        </div>
      </div>

      {/* Voice Input Button */}
      <div className="mt-4">
        <VoiceButton
          size="custom"
          fullWidth
          className="w-full bg-yellow-600 hover:bg-yellow-700 active:bg-yellow-800 text-white py-10 px-6 text-lg font-bold rounded-2xl flex items-center justify-center space-x-3 min-h-[100px] shadow-lg border-2 border-yellow-500 transition-all duration-200 focus:ring-4 focus:ring-yellow-300"
          onVoiceResult={handleVoiceResult}
          aria-label="Sesli komut - Sesle hedef belirle"
        >
          <div className="w-8 h-8 flex items-center justify-center">
            <i className="ri-mic-fill text-2xl" aria-hidden="true"></i>
          </div>
          <span>Sesli Komut</span>
        </VoiceButton>
      </div>

      {/* Demo Notifications Button */}
      <div className="mt-4">
        <Button
          size="custom"
          fullWidth
          onClick={() => {
            navigate('/notifications');
            speak('Bildirim demo ekranı açılıyor');
          }}
          className="w-full bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white py-8 px-6 text-lg font-bold rounded-2xl flex items-center justify-center space-x-3 min-h-[80px] shadow-lg border-2 border-indigo-500 transition-all duration-200 focus:ring-4 focus:ring-indigo-300"
          aria-label="Bildirim demo - Yolculuk bildirimlerini görüntüle"
        >
          <div className="w-8 h-8 flex items-center justify-center">
            <i className="ri-notification-fill text-2xl" aria-hidden="true"></i>
          </div>
          <span>Bildirim Demo</span>
        </Button>
      </div>
    </div>
  );

  const renderSearchView = () => (
    <div className="space-y-6 px-6">
      <div className="text-center mb-6">
        <h2 className="text-2xl font-bold text-white mb-4 tracking-wide leading-relaxed">Nereye gitmek istiyorsunuz?</h2>
      </div>

      <div className="space-y-4">
        <div className="relative">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Hedef girin..."
            className="w-full bg-gray-800 text-white text-lg p-6 rounded-2xl border-2 border-gray-600 focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-300 min-h-[60px] font-medium"
            aria-label="Hedef girin - Gitmek istediğiniz yeri yazın"
          />
        </div>

        <Button
          size="custom"
          onClick={handleSearchSubmit}
          className="w-full bg-blue-600 hover:bg-blue-700 active:bg-blue-800 text-white py-8 px-6 text-lg font-bold rounded-2xl min-h-[80px] shadow-lg border-2 border-blue-500 transition-all duration-200 focus:ring-4 focus:ring-blue-300"
          aria-label="Rota ara - Girilen hedef için rotaları bul"
        >
          <div className="flex items-center justify-center space-x-3">
            <div className="w-8 h-8 flex items-center justify-center">
              <i className="ri-search-line text-2xl"></i>
            </div>
            <span>Rota Ara</span>
          </div>
        </Button>

        <VoiceButton
          onVoiceResult={handleVoiceSearch}
          className="w-full bg-yellow-500 hover:bg-yellow-600 active:bg-yellow-700 text-black py-8 px-6 text-lg font-bold rounded-2xl flex items-center justify-center space-x-3 min-h-[80px] shadow-lg border-2 border-yellow-400 transition-all duration-200 focus:ring-4 focus:ring-yellow-300"
          aria-label="Sesli arama - Hedefınızı sesle söyleyin"
        >
          <div className="w-8 h-8 flex items-center justify-center">
            <i className="ri-mic-line text-2xl"></i>
          </div>
          <span>Sesli Arama</span>
        </VoiceButton>

        <Button
          size="custom"
          onClick={() => handleButtonPress('back')}
          className="w-full bg-gray-700 hover:bg-gray-600 active:bg-gray-800 text-white py-6 px-6 text-lg font-semibold rounded-2xl min-h-[60px] shadow-lg border-2 border-gray-600 transition-all duration-200 focus:ring-4 focus:ring-gray-400"
          aria-label="Ana menüye dön"
        >
          Ana Menüye Dön
        </Button>
      </div>
    </div>
  );

  const renderRoutesView = () => (
    <div className="space-y-6 px-6">
      <div className="text-center mb-6">
        <h2 className="text-2xl font-bold text-white mb-2 tracking-wide leading-relaxed">
          {searchQuery} için Rotalar
        </h2>
        <p className="text-lg text-gray-300">{searchResults.length} rota bulundu</p>
      </div>

      <div className="space-y-4">
        {searchResults.map((route) => (
          <Button
            key={route.id}
            size="custom"
            onClick={() => handleRouteSelect(route)}
            className="w-full bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white py-6 px-6 text-left rounded-2xl min-h-[120px] shadow-lg border-2 border-indigo-500 transition-all duration-200 focus:ring-4 focus:ring-indigo-300"
            aria-label={`${route.routeName} rotası - ${route.duration} sürecek, ${route.transfers} aktarma`}
          >
            <div className="flex items-start space-x-4">
              <div className="w-10 h-10 flex items-center justify-center flex-shrink-0">
                <i className={`${getRouteIcon(route.routeName)} text-2xl text-indigo-200`}></i>
              </div>
              <div className="flex-1">
                <div className="flex items-center space-x-3 mb-2">
                  <span className="text-xl font-bold">{route.routeName}</span>
                  {route.accessibility && (
                    <span className="bg-green-700 text-white px-2 py-1 rounded-full text-xs font-bold">
                      Erişilebilir
                    </span>
                  )}
                </div>
                <div className="text-indigo-100 space-y-1">
                  <div className="flex items-center space-x-4">
                    <span className="font-semibold">{route.duration}</span>
                    <span>{route.transfers} aktarma</span>
                  </div>
                  <div className="text-sm">
                    {route.steps.slice(0, 2).map((step, index) => (
                      <div key={index} className="flex items-center space-x-2">
                        <i className={`${getStepIcon(step.type)} text-sm`}></i>
                        <span>{step.description}</span>
                      </div>
                    ))}
                    {route.steps.length > 2 && (
                      <span className="text-indigo-200">+{route.steps.length - 2} adım daha</span>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </Button>
        ))}

        <Button
          size="custom"
          onClick={() => handleButtonPress('back')}
          className="w-full bg-gray-700 hover:bg-gray-600 active:bg-gray-800 text-white py-6 px-6 text-lg font-semibold rounded-2xl min-h-[60px] shadow-lg border-2 border-gray-600 transition-all duration-200 focus:ring-4 focus:ring-gray-400"
          aria-label="Ana menüye dön"
        >
          Ana Menüye Dön
        </Button>
      </div>
    </div>
  );

  const renderFavoritesView = () => (
    <div className="space-y-8 px-6">
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold text-white mb-4 tracking-wide leading-relaxed">Favorileriniz</h2>
      </div>

      <div className="space-y-6">
        {mockFavorites.map((favorite) => (
          <Button
            key={favorite.id}
            onClick={() => handleDestinationSelect(favorite.name)}
            className="w-full bg-orange-600 hover:bg-orange-700 active:bg-orange-800 text-white py-20 px-8 text-xl font-semibold rounded-2xl text-left min-h-[200px] shadow-lg border-2 border-orange-500 transition-all duration-200 focus:ring-4 focus:ring-orange-300"
            aria-label={`${favorite.name} hedef olarak seç - ${favorite.address}`}
          >
            <div className="flex items-center space-x-4">
              <div className="w-12 h-12 flex items-center justify-center">
                <i className="ri-star-fill text-4xl text-orange-200"></i>
              </div>
              <div>
                <div className="text-2xl font-bold">{favorite.name}</div>
                <div className="text-lg text-orange-100 font-medium">{favorite.address}</div>
              </div>
            </div>
          </Button>
        ))}

        <Button
          onClick={() => handleButtonPress('back')}
          className="w-full bg-gray-700 hover:bg-gray-600 active:bg-gray-800 text-white py-16 px-8 text-xl font-semibold rounded-2xl min-h-[160px] shadow-lg border-2 border-gray-600 transition-all duration-200 focus:ring-4 focus:ring-gray-400"
          aria-label="Ana menüye dön"
        >
          Ana Menüye Dön
        </Button>
      </div>
    </div>
  );

  const renderNearbyView = () => (
    <div className="space-y-8 px-6">
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold text-white mb-4 tracking-wide leading-relaxed">Yakındaki Duraklar</h2>
      </div>

      <div className="space-y-6">
        {mockNearbyStops.map((stop) => (
          <Button
            key={stop.id}
            onClick={() => handleDestinationSelect(stop.name)}
            className="w-full bg-teal-600 hover:bg-teal-700 active:bg-teal-800 text-white py-20 px-8 text-xl font-semibold rounded-2xl text-left min-h-[200px] shadow-lg border-2 border-teal-500 transition-all duration-200 focus:ring-4 focus:ring-teal-300"
            aria-label={`${stop.name} hedef olarak seç - ${stop.distance}`}
          >
            <div className="flex items-center space-x-4">
              <div className="w-12 h-12 flex items-center justify-center">
                <i className="ri-map-pin-fill text-4xl text-teal-200"></i>
              </div>
              <div className="flex-1">
                <div className="text-2xl font-bold flex items-center space-x-3">
                  <span>{stop.name}</span>
                  {stop.accessible && (
                    <span className="bg-green-700 text-white px-3 py-1 rounded-full text-sm font-bold border border-green-500">
                      Erişilebilir
                    </span>
                  )}
                  {stop.audio && (
                    <span className="bg-blue-700 text-white px-3 py-1 rounded-full text-sm font-bold border border-blue-500">
                      Ses
                    </span>
                  )}
                </div>
                <div className="text-lg text-teal-100 font-medium">{stop.distance}</div>
              </div>
            </div>
          </Button>
        ))}

        <Button
          onClick={() => handleButtonPress('back')}
          className="w-full bg-gray-700 hover:bg-gray-600 active:bg-gray-800 text-white py-16 px-8 text-xl font-semibold rounded-2xl min-h-[160px] shadow-lg border-2 border-gray-600 transition-all duration-200 focus:ring-4 focus:ring-gray-400"
          aria-label="Ana menüye dön"
        >
          Ana Menüye Dön
        </Button>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-slate-900" style={{ backgroundColor: '#0A0F1A' }}>
      <NavigationHeader />
      
      <main className="pt-24 pb-8">
        <div className="max-w-md mx-auto">
          {currentView === 'main' && renderMainView()}
          {currentView === 'search' && renderSearchView()}
          {currentView === 'routes' && renderRoutesView()}
          {currentView === 'favorites' && renderFavoritesView()}
          {currentView === 'nearby' && renderNearbyView()}
        </div>
      </main>
    </div>
  );
}
