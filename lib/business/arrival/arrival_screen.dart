import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:yol_arkadasim/business/journey_steps/journey_steps_screen.dart';
import 'package:yol_arkadasim/core/accessibility/accessibility_settings_service.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/models/beacon_detection.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';
import 'package:yol_arkadasim/services/beacon_scanner_service.dart';
import 'package:yol_arkadasim/services/vibration_service.dart';

enum _BusBeaconStatus {
  waiting,
  approaching,
  veryClose,
}

class ArrivalScreen extends StatefulWidget {
  const ArrivalScreen({super.key, required this.journeyPlan});

  final JourneyPlan journeyPlan;

  @override
  State<ArrivalScreen> createState() => _ArrivalScreenState();
}

class _ArrivalScreenState extends State<ArrivalScreen> {
  final AccessibilitySettingsService _accessibilitySettingsService =
      AccessibilitySettingsService();
  final BeaconScannerService _scanner = BeaconScannerService();
  StreamSubscription<List<BeaconDetection>>? _detectionsSubscription;
  VibrationService? _vibrationService;

  _BusBeaconStatus _busStatus = _BusBeaconStatus.waiting;
  bool _announcedApproaching = false;
  bool _announcedVeryClose = false;

  String get _beaconStatusMessage {
    final stopName = widget.journeyPlan.startStopName;
    final routeName = widget.journeyPlan.routeName;

    switch (_busStatus) {
      case _BusBeaconStatus.waiting:
        return '$stopName durağında $routeName otobüsü bekleniyor.';
      case _BusBeaconStatus.approaching:
        return '$stopName durağında $routeName otobüsü yaklaşıyor.';
      case _BusBeaconStatus.veryClose:
        return '$routeName otobüsü çok yakında. '
            'Otobüse bindiyseniz yolculuk takibini başlatın.';
    }
  }

  String get _busStatusSemanticsLabel =>
      'Otobüs durumu. $_beaconStatusMessage';

  @override
  void initState() {
    super.initState();
    _detectionsSubscription = _scanner.detectionsStream.listen(
      _onDetections,
      onError: (_) {},
    );
    unawaited(_scanner.startScan());
    unawaited(_loadHapticSettings());
  }

  Future<void> _loadHapticSettings() async {
    final enabled =
        await _accessibilitySettingsService.getHapticFeedbackEnabled();
    if (!mounted) {
      return;
    }
    _vibrationService = VibrationService(vibrationEnabled: enabled);
  }

  void _onDetections(List<BeaconDetection> detections) {
    if (!mounted) {
      return;
    }

    BeaconDetection? busDetection;
    for (final detection in detections) {
      if (detection.isBus286) {
        busDetection = detection;
        break;
      }
    }

    if (busDetection == null) {
      return;
    }

    if (busDetection.isBusVeryClose) {
      _upgradeStatus(_BusBeaconStatus.veryClose);
    } else if (busDetection.isBusApproaching) {
      _upgradeStatus(_BusBeaconStatus.approaching);
    }
  }

  void _upgradeStatus(_BusBeaconStatus newStatus) {
    if (newStatus.index <= _busStatus.index) {
      return;
    }

    setState(() {
      _busStatus = newStatus;
    });

    if (newStatus == _BusBeaconStatus.approaching && !_announcedApproaching) {
      _announcedApproaching = true;
      SemanticsService.announce(_beaconStatusMessage, TextDirection.ltr);
      final vibrationService = _vibrationService;
      if (vibrationService != null) {
        unawaited(vibrationService.vibrateShort());
      }
    } else if (newStatus == _BusBeaconStatus.veryClose && !_announcedVeryClose) {
      _announcedVeryClose = true;
      SemanticsService.announce(_beaconStatusMessage, TextDirection.ltr);
      final vibrationService = _vibrationService;
      if (vibrationService != null) {
        unawaited(vibrationService.vibrateLong());
      }
    }
  }

  @override
  void dispose() {
    _detectionsSubscription?.cancel();
    _scanner.dispose();
    super.dispose();
  }

  void _goToJourneySteps(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JourneyStepsScreen(journeyPlan: widget.journeyPlan),
      ),
    );
  }

  Color _busStatusBorderColor() {
    switch (_busStatus) {
      case _BusBeaconStatus.waiting:
        return AppColors.borderBlue500;
      case _BusBeaconStatus.approaching:
        return AppColors.borderOrange500;
      case _BusBeaconStatus.veryClose:
        return AppColors.borderGreen500;
    }
  }

  Widget _buildBusStatusCard() {
    return Semantics(
      container: true,
      liveRegion: true,
      label: _busStatusSemanticsLabel,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: BorderRadius.circular(AppRadius.rounded2xl),
          border: Border.all(
            color: _busStatusBorderColor(),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Text(
                'Otobüs durumu',
                style: AppTextStyles.screenSubtitle.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ExcludeSemantics(
              child: Text(
                _beaconStatusMessage,
                softWrap: true,
                style: AppTextStyles.buttonLabel.copyWith(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(title: 'Otobüs Bekleniyor'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p6),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildBusStatusCard(),
                  ),
                  const SizedBox(height: AppSpacing.spaceY4),
                  AppButton(
                    onPressed: () => _goToJourneySteps(context),
                    semanticsLabel:
                        'Otobüse bindim, yolculuk takip ekranını aç',
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
    );
  }
}
