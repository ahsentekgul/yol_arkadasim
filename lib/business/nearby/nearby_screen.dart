import 'package:flutter/material.dart';

import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';

import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  static final List<Map<String, dynamic>> mockNearbyStops = [
    {
      'id': '1',
      'name': 'Taksim Meydanı',
      'distance': '0.2 km uzakta',
      'accessible': true,
      'audio': true,
    },
    {
      'id': '2',
      'name': 'Şişli Metro',
      'distance': '0.5 km uzakta',
      'accessible': true,
      'audio': false,
    },
  ];

  Widget _buildNearbyView(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Yakındaki Duraklar',
          style: AppTextStyles.screenTitle,
        ),
        const SizedBox(height: 12),
        Column(
          children: mockNearbyStops.map((stop) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AppButton(
                onPressed: () =>
                    debugPrint('Durak seçildi: ${stop['name']} (demo)'),
                semanticsLabel: 'Durak seç: ${stop['name']}',
                fullWidth: true,
                size: 'custom',
                minHeight: 200,
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 32, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stop['name'],
                                style: AppTextStyles.screenTitle.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              if (stop['accessible'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.borderGreen500,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Erişilebilir',
                                    style: AppTextStyles.buttonLabel.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            stop['distance'],
                            style: AppTextStyles.screenSubtitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _buildNearbyView(context),
            ),
          ),
        ),
      ),
    );
  }
}
