import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:yol_arkadasim/business/arrival/arrival_screen.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/utils/map_url_helper.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';

class JourneyDetailScreen extends StatefulWidget {
  const JourneyDetailScreen({super.key, required this.journeyPlan});

  final JourneyPlan journeyPlan;

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  String? _feedbackMessage;

  JourneyPlan get journeyPlan => widget.journeyPlan;

  Future<void> _openStartStopDirections() async {
    const errorMessage = 'Google Maps yönlendirmesi açılamadı.';
    final uri = buildWalkingDirectionsUri(
      journeyPlan.navigationMetadata.startStopLocation,
    );
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;

    if (launched) {
      setState(() => _feedbackMessage = null);
      return;
    }

    setState(() => _feedbackMessage = errorMessage);
    SemanticsService.announce(errorMessage, Directionality.of(context));
  }

  void _goToArrivalScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArrivalScreen(journeyPlan: journeyPlan),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceX3),
      child: Semantics(
        label: '$label: $value',
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.screenSubtitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.buttonLabel.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(String message) {
    return Semantics(
      container: true,
      label: message,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.p6),
          decoration: BoxDecoration(
            color: AppColors.gray800,
            borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
            border: Border.all(
              color: AppColors.borderOrange500,
              width: 1.2,
            ),
          ),
          child: Text(
            message,
            style: AppTextStyles.screenSubtitle.copyWith(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? feedbackMessage = _feedbackMessage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(title: 'Rota Detayı'),
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
                    Semantics(
                      header: true,
                      child: Text(
                        'Rota Detayı',
                        style: AppTextStyles.screenTitle.copyWith(
                          fontSize: 32,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceY4),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p6),
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius:
                            BorderRadius.circular(AppRadius.rounded2xl),
                        border: Border.all(
                          color: AppColors.borderBlue500,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            label: 'Hedef adı',
                            value: journeyPlan.destinationName,
                          ),
                          _buildInfoRow(
                            label: 'Hat adı',
                            value: journeyPlan.routeName,
                          ),
                          _buildInfoRow(
                            label: 'Toplam tahmini süre',
                            value: journeyPlan.totalDurationText,
                          ),
                          _buildInfoRow(
                            label: 'Biniş durağı',
                            value: journeyPlan.startStopName,
                          ),
                          _buildInfoRow(
                            label: 'İniş durağı',
                            value: journeyPlan.endStopName,
                          ),
                        ],
                      ),
                    ),
                    if (feedbackMessage != null) ...[
                      const SizedBox(height: AppSpacing.spaceY4),
                      _buildFeedbackBanner(feedbackMessage),
                    ],
                    const SizedBox(height: AppSpacing.spaceY4),
                    AppButton(
                      onPressed: _openStartStopDirections,
                      semanticsLabel:
                          '${journeyPlan.startStopName} için Google Maps ile yol tarifi al',
                      fullWidth: true,
                      size: 'xl',
                      minHeight: 72,
                      borderRadius: AppRadius.rounded2xl,
                      backgroundColor: AppColors.blue600,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Biniş Durağına Yol Tarifi Al',
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceY4),
                    AppButton(
                      onPressed: _goToArrivalScreen,
                      semanticsLabel:
                          'Durağa ulaştım, otobüs bekleme ekranına geç',
                      fullWidth: true,
                      size: 'xl',
                      minHeight: 72,
                      borderRadius: AppRadius.rounded2xl,
                      backgroundColor: AppColors.green600,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Durağa Ulaştım',
                          textAlign: TextAlign.center,
                          softWrap: true,
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
