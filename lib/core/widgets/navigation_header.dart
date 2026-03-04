import 'package:flutter/material.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import '../widgets/accessibility_settings.dart';
import '../widgets/app_button.dart';

class NavigationHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const NavigationHeader({super.key, this.title = 'YolArkadaşım'});

  @override
  State<NavigationHeader> createState() => _NavigationHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _NavigationHeaderState extends State<NavigationHeader> {
  bool _showSettings = false;

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });
    if (_showSettings) {
      // TODO: burada açılma duyurusu (voice) tetiklenebilir
    } else {
      // TODO: burada kapanış duyurusu (voice) tetiklenebilir
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.blue600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.navigation, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AppButton(
                onPressed: _toggleSettings,
                semanticsLabel: 'Erişilebilirlik ayarları',
                size: 'custom',
                minHeight: 48,
                child: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
        ),
        if (_showSettings)
          AccessibilitySettings(
            isOpen: _showSettings,
            onClose: () => setState(() => _showSettings = false),
          ),
      ],
    );
  }
}
