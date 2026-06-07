import 'package:flutter/material.dart';

import 'package:yol_arkadasim/data/models/transit_models.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key, required this.journeyPlan});

  final JourneyPlan journeyPlan;

  Widget _buildRoutesView() {
    final String transferText = journeyPlan.transferCount == 0
        ? 'Aktarmasız'
        : '${journeyPlan.transferCount} aktarma';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${journeyPlan.destinationName} için Rota',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray800,
            borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
            border: Border.all(color: AppColors.gray700, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hat: ${journeyPlan.routeName}',
                style: AppTextStyles.buttonLabel.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${journeyPlan.totalDurationText} • $transferText',
                style: AppTextStyles.screenSubtitle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                'Başlangıç: ${journeyPlan.startStopName}',
                style: AppTextStyles.screenSubtitle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'İniş: ${journeyPlan.endStopName}',
                style: AppTextStyles.screenSubtitle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Yolculuk Adımları',
          style: AppTextStyles.buttonLabel.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: journeyPlan.steps.map((step) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gray800,
                  borderRadius: BorderRadius.circular(AppRadius.roundedXl),
                  border: Border.all(color: AppColors.gray700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: AppTextStyles.buttonLabel.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: AppTextStyles.screenSubtitle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.durationText,
                      style: AppTextStyles.screenSubtitle.copyWith(
                        fontSize: 13,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p6),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildRoutesView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
