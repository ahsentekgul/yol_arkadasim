import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Physical vibration via the [vibration] package.
class VibrationService {
  final bool vibrationEnabled;

  VibrationService({this.vibrationEnabled = true});

  static const int _shortDurationMs = 120;
  static const int _longDurationMs = 400;
  static const int _shortAmplitude = 128;
  static const int _longAmplitude = 220;

  static const List<int> _alertPattern = [0, 150, 100, 250];
  static const List<int> _alertIntensities = [0, 200, 0, 255];
  static const List<int> _arrivalPattern = [0, 250, 120, 250, 120, 400];
  static const List<int> _arrivalIntensities = [0, 255, 0, 255, 0, 255];

  Future<void> _safeVibrate(Future<void> Function() action) async {
    if (!vibrationEnabled) {
      return;
    }
    try {
      if (!await Vibration.hasVibrator()) {
        return;
      }
      await action();
    } catch (error) {
      debugPrint('Vibration failed: $error');
    }
  }

  Future<bool> _hasAmplitudeControl() async {
    return Vibration.hasAmplitudeControl();
  }

  Future<void> _vibrateDuration(int duration, {int? amplitude}) async {
    if (await _hasAmplitudeControl() && amplitude != null) {
      await Vibration.vibrate(duration: duration, amplitude: amplitude);
      return;
    }
    await Vibration.vibrate(duration: duration);
  }

  Future<void> _vibrateWithPattern(
    List<int> pattern, {
    List<int>? intensities,
  }) async {
    if (intensities != null && await _hasAmplitudeControl()) {
      await Vibration.vibrate(pattern: pattern, intensities: intensities);
      return;
    }
    await Vibration.vibrate(pattern: pattern);
  }

  Future<void> vibrateShort() async {
    debugPrint('Vibration: vibrateShort');
    await _safeVibrate(
      () => _vibrateDuration(_shortDurationMs, amplitude: _shortAmplitude),
    );
  }

  Future<void> vibrateLong() async {
    debugPrint('Vibration: vibrateLong');
    await _safeVibrate(
      () => _vibrateDuration(_longDurationMs, amplitude: _longAmplitude),
    );
  }

  Future<void> vibratePattern(List<int> pattern) async {
    debugPrint('Vibration: vibratePattern');
    await _safeVibrate(() async {
      if (pattern.isEmpty) {
        await _vibrateDuration(_shortDurationMs, amplitude: _shortAmplitude);
        return;
      }
      final safePattern = pattern.length > 12 ? pattern.sublist(0, 12) : pattern;
      await Vibration.vibrate(pattern: safePattern);
    });
  }

  Future<void> vibrateArrival() async {
    debugPrint('Vibration: vibrateArrival');
    await _safeVibrate(
      () => _vibrateWithPattern(
        _arrivalPattern,
        intensities: _arrivalIntensities,
      ),
    );
  }

  Future<void> vibrateAlert() async {
    debugPrint('Vibration: vibrateAlert');
    await _safeVibrate(
      () => _vibrateWithPattern(
        _alertPattern,
        intensities: _alertIntensities,
      ),
    );
  }
}
