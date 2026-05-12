import 'package:flutter/material.dart';

import 'package:yol_arkadasim/business/journey_steps/journey_steps_screen.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';

class ArrivalScreen extends StatelessWidget {
  const ArrivalScreen({super.key, required this.journeyPlan});

  final JourneyPlan journeyPlan;

  void _goToJourneySteps(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JourneyStepsScreen(journeyPlan: journeyPlan),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.screenSubtitle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.buttonLabel.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(title: 'Otobüs Bekleniyor'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p6),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Biniş durağına ulaştınız',
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Otobüs bekleniyor',
                      style: AppTextStyles.screenSubtitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppSpacing.spaceY4),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p6),
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                        border: Border.all(color: AppColors.gray700),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            label: 'Hat adı',
                            value: journeyPlan.routeName,
                          ),
                          _buildInfoRow(
                            label: 'Biniş durağı',
                            value: journeyPlan.startStopName,
                          ),
                          _buildInfoRow(
                            label: 'İniş durağı',
                            value: journeyPlan.endStopName,
                          ),
                          Text(
                            'Hedef: ${journeyPlan.destinationName}',
                            style: AppTextStyles.screenSubtitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceY4),
                    AppButton(
                      onPressed: () => _goToJourneySteps(context),
                      semanticsLabel: 'Otobüse bindim, yolculuk adımlarına geç',
                      fullWidth: true,
                      size: 'xl',
                      minHeight: 72,
                      borderRadius: AppRadius.rounded2xl,
                      backgroundColor: AppColors.blue600,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Otobüse Bindim'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
