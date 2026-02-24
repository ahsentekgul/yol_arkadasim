
import { useState, useEffect } from 'react';
import Button from '../base/Button';
import { useVoiceAnnouncement } from '../../hooks/useVoiceAnnouncement';
import { useVibration } from '../../hooks/useVibration';

interface AccessibilitySettingsProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function AccessibilitySettings({ isOpen, onClose }: AccessibilitySettingsProps) {
  const [settings, setSettings] = useState({
    voiceSpeed: 1,
    voiceEnabled: true,
    vibrationEnabled: true,
    autoAnnouncements: true,
    textSize: 'large'
  });

  const { speak } = useVoiceAnnouncement({
    voiceEnabled: settings.voiceEnabled,
    voiceSpeed: settings.voiceSpeed
  });
  const { vibrateShort } = useVibration({
    vibrationEnabled: settings.vibrationEnabled
  });

  useEffect(() => {
    // Load settings from localStorage
    const savedSettings = localStorage.getItem('accessibilitySettings');
    if (savedSettings) {
      const parsed = JSON.parse(savedSettings);
      setSettings(parsed);
    }
  }, []);

  const updateSetting = (key: string, value: any) => {
    const newSettings = { ...settings, [key]: value };
    setSettings(newSettings);
    localStorage.setItem('accessibilitySettings', JSON.stringify(newSettings));
    
    vibrateShort();
  };

  const testVoice = () => {
    speak('Bu ses hızı testi. Ayarlarınız kaydedildi.');
    vibrateShort();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4">
      <div className="bg-gray-800 rounded-2xl p-6 w-full max-w-md max-h-[80vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-white">Erişilebilirlik Ayarları</h2>
          <Button
            onClick={onClose}
            className="p-2 bg-gray-700 hover:bg-gray-600 rounded-lg"
            aria-label="Ayarları kapat"
          >
            <i className="ri-close-line text-white text-xl"></i>
          </Button>
        </div>

        <div className="space-y-6">
          {/* Voice Speed */}
          <div>
            <label className="block text-white text-lg font-semibold mb-3">
              Ses Hızı
            </label>
            <div className="space-y-3">
              <input
                type="range"
                min="0.5"
                max="2"
                step="0.1"
                value={settings.voiceSpeed}
                onChange={(e) => updateSetting('voiceSpeed', parseFloat(e.target.value))}
                className="w-full h-3 bg-gray-600 rounded-lg appearance-none cursor-pointer"
                aria-label="Ses hızı ayarı"
              />
              <div className="flex justify-between text-sm text-gray-300">
                <span>Yavaş</span>
                <span>Normal</span>
                <span>Hızlı</span>
              </div>
              <Button
                onClick={testVoice}
                className="w-full bg-blue-500 hover:bg-blue-600 text-white py-3 rounded-lg"
                aria-label="Ses hızını test et"
              >
                Ses Hızını Test Et
              </Button>
            </div>
          </div>

          {/* Vibration */}
          <div>
            <label className="block text-white text-lg font-semibold mb-3">
              Titreşim
            </label>
            <Button
              onClick={() => updateSetting('vibrationEnabled', !settings.vibrationEnabled)}
              className={`w-full py-4 rounded-lg font-semibold ${
                settings.vibrationEnabled
                  ? 'bg-green-500 hover:bg-green-600 text-white'
                  : 'bg-gray-600 hover:bg-gray-500 text-gray-300'
              }`}
              aria-label={`Titreşim ${settings.vibrationEnabled ? 'açık' : 'kapalı'}`}
            >
              {settings.vibrationEnabled ? 'Titreşim Açık' : 'Titreşim Kapalı'}
            </Button>
          </div>

          {/* Auto Announcements */}
          <div>
            <label className="block text-white text-lg font-semibold mb-3">
              Otomatik Duyurular
            </label>
            <Button
              onClick={() => updateSetting('autoAnnouncements', !settings.autoAnnouncements)}
              className={`w-full py-4 rounded-lg font-semibold ${
                settings.autoAnnouncements
                  ? 'bg-green-500 hover:bg-green-600 text-white'
                  : 'bg-gray-600 hover:bg-gray-500 text-gray-300'
              }`}
              aria-label={`Otomatik duyurular ${settings.autoAnnouncements ? 'açık' : 'kapalı'}`}
            >
              {settings.autoAnnouncements ? 'Duyurular Açık' : 'Duyurular Kapalı'}
            </Button>
          </div>

          {/* Text Size */}
          <div>
            <label className="block text-white text-lg font-semibold mb-3">
              Metin Boyutu
            </label>
            <div className="space-y-2">
              {['medium', 'large', 'extra-large'].map((size) => (
                <Button
                  key={size}
                  onClick={() => updateSetting('textSize', size)}
                  className={`w-full py-3 rounded-lg font-semibold ${
                    settings.textSize === size
                      ? 'bg-blue-500 hover:bg-blue-600 text-white'
                      : 'bg-gray-600 hover:bg-gray-500 text-gray-300'
                  }`}
                  aria-label={`Metin boyutu ${size === 'medium' ? 'orta' : size === 'large' ? 'büyük' : 'çok büyük'}`}
                >
                  {size === 'medium' ? 'Orta' : size === 'large' ? 'Büyük' : 'Çok Büyük'}
                </Button>
              ))}
            </div>
          </div>
        </div>

        <div className="mt-8">
          <Button
            onClick={onClose}
            className="w-full bg-gray-600 hover:bg-gray-700 text-white py-4 text-lg font-bold rounded-lg"
            aria-label="Ayarları kaydet ve kapat"
          >
            Ayarları Kaydet
          </Button>
        </div>
      </div>
    </div>
  );
}
