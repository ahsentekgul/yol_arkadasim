
import { useCallback, useRef } from 'react';

interface VoiceSettings {
  voiceEnabled: boolean;
  voiceSpeed: number;
}

export function useVoiceAnnouncement(settings: VoiceSettings) {
  const utteranceRef = useRef<SpeechSynthesisUtterance | null>(null);

  const speak = useCallback((text: string, priority: 'low' | 'medium' | 'high' = 'medium') => {
    if (!settings.voiceEnabled || !('speechSynthesis' in window)) {
      return;
    }

    // Cancel previous announcement if high priority
    if (priority === 'high' && utteranceRef.current) {
      speechSynthesis.cancel();
    }

    const utterance = new SpeechSynthesisUtterance(text);
    utterance.rate = settings.voiceSpeed;
    utterance.volume = 1;
    utterance.pitch = 1;

    // Set voice to Turkish if available
    const voices = speechSynthesis.getVoices();
    const preferredVoice = voices.find(voice => 
      voice.lang.startsWith('tr') || 
      (voice.lang.startsWith('en') && 
      (voice.name.includes('Google') || voice.name.includes('Microsoft')))
    );
    if (preferredVoice) {
      utterance.voice = preferredVoice;
    }

    utteranceRef.current = utterance;
    speechSynthesis.speak(utterance);
  }, [settings.voiceEnabled, settings.voiceSpeed]);

  const stopSpeaking = useCallback(() => {
    if ('speechSynthesis' in window) {
      speechSynthesis.cancel();
    }
  }, []);

  const announceNavigation = useCallback((message: string) => {
    speak(message, 'high');
  }, [speak]);

  const announceArrival = useCallback((stopName: string) => {
    speak(`${stopName} durağına varıyoruz`, 'high');
  }, [speak]);

  const announceDirection = useCallback((direction: string) => {
    speak(`${direction} yönüne gidin`, 'medium');
  }, [speak]);

  return {
    speak,
    stopSpeaking,
    announceNavigation,
    announceArrival,
    announceDirection
  };
}
