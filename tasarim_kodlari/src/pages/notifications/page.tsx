
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Button from '../../components/base/Button';
import { useVoiceAnnouncement } from '../../hooks/useVoiceAnnouncement';
import { useVibration } from '../../hooks/useVibration';

interface NotificationData {
  type: 'stop_arrival' | 'bus_arrival' | 'route_alert';
  title: string;
  message: string;
  stopName?: string;
  busNumber?: string;
  estimatedTime?: string;
  platform?: string;
}

export default function NotificationsPage() {
  const navigate = useNavigate();
  const [currentNotification, setCurrentNotification] = useState<NotificationData | null>(null);
  const [isVisible, setIsVisible] = useState(false);

  // Voice and vibration settings
  const [settings] = useState({
    voiceEnabled: true,
    voiceSpeed: 1,
    vibrationEnabled: true
  });

  const { speak, announceArrival, announceNavigation } = useVoiceAnnouncement(settings);
  const { vibrateArrival, vibrateAlert, vibratePattern } = useVibration(settings);

  // Mock notifications for demonstration
  const mockNotifications: NotificationData[] = [
    {
      type: 'stop_arrival',
      title: 'Durağa Varıyorsunuz',
      message: 'Taksim Meydanı durağına 2 dakika kaldı',
      stopName: 'Taksim Meydanı',
      estimatedTime: '2 dakika'
    },
    {
      type: 'bus_arrival',
      title: 'Otobüs Geliyor',
      message: '42T otobüsü 3 dakika sonra gelecek',
      busNumber: '42T',
      estimatedTime: '3 dakika',
      platform: '2. Peron'
    },
    {
      type: 'route_alert',
      title: 'Rota Uyarısı',
      message: 'M2 Metro hattında gecikme var. Alternatif rota öneriliyor.',
      estimatedTime: '10 dakika gecikme'
    }
  ];

  useEffect(() => {
    // Simulate receiving notifications
    const showNotification = (notification: NotificationData) => {
      setCurrentNotification(notification);
      setIsVisible(true);

      // Voice announcement and vibration based on notification type
      switch (notification.type) {
        case 'stop_arrival':
          announceArrival(notification.stopName || 'durak');
          vibrateArrival();
          break;
        case 'bus_arrival':
          speak(`${notification.busNumber} otobüsü ${notification.estimatedTime} sonra gelecek`, 'high');
          vibrateAlert();
          break;
        case 'route_alert':
          speak(notification.message, 'high');
          vibratePattern([300, 100, 300, 100, 300]);
          break;
      }
    };

    // Demo: Show different notifications every 5 seconds
    let notificationIndex = 0;
    const interval = setInterval(() => {
      if (notificationIndex < mockNotifications.length) {
        showNotification(mockNotifications[notificationIndex]);
        notificationIndex++;
      } else {
        clearInterval(interval);
      }
    }, 5000);

    // Show first notification immediately
    showNotification(mockNotifications[0]);

    return () => clearInterval(interval);
  }, [announceArrival, speak, vibrateArrival, vibrateAlert, vibratePattern]);

  const handleDismiss = () => {
    setIsVisible(false);
    speak('Bildirim kapatıldı');
    setTimeout(() => {
      setCurrentNotification(null);
    }, 300);
  };

  const handleGoHome = () => {
    navigate('/');
    announceNavigation('Ana menüye dönülüyor');
  };

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'stop_arrival':
        return 'ri-map-pin-fill';
      case 'bus_arrival':
        return 'ri-bus-fill';
      case 'route_alert':
        return 'ri-alert-fill';
      default:
        return 'ri-notification-fill';
    }
  };

  const getNotificationColor = (type: string) => {
    switch (type) {
      case 'stop_arrival':
        return 'bg-green-600 border-green-500';
      case 'bus_arrival':
        return 'bg-blue-600 border-blue-500';
      case 'route_alert':
        return 'bg-orange-600 border-orange-500';
      default:
        return 'bg-gray-600 border-gray-500';
    }
  };

  if (!currentNotification) {
    return (
      <div className="min-h-screen bg-slate-900 flex items-center justify-center" style={{ backgroundColor: '#0A0F1A' }}>
        <div className="text-center px-6">
          <h1 className="text-3xl font-bold text-white mb-4">Bildirim Bekleniyor</h1>
          <p className="text-xl text-gray-300 mb-8">Yolculuk sırasında bildirimler burada görünecek</p>
          <Button
            onClick={handleGoHome}
            className="bg-blue-600 hover:bg-blue-700 text-white py-4 px-8 text-lg font-semibold rounded-2xl"
          >
            Ana Menüye Dön
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-900 flex items-center justify-center p-6" style={{ backgroundColor: '#0A0F1A' }}>
      <div 
        className={`w-full max-w-md transform transition-all duration-300 ${
          isVisible ? 'scale-100 opacity-100' : 'scale-95 opacity-0'
        }`}
      >
        {/* Notification Card */}
        <div 
          className={`${getNotificationColor(currentNotification.type)} text-white rounded-3xl p-8 shadow-2xl border-4 mb-6`}
          role="alert"
          aria-live="assertive"
        >
          {/* Icon and Title */}
          <div className="flex items-center space-x-4 mb-6">
            <div className="w-16 h-16 flex items-center justify-center bg-white/20 rounded-full">
              <i className={`${getNotificationIcon(currentNotification.type)} text-3xl`} aria-hidden="true"></i>
            </div>
            <div className="flex-1">
              <h1 className="text-2xl font-bold mb-1">{currentNotification.title}</h1>
              {currentNotification.estimatedTime && (
                <p className="text-lg opacity-90">{currentNotification.estimatedTime}</p>
              )}
            </div>
          </div>

          {/* Message */}
          <div className="mb-8">
            <p className="text-xl font-medium leading-relaxed">{currentNotification.message}</p>
          </div>

          {/* Additional Info */}
          {(currentNotification.stopName || currentNotification.busNumber || currentNotification.platform) && (
            <div className="bg-white/10 rounded-2xl p-6 mb-8">
              {currentNotification.stopName && (
                <div className="flex items-center space-x-3 mb-3">
                  <i className="ri-map-pin-line text-xl"></i>
                  <span className="text-lg font-medium">Durak: {currentNotification.stopName}</span>
                </div>
              )}
              {currentNotification.busNumber && (
                <div className="flex items-center space-x-3 mb-3">
                  <i className="ri-bus-line text-xl"></i>
                  <span className="text-lg font-medium">Hat: {currentNotification.busNumber}</span>
                </div>
              )}
              {currentNotification.platform && (
                <div className="flex items-center space-x-3">
                  <i className="ri-road-map-line text-xl"></i>
                  <span className="text-lg font-medium">{currentNotification.platform}</span>
                </div>
              )}
            </div>
          )}

          {/* Action Buttons */}
          <div className="space-y-4">
            <Button
              onClick={handleDismiss}
              className="w-full bg-white/20 hover:bg-white/30 active:bg-white/40 text-white py-6 px-6 text-lg font-bold rounded-2xl border-2 border-white/30 transition-all duration-200 focus:ring-4 focus:ring-white/50"
              aria-label="Bildirimi kapat"
            >
              <div className="flex items-center justify-center space-x-3">
                <i className="ri-check-line text-2xl"></i>
                <span>Anladım</span>
              </div>
            </Button>

            {currentNotification.type === 'route_alert' && (
              <Button
                onClick={() => {
                  speak('Alternatif rota aranıyor');
                  // Here you would navigate to route alternatives
                }}
                className="w-full bg-white text-gray-900 hover:bg-gray-100 active:bg-gray-200 py-6 px-6 text-lg font-bold rounded-2xl transition-all duration-200 focus:ring-4 focus:ring-white/50"
                aria-label="Alternatif rota bul"
              >
                <div className="flex items-center justify-center space-x-3">
                  <i className="ri-route-line text-2xl"></i>
                  <span>Alternatif Rota</span>
                </div>
              </Button>
            )}
          </div>
        </div>

        {/* Bottom Navigation */}
        <div className="text-center">
          <Button
            onClick={handleGoHome}
            className="bg-gray-700 hover:bg-gray-600 active:bg-gray-800 text-white py-4 px-8 text-lg font-semibold rounded-2xl border-2 border-gray-600 transition-all duration-200 focus:ring-4 focus:ring-gray-400"
            aria-label="Ana menüye dön"
          >
            Ana Menü
          </Button>
        </div>
      </div>
    </div>
  );
}
