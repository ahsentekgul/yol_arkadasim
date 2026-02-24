
import { useCallback } from 'react';

interface VibrationSettings {
  vibrationEnabled: boolean;
}

export function useVibration(settings: VibrationSettings) {
  const vibrate = useCallback((pattern: number | number[]) => {
    if (!settings.vibrationEnabled || !('vibrate' in navigator)) {
      return;
    }
    
    navigator.vibrate(pattern);
  }, [settings.vibrationEnabled]);

  const vibrateShort = useCallback(() => {
    vibrate(100);
  }, [vibrate]);

  const vibrateLong = useCallback(() => {
    vibrate(500);
  }, [vibrate]);

  const vibratePattern = useCallback((pattern: number[]) => {
    vibrate(pattern);
  }, [vibrate]);

  const vibrateArrival = useCallback(() => {
    // Three short pulses for arrival
    vibrate([200, 100, 200, 100, 200]);
  }, [vibrate]);

  const vibrateAlert = useCallback(() => {
    // Two long pulses for important alerts
    vibrate([500, 200, 500]);
  }, [vibrate]);

  return {
    vibrate,
    vibrateShort,
    vibrateLong,
    vibratePattern,
    vibrateArrival,
    vibrateAlert
  };
}
