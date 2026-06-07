import 'package:flutter/material.dart';
import 'package:yol_arkadasim/core/accessibility/accessibility_settings_service.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  final AccessibilitySettingsService _settingsService =
      AccessibilitySettingsService();

  bool _hapticFeedbackEnabled =
      AccessibilitySettingsService.defaultHapticFeedbackEnabled;
  String _textSizePreference =
      AccessibilitySettingsService.defaultTextSizePreference;
  bool _isLoading = true;
  bool _isSaving = false;

  static const List<_TextSizeOption> _textSizeOptions = [
    _TextSizeOption(
      value: AccessibilitySettingsService.textSizeMedium,
      label: 'Orta',
    ),
    _TextSizeOption(
      value: AccessibilitySettingsService.textSizeLarge,
      label: 'Büyük',
    ),
    _TextSizeOption(
      value: AccessibilitySettingsService.textSizeExtraLarge,
      label: 'Çok Büyük',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hapticEnabled = await _settingsService.getHapticFeedbackEnabled();
    final textSize = await _settingsService.getTextSizePreference();

    if (!mounted) {
      return;
    }

    setState(() {
      _hapticFeedbackEnabled = hapticEnabled;
      _textSizePreference = textSize;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    await _settingsService.saveSettings(
      hapticFeedbackEnabled: _hapticFeedbackEnabled,
      textSizePreference: _textSizePreference,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ayarlar kaydedildi.')),
    );
  }

  double _previewPrimaryFontSize() {
    switch (_textSizePreference) {
      case AccessibilitySettingsService.textSizeMedium:
        return 18;
      case AccessibilitySettingsService.textSizeExtraLarge:
        return 26;
      case AccessibilitySettingsService.textSizeLarge:
      default:
        return 22;
    }
  }

  double _previewSecondaryFontSize() {
    switch (_textSizePreference) {
      case AccessibilitySettingsService.textSizeMedium:
        return 16;
      case AccessibilitySettingsService.textSizeExtraLarge:
        return 22;
      case AccessibilitySettingsService.textSizeLarge:
      default:
        return 19;
    }
  }

  String _textSizeLabel(String value) {
    for (final option in _textSizeOptions) {
      if (option.value == value) {
        return option.label;
      }
    }
    return 'Büyük';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Erişilebilirlik Ayarları',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blue600),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.p6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHapticFeedbackSection(),
                  const SizedBox(height: AppSpacing.spaceY4),
                  _buildTextSizeSection(),
                  const SizedBox(height: AppSpacing.spaceY4),
                  _buildPreviewCard(),
                  const SizedBox(height: AppSpacing.p8),
                  AppButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    semanticsLabel: 'Ayarları kaydet',
                    fullWidth: true,
                    isLoading: _isSaving,
                    child: const Text('Ayarları Kaydet'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHapticFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceY4),
      decoration: BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        dense: false,
        title: const Text(
          'Titreşimli geri bildirim',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: _hapticFeedbackEnabled,
        activeTrackColor: AppColors.green600,
        inactiveTrackColor: AppColors.gray700,
        activeThumbColor: Colors.white,
        inactiveThumbColor: AppColors.gray300,
        onChanged: (value) {
          setState(() {
            _hapticFeedbackEnabled = value;
          });
        },
      ),
    );
  }

  Widget _buildTextSizeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceY4),
      decoration: BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metin boyutu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._textSizeOptions.map((option) {
            final selected = _textSizePreference == option.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(
                button: true,
                selected: selected,
                label: selected
                    ? 'Metin boyutu ${option.label}, seçili'
                    : 'Metin boyutu ${option.label}',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _textSizePreference = option.value;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.blue600 : AppColors.gray700,
                      borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          option.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (selected)
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Semantics(
      label:
          'Metin boyutu önizlemesi. Seçili boyut: ${_textSizeLabel(_textSizePreference)}. '
          'Sonraki durak: Hunat Durağı. Yaklaşık 4 dakika sonra ininiz.',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceY4),
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
          border: Border.all(color: AppColors.borderBlue500),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metin boyutu önizlemesi',
              style: TextStyle(
                color: AppColors.subtitleTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sonraki durak: Hunat Durağı',
              style: TextStyle(
                color: Colors.white,
                fontSize: _previewPrimaryFontSize(),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yaklaşık 4 dakika sonra ininiz.',
              style: TextStyle(
                color: AppColors.subtitleTextColor,
                fontSize: _previewSecondaryFontSize(),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextSizeOption {
  const _TextSizeOption({required this.value, required this.label});

  final String value;
  final String label;
}
