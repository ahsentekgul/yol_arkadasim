import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';

// UI-only accessibility settings modal closely matching React layout.

class AccessibilitySettings extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const AccessibilitySettings({Key? key, required this.isOpen, required this.onClose}) : super(key: key);

  @override
  State<AccessibilitySettings> createState() => _AccessibilitySettingsState();
}

class _AccessibilitySettingsState extends State<AccessibilitySettings> {
  double _voiceSpeed = 1.0;
  bool _voiceEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoAnnouncements = true;
  String _textSize = 'large';

  void _updateSetting(String key, dynamic value) {
    setState(() {
      switch (key) {
        case 'voiceSpeed':
          _voiceSpeed = value as double;
          break;
        case 'voiceEnabled':
          _voiceEnabled = value as bool;
          break;
        case 'vibrationEnabled':
          _vibrationEnabled = value as bool;
          break;
        case 'autoAnnouncements':
          _autoAnnouncements = value as bool;
          break;
        case 'textSize':
          _textSize = value as String;
          break;
      }
    });
    // TODO: burada titreşim veya ses testi tetiklenebilir (UI-only)
  }

  void _testVoice() {
    // Demo: TTS placeholder call (UI-only)
    debugPrint('Ses hızı testi (demo): $_voiceSpeed');
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    final maxWidth = 448.0;
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.gray800,
              borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Erişilebilirlik Ayarları',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: widget.onClose,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gray700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Voice Speed
                  const Text('Ses Hızı', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Slider(
                    value: _voiceSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: _voiceSpeed.toStringAsFixed(1),
                    activeColor: AppColors.blue600,
                    inactiveColor: AppColors.gray700,
                    onChanged: (v) => _updateSetting('voiceSpeed', v),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Yavaş', style: TextStyle(color: AppColors.gray300, fontSize: 12)),
                        Text('Normal', style: TextStyle(color: AppColors.gray300, fontSize: 12)),
                        Text('Hızlı', style: TextStyle(color: AppColors.gray300, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    child: const Text('Ses Hızını Test Et'),
                    onPressed: _testVoice,
                    semanticsLabel: 'Ses hızını test et',
                    fullWidth: true,
                  ),
                  const SizedBox(height: 18),

                  // Vibration toggle (styled to match React)
                  const Text('Titreşim', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _updateSetting('vibrationEnabled', !_vibrationEnabled),
                    borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _vibrationEnabled ? AppColors.green600 : AppColors.gray700,
                        borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                      ),
                      child: Center(
                        child: Text(
                          _vibrationEnabled ? 'Titreşim Açık' : 'Titreşim Kapalı',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Auto announcements
                  const Text('Otomatik Duyurular', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _updateSetting('autoAnnouncements', !_autoAnnouncements),
                    borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _autoAnnouncements ? AppColors.green600 : AppColors.gray700,
                        borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                      ),
                      child: Center(
                        child: Text(
                          _autoAnnouncements ? 'Duyurular Açık' : 'Duyurular Kapalı',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text size
                  const Text('Metin Boyutu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Column(
                    children: ['medium', 'large', 'extra-large'].map((size) {
                      final label = size == 'medium' ? 'Orta' : size == 'large' ? 'Büyük' : 'Çok Büyük';
                      final selected = _textSize == size;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: InkWell(
                          onTap: () => _updateSetting('textSize', size),
                          borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.blue600 : AppColors.gray700,
                              borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  AppButton(
                    child: const Text('Ayarları Kaydet'),
                    onPressed: widget.onClose,
                    semanticsLabel: 'Ayarları kaydet ve kapat',
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

