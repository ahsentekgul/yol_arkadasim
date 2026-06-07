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

  Widget _buildMainRouteInfo({required String routeName}) {
    return Semantics(
      label: 'Beklenecek otobüs: $routeName',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(
              'Beklenecek otobüs',
              style: AppTextStyles.screenSubtitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: Text(
              routeName,
              style: AppTextStyles.buttonLabel.copyWith(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(
              label,
              style: AppTextStyles.screenSubtitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: Text(
              value,
              style: AppTextStyles.buttonLabel.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
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
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Biniş durağına ulaştınız',
                        style: AppTextStyles.screenTitle.copyWith(fontSize: 28),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceY4),
                    Container(
                      constraints: const BoxConstraints(minHeight: 430),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
                        border: Border.all(color: AppColors.borderBlue500, width: 1.4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainRouteInfo(routeName: journeyPlan.routeName),
                          const ExcludeSemantics(
                            child: Divider(
                              height: 28,
                              thickness: 1,
                              color: AppColors.gray700,
                            ),
                          ),
                          _buildInfoRow(
                            label: 'Bulunduğunuz durak',
                            value: journeyPlan.startStopName,
                          ),
                          const ExcludeSemantics(
                            child: Divider(
                              height: 28,
                              thickness: 1,
                              color: AppColors.gray700,
                            ),
                          ),
                          _buildInfoRow(
                            label: 'İneceğiniz durak',
                            value: journeyPlan.endStopName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceY4),
                    AppButton(
                      onPressed: () => _goToJourneySteps(context),
                      semanticsLabel: 'Otobüse bindim, yolculuk adımlarını başlat',
                      fullWidth: true,
                      size: 'xl',
                      minHeight: 72,
                      borderRadius: AppRadius.rounded2xl,
                      backgroundColor: AppColors.blue600,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Otobüse Bindim',
                          textAlign: TextAlign.center,
                        ),
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
