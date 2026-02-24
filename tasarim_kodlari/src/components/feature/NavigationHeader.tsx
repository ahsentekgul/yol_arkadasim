
import { useState } from 'react';
import Button from '../base/Button';
import AccessibilitySettings from './AccessibilitySettings';
import { useVoiceAnnouncement } from '../../hooks/useVoiceAnnouncement';
import { useVibration } from '../../hooks/useVibration';

export default function NavigationHeader() {
  const [showSettings, setShowSettings] = useState(false);
  
  // Settings for voice and vibration
  const [settings] = useState({
    voiceEnabled: true,
    voiceSpeed: 1,
    vibrationEnabled: true
  });
  
  const { speak } = useVoiceAnnouncement(settings);
  const { vibrate } = useVibration(settings);

  const handleSettingsToggle = () => {
    setShowSettings(!showSettings);
    vibrate('short');
    if (!showSettings) {
      speak('Erişilebilirlik ayarları açılıyor');
    } else {
      speak('Ayarlar kapatılıyor');
    }
  };

  return (
    <>
      <header className="fixed top-0 left-0 right-0 z-50" style={{ backgroundColor: '#0A0F1A' }}>
        <div className="border-b border-gray-700">
          <div className="flex items-center justify-between p-6">
            <div className="flex items-center space-x-4">
              <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center shadow-lg border border-blue-500">
                <i className="ri-navigation-line text-white text-xl"></i>
              </div>
              <h1 className="text-xl font-bold text-white tracking-wide">YolArkadaşım</h1>
            </div>
            
            <Button
              onClick={handleSettingsToggle}
              className="p-4 bg-gray-700 hover:bg-gray-600 active:bg-gray-800 rounded-xl shadow-lg border border-gray-600 transition-all duration-200 focus:ring-4 focus:ring-gray-400 min-w-[48px] min-h-[48px]"
              aria-label="Erişilebilirlik ayarları - Ses ve titreşim ayarlarını değiştirin"
            >
              <i className="ri-settings-3-line text-white text-xl"></i>
            </Button>
          </div>
        </div>
      </header>

      {showSettings && (
        <AccessibilitySettings 
          isOpen={showSettings}
          onClose={() => setShowSettings(false)}
        />
      )}
    </>
  );
}
