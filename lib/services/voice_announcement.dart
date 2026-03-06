import 'package:flutter/material.dart';

/// UI-only TTS placeholder service.
/// Real speechSynthesis / platform integration is intentionally NOT implemented.
class VoiceAnnouncement {
  final bool voiceEnabled;
  final double voiceSpeed;

  VoiceAnnouncement({this.voiceEnabled = true, this.voiceSpeed = 1.0});

  void speak(String text, {String priority = 'medium'}) {
    if (!voiceEnabled) return;
    // TODO: Entegre edilecek TTS çağrısı burada olacak (UI-only: demo log)
    debugPrint('TTS (demo) [$priority]: $text (rate: $voiceSpeed)');
  }

  void stopSpeaking() {
    // TODO: Gerçek TTS iptali burada yapılacak
    debugPrint('TTS durduruldu (demo)');
  }

  void announceNavigation(String message) {
    speak(message, priority: 'high');
  }

  void announceArrival(String stopName) {
    speak('$stopName durağına varıyoruz', priority: 'high');
  }

  void announceDirection(String direction) {
    speak('$direction yönüne gidin', priority: 'medium');
  }
}
