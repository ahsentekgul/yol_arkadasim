import 'package:flutter/material.dart';

import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';

class NoDirectRouteState extends StatelessWidget {
  const NoDirectRouteState({
    super.key,
    required this.placeName,
    required this.placeAddress,
    required this.primaryButtonText,
    required this.primaryButtonSemanticsLabel,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.secondaryButtonSemanticsLabel,
    this.onSecondaryPressed,
  });

  final String placeName;
  final String placeAddress;
  final String primaryButtonText;
  final String primaryButtonSemanticsLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final String? secondaryButtonSemanticsLabel;
  final VoidCallback? onSecondaryPressed;

  static const String _title = 'Aktarmasız rota bulunamadı';
  static const String _selectedDestinationLabel = 'Seçilen hedef';
  static const String _description =
      'Bu hedef için şu an sistemde uygun aktarmasız rota bulunamadı.';
  static const String _supportTitle = 'Ulaşım desteği için Alo 153';
  static const String _supportDescription =
      'En güncel güzergâh ve ulaşım desteği için Kayseri Ulaşım / Büyükşehir Belediyesi Alo 153 destek hattıyla iletişime geçebilirsiniz.';

  String get _semanticsLabel =>
      '$_title. Seçilen hedef: $placeName, $placeAddress. '
      '$_description '
      'En güncel güzergâh ve ulaşım desteği için Kayseri Ulaşım veya Büyükşehir Belediyesi Alo 153 destek hattıyla iletişime geçebilirsiniz.';

  @override
  Widget build(BuildContext context) {
    final bool showSecondaryButton =
        secondaryButtonText != null && onSecondaryPressed != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          liveRegion: true,
          label: _semanticsLabel,
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.orange600,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceX3),
                    Expanded(
                      child: Text(
                        _title,
                        style: AppTextStyles.buttonLabel.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceY4),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.p6),
                  decoration: BoxDecoration(
                    color: AppColors.gray800,
                    borderRadius: BorderRadius.circular(AppRadius.roundedXl),
                    border: Border.all(
                      color: AppColors.borderOrange500,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDestinationLabel,
                        style: AppTextStyles.screenSubtitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray300,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceX3),
                      Text(
                        placeName,
                        style: AppTextStyles.buttonLabel.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceX3),
                      Text(
                        placeAddress,
                        style: AppTextStyles.screenSubtitle.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray300,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceY4),
                Text(
                  _description,
                  style: AppTextStyles.screenSubtitle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray300,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceY4),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.p6),
                  decoration: BoxDecoration(
                    color: AppColors.gray800,
                    borderRadius: BorderRadius.circular(AppRadius.roundedXl),
                    border: Border.all(
                      color: AppColors.borderOrange500,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _supportTitle,
                        style: AppTextStyles.buttonLabel.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.borderOrange500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceX3),
                      Text(
                        _supportDescription,
                        style: AppTextStyles.screenSubtitle.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray300,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.p8),
              ],
            ),
          ),
        ),
        AppButton(
          fullWidth: true,
          semanticsLabel: primaryButtonSemanticsLabel,
          onPressed: onPrimaryPressed,
          child: Text(
            primaryButtonText,
            textAlign: TextAlign.center,
          ),
        ),
        if (showSecondaryButton) ...[
          const SizedBox(height: AppSpacing.spaceY4),
          AppButton(
            fullWidth: true,
            variant: 'secondary',
            semanticsLabel:
                secondaryButtonSemanticsLabel ?? secondaryButtonText!,
            onPressed: onSecondaryPressed,
            child: Text(
              secondaryButtonText!,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
