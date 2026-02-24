
import { useState, useRef, useEffect } from 'react';
import Button from './Button';

interface VoiceButtonProps {
  onVoiceResult: (text: string) => void;
  className?: string;
  children?: React.ReactNode;
  'aria-label'?: string;
}

export default function VoiceButton({ 
  onVoiceResult, 
  className = '', 
  children,
  'aria-label': ariaLabel = 'Sesli komut ver'
}: VoiceButtonProps) {
  const [isListening, setIsListening] = useState(false);
  const [isSupported, setIsSupported] = useState(false);
  const recognitionRef = useRef<any>(null);

  useEffect(() => {
    // Check if speech recognition is supported
    const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    if (SpeechRecognition) {
      setIsSupported(true);
      recognitionRef.current = new SpeechRecognition();
      recognitionRef.current.continuous = false;
      recognitionRef.current.interimResults = false;
      recognitionRef.current.lang = 'tr-TR';

      recognitionRef.current.onresult = (event: any) => {
        const transcript = event.results[0][0].transcript;
        onVoiceResult(transcript);
        setIsListening(false);
      };

      recognitionRef.current.onerror = () => {
        setIsListening(false);
      };

      recognitionRef.current.onend = () => {
        setIsListening(false);
      };
    }

    return () => {
      if (recognitionRef.current) {
        recognitionRef.current.stop();
      }
    };
  }, [onVoiceResult]);

  const handleVoiceInput = () => {
    if (!isSupported || !recognitionRef.current) {
      alert('Sesli komut bu tarayıcıda desteklenmiyor');
      return;
    }

    if (isListening) {
      recognitionRef.current.stop();
      setIsListening(false);
    } else {
      recognitionRef.current.start();
      setIsListening(true);
    }
  };

  if (!isSupported) {
    return (
      <Button
        disabled
        className={`opacity-50 cursor-not-allowed ${className}`}
        aria-label="Sesli komut desteklenmiyor"
      >
        {children || (
          <>
            <div className="w-8 h-8 flex items-center justify-center">
              <i className="ri-mic-off-line text-2xl"></i>
            </div>
            <span>Sesli Komut Desteklenmiyor</span>
          </>
        )}
      </Button>
    );
  }

  return (
    <Button
      onClick={handleVoiceInput}
      className={className}
      aria-label={isListening ? 'Dinleniyor - Tekrar basarak durdurun' : ariaLabel}
      aria-pressed={isListening}
    >
      {children || (
        <>
          <div className="w-8 h-8 flex items-center justify-center">
            <i className={`${isListening ? 'ri-mic-fill animate-pulse' : 'ri-mic-line'} text-2xl`}></i>
          </div>
          <span>{isListening ? 'Dinleniyor...' : 'Sesli Komut'}</span>
        </>
      )}
    </Button>
  );
}
