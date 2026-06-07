import 'package:shared_preferences/shared_preferences.dart';

class AccessibilitySettingsService {
  static const String keyHapticFeedbackEnabled = 'haptic_feedback_enabled';
  static const String keyTextSizePreference = 'text_size_preference';

  static const String textSizeMedium = 'medium';
  static const String textSizeLarge = 'large';
  static const String textSizeExtraLarge = 'extraLarge';

  static const bool defaultHapticFeedbackEnabled = true;
  static const String defaultTextSizePreference = textSizeLarge;

  static const List<String> validTextSizePreferences = [
    textSizeMedium,
    textSizeLarge,
    textSizeExtraLarge,
  ];

  Future<bool> getHapticFeedbackEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyHapticFeedbackEnabled) ??
        defaultHapticFeedbackEnabled;
  }

  Future<String> getTextSizePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(keyTextSizePreference);

    if (savedValue == null ||
        !validTextSizePreferences.contains(savedValue)) {
      return defaultTextSizePreference;
    }

    return savedValue;
  }

  Future<void> saveSettings({
    required bool hapticFeedbackEnabled,
    required String textSizePreference,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyHapticFeedbackEnabled, hapticFeedbackEnabled);
    await prefs.setString(keyTextSizePreference, textSizePreference);
  }
}
