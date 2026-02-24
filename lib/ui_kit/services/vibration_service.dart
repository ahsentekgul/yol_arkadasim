import 'package:flutter/material.dart';

/// UI-only vibration placeholder.
/// Real navigator.vibrate or Haptics integration is NOT implemented here.
class VibrationService {
  final bool vibrationEnabled;

  VibrationService({this.vibrationEnabled = true});

  void vibrate(dynamic pattern) {
    if (!vibrationEnabled) return;
    // TODO: Gerçek titreşim API'ı burada çağrılacak (UI-only: demo log)
    debugPrint('Vibrate (demo): $pattern');
  }

  void vibrateShort() {
    vibrate(100);
  }

  void vibrateLong() {
    vibrate(500);
  }

  void vibratePattern(List<int> pattern) {
    vibrate(pattern);
  }

  void vibrateArrival() {
    vibrate([200, 100, 200, 100, 200]);
  }

  void vibrateAlert() {
    vibrate([500, 200, 500]);
  }
}

