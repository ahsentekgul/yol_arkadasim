import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/models/beacon_detection.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';
import 'package:yol_arkadasim/services/beacon_scanner_service.dart';

enum _JourneySimulationStage {
  onBus,
  oneStopBefore,
  waitingForTargetStopBeacon,
  arrivedAtEndStop,
  completed,
}

class JourneyStepsScreen extends StatefulWidget {
  const JourneyStepsScreen({super.key, required this.journeyPlan});

  final JourneyPlan journeyPlan;

  @override
  State<JourneyStepsScreen> createState() => _JourneyStepsScreenState();
}

class _JourneyStepsScreenState extends State<JourneyStepsScreen> {
  final BeaconScannerService _scanner = BeaconScannerService();
  StreamSubscription<List<BeaconDetection>>? _detectionsSubscription;

  _JourneySimulationStage _stage = _JourneySimulationStage.onBus;
  Timer? _simulationTimer;
  int _elapsedSeconds = 0;
  bool _targetStopReached = false;

  static const int _travelSimulationSeconds = 15;
  static const int _oneStopWarningSeconds = 5;

  int get _totalSimulationSeconds =>
      _travelSimulationSeconds + _oneStopWarningSeconds;

  double get _progressValue {
    if (_stage == _JourneySimulationStage.arrivedAtEndStop ||
        _stage == _JourneySimulationStage.completed) {
      return 1.0;
    }
    return (_elapsedSeconds / _totalSimulationSeconds).clamp(0.0, 0.9);
  }

  String get _progressSemanticValue {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return 'Otobüstesiniz. İneceğiniz durağa doğru ilerliyorsunuz.';
      case _JourneySimulationStage.oneStopBefore:
        return 'İnilecek durağa yaklaşıyorsunuz. İnmenize 1 durak kaldı.';
      case _JourneySimulationStage.waitingForTargetStopBeacon:
        return 'Hedef durak sinyali bekleniyor.';
      case _JourneySimulationStage.arrivedAtEndStop:
        return 'İniş durağına ulaşıldı.';
      case _JourneySimulationStage.completed:
        return 'Yolculuk tamamlandı.';
    }
  }

  String get _stageTitle {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return 'Yolculuk başladı';
      case _JourneySimulationStage.oneStopBefore:
        return 'İnmenize 1 durak kaldı';
      case _JourneySimulationStage.waitingForTargetStopBeacon:
        return 'Hedef durak bekleniyor';
      case _JourneySimulationStage.arrivedAtEndStop:
        return 'İniş durağına ulaştınız';
      case _JourneySimulationStage.completed:
        return 'Yolculuk tamamlandı';
    }
  }

  String get _approachWarningMessage {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return 'Yolculuğunuz başladı. İneceğiniz durak takip ediliyor.';
      case _JourneySimulationStage.oneStopBefore:
        return 'İniş durağına yaklaşıyorsunuz. İnmeye hazırlanın.';
      case _JourneySimulationStage.waitingForTargetStopBeacon:
        return 'Hedef durak sinyali bekleniyor. İniş durağı algılandığında sizi uyaracağız.';
      case _JourneySimulationStage.arrivedAtEndStop:
        return 'İniş durağına ulaştınız. Lütfen güvenli şekilde inin.';
      case _JourneySimulationStage.completed:
        return 'Yolculuk tamamlandı.';
    }
  }

  Color get _stageBorderColor {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return AppColors.borderGreen500;
      case _JourneySimulationStage.oneStopBefore:
        return AppColors.borderOrange500;
      case _JourneySimulationStage.waitingForTargetStopBeacon:
        return AppColors.borderBlue500;
      case _JourneySimulationStage.arrivedAtEndStop:
        return AppColors.borderBlue500;
      case _JourneySimulationStage.completed:
        return AppColors.borderGreen500;
    }
  }

  double get _cardHeight {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return 520;
      case _JourneySimulationStage.oneStopBefore:
        return 520;
      case _JourneySimulationStage.waitingForTargetStopBeacon:
        return 500;
      case _JourneySimulationStage.arrivedAtEndStop:
        return 460;
      case _JourneySimulationStage.completed:
        return 440;
    }
  }

  double get _cardVerticalPadding {
    switch (_stage) {
      case _JourneySimulationStage.arrivedAtEndStop:
        return 36;
      default:
        return 40;
    }
  }

  double get _topContentSpacing {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
      case _JourneySimulationStage.oneStopBefore:
      case _JourneySimulationStage.waitingForTargetStopBeacon:
        return 20;
      case _JourneySimulationStage.arrivedAtEndStop:
      case _JourneySimulationStage.completed:
        return 8;
    }
  }

  @override
  void initState() {
    super.initState();
    _detectionsSubscription = _scanner.detectionsStream.listen(
      _onBeaconDetections,
      onError: (_) {},
    );
    unawaited(_scanner.startScan());
    _startSimulationTimer();
  }

  void _onBeaconDetections(List<BeaconDetection> detections) {
    if (!mounted || _targetStopReached) {
      return;
    }

    for (final detection in detections) {
      if (detection.isTargetStop && detection.isTargetStopReached) {
        _handleTargetStopReached();
        return;
      }
    }
  }

  void _handleTargetStopReached() {
    if (_targetStopReached) {
      return;
    }
    _targetStopReached = true;
    _simulationTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _stage = _JourneySimulationStage.arrivedAtEndStop;
    });

    final message =
        'İniş durağına ulaştınız. İniş durağı: ${widget.journeyPlan.endStopName}. '
        'Lütfen güvenli şekilde inin.';
    SemanticsService.announce(message, Directionality.of(context));
  }

  void _announceStageChange(_JourneySimulationStage stage) {
    final String? message;
    switch (stage) {
      case _JourneySimulationStage.onBus:
        return;
      case _JourneySimulationStage.oneStopBefore:
        message =
            'İnmenize 1 durak kaldı. Sonraki durak: ${widget.journeyPlan.endStopName}. Sonraki durak iniş durağınız. Lütfen inmeye hazırlanın.';
      case _JourneySimulationStage.waitingForTargetStopBeacon:
        return;
      case _JourneySimulationStage.arrivedAtEndStop:
        return;
      case _JourneySimulationStage.completed:
        message = 'Yolculuk tamamlandı.';
    }
    SemanticsService.announce(message, Directionality.of(context));
  }

  void _startSimulationTimer() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_stage == _JourneySimulationStage.arrivedAtEndStop ||
          _stage == _JourneySimulationStage.waitingForTargetStopBeacon) {
        timer.cancel();
        return;
      }
      final previousStage = _stage;
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= _travelSimulationSeconds &&
            _stage == _JourneySimulationStage.onBus) {
          _stage = _JourneySimulationStage.oneStopBefore;
        } else if (_elapsedSeconds >= _totalSimulationSeconds &&
            _stage == _JourneySimulationStage.oneStopBefore) {
          _stage = _JourneySimulationStage.waitingForTargetStopBeacon;
        }
      });
      if (_stage != previousStage) {
        _announceStageChange(_stage);
      }
      if (_stage == _JourneySimulationStage.waitingForTargetStopBeacon) {
        timer.cancel();
        _simulationTimer?.cancel();
      }
    });
  }

  void _completeJourney() {
    _simulationTimer?.cancel();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    double labelFontSize = 19,
    double valueFontSize = 22,
    FontWeight valueFontWeight = FontWeight.w700,
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
                fontSize: labelFontSize,
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
                fontSize: valueFontSize,
                fontWeight: valueFontWeight,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Semantics(
      label: 'Yolculuk durumu',
      value: _progressSemanticValue,
      child: ExcludeSemantics(
        child: LinearProgressIndicator(
          value: _progressValue,
          backgroundColor: AppColors.gray700,
          color: _stageBorderColor,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildOnBusContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  label: 'İneceğiniz durak',
                  value: widget.journeyPlan.endStopName,
                  labelFontSize: 22,
                  valueFontSize: 36,
                  valueFontWeight: FontWeight.w800,
                ),
                const ExcludeSemantics(
                  child: Divider(
                    height: 32,
                    thickness: 1,
                    color: AppColors.gray700,
                  ),
                ),
                _buildInfoRow(
                  label: 'Gideceğiniz yer',
                  value: widget.journeyPlan.destinationName,
                  labelFontSize: 22,
                  valueFontSize: 28,
                  valueFontWeight: FontWeight.w800,
                ),
                const ExcludeSemantics(
                  child: Divider(
                    height: 32,
                    thickness: 1,
                    color: AppColors.gray700,
                  ),
                ),
                Semantics(
                  label: 'Bilgilendirme: $_approachWarningMessage',
                  child: ExcludeSemantics(
                    child: Text(
                      _approachWarningMessage,
                      style: AppTextStyles.screenSubtitle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildWarningContent() {
    final stopName = widget.journeyPlan.endStopName;
    const warningLine1 = 'Sonraki durak iniş durağınız.';
    const warningLine2 = 'Lütfen inmeye hazırlanın.';
    return Semantics(
      label:
          'Uyarı: İnmenize 1 durak kaldı. Sonraki durak: $stopName. $warningLine1 $warningLine2',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      'Sonraki durak',
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
                      stopName,
                      style: AppTextStyles.buttonLabel.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const ExcludeSemantics(
                    child: Divider(
                      height: 32,
                      thickness: 1,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      warningLine1,
                      style: AppTextStyles.buttonLabel.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      warningLine2,
                      style: AppTextStyles.buttonLabel.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildWaitingForBeaconContent() {
    final stopName = widget.journeyPlan.endStopName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Semantics(
              label:
                  'Hedef durak sinyali bekleniyor. İniş durağı: $stopName. '
                  'İniş durağı algılandığında sizi uyaracağız.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      'İniş durağı',
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
                      stopName,
                      style: AppTextStyles.buttonLabel.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const ExcludeSemantics(
                    child: Divider(
                      height: 32,
                      thickness: 1,
                      color: AppColors.gray700,
                    ),
                  ),
                  ExcludeSemantics(
                    child: Text(
                      _approachWarningMessage,
                      style: AppTextStyles.screenSubtitle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildArrivedContent() {
    final stopName = widget.journeyPlan.endStopName;
    const infoMessageSemantic =
        'Bu durak, ineceğiniz duraktır. Lütfen güvenli şekilde inin.';
    const infoMessageVisual =
        'Bu durak, ineceğiniz duraktır.\nLütfen güvenli şekilde inin.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Semantics(
              label:
                  'İniş durağına ulaştınız. İniş durağı: $stopName. $infoMessageSemantic',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      'İniş durağı',
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
                      stopName,
                      style: AppTextStyles.buttonLabel.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const ExcludeSemantics(
                    child: Divider(
                      height: 32,
                      thickness: 1,
                      color: AppColors.gray700,
                    ),
                  ),
                  ExcludeSemantics(
                    child: Text(
                      infoMessageVisual,
                      style: AppTextStyles.screenSubtitle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildCompletedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Semantics(
              label:
                  'Yolculuk tamamlandı. Rota bilgilerinizi tekrar incelemek için geri dönebilirsiniz.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      'Yolculuk tamamlandı.',
                      style: AppTextStyles.buttonLabel.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ExcludeSemantics(
                    child: Text(
                      'Rota bilgilerinizi tekrar incelemek için geri dönebilirsiniz.',
                      style: AppTextStyles.screenSubtitle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildCardContent() {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return _buildOnBusContent();
      case _JourneySimulationStage.oneStopBefore:
        return _buildWarningContent();
      case _JourneySimulationStage.waitingForTargetStopBeacon:
        return _buildWaitingForBeaconContent();
      case _JourneySimulationStage.arrivedAtEndStop:
        return _buildArrivedContent();
      case _JourneySimulationStage.completed:
        return _buildCompletedContent();
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _detectionsSubscription?.cancel();
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(title: 'Yolculuk Takibi'),
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
                    SizedBox(height: _topContentSpacing),
                    Semantics(
                      header: true,
                      child: Text(
                        _stageTitle,
                        style: AppTextStyles.screenTitle.copyWith(fontSize: 28),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceY4),
                    Container(
                      height: _cardHeight,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: _cardVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(
                          AppRadius.rounded2xl,
                        ),
                        border: Border.all(
                          color: _stageBorderColor,
                          width: 1.4,
                        ),
                      ),
                      child: _buildCardContent(),
                    ),
                    if (_stage == _JourneySimulationStage.arrivedAtEndStop) ...[
                      const SizedBox(height: AppSpacing.spaceY4),
                      AppButton(
                        fullWidth: true,
                        size: 'xl',
                        minHeight: 72,
                        backgroundColor: AppColors.blue600,
                        semanticsLabel: 'İndim, yolculuğu tamamla',
                        onPressed: _completeJourney,
                        child: const Text(
                          'Yolculuğu Tamamla',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
