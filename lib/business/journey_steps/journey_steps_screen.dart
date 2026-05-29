import 'dart:async';

import 'package:flutter/material.dart';

import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_radius.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/core/widgets/app_navigation_bar.dart';
import 'package:yol_arkadasim/data/models/transit_models.dart';

enum _JourneySimulationStage {
  onBus,
  oneStopBefore,
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
  _JourneySimulationStage _stage = _JourneySimulationStage.onBus;
  Timer? _simulationTimer;
  int _elapsedSeconds = 0;
  static const int _travelSimulationSeconds = 15;
  static const int _oneStopWarningSeconds = 5;

  int get _totalSimulationSeconds =>
      _travelSimulationSeconds + _oneStopWarningSeconds;

  double get _progressValue {
    if (_stage == _JourneySimulationStage.completed) {
      return 1.0;
    }
    return (_elapsedSeconds / _totalSimulationSeconds).clamp(0.0, 1.0);
  }

  String get _stageTitle {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return 'Yolculuk başladı';
      case _JourneySimulationStage.oneStopBefore:
        return 'İnmenize 1 durak kaldı';
      case _JourneySimulationStage.arrivedAtEndStop:
        return 'İniş durağına ulaştınız';
      case _JourneySimulationStage.completed:
        return 'Yolculuk tamamlandı';
    }
  }

  String get _approachWarningMessage {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return 'İniş durağınız: ${widget.journeyPlan.endStopName}. Yaklaştığınızda sizi uyaracağız.';
      case _JourneySimulationStage.oneStopBefore:
        return 'Lütfen inmeye hazırlanın. Bir sonraki durakta ineceksiniz.';
      case _JourneySimulationStage.arrivedAtEndStop:
        return 'İniş durağınız: ${widget.journeyPlan.endStopName}. Lütfen güvenli şekilde inin.';
      case _JourneySimulationStage.completed:
        return 'Yolculuk tamamlandı. Geri dönerek rota bilgilerinizi tekrar inceleyebilirsiniz.';
    }
  }

  Color get _stageBorderColor {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return AppColors.borderGreen500;
      case _JourneySimulationStage.oneStopBefore:
        return AppColors.borderOrange500;
      case _JourneySimulationStage.arrivedAtEndStop:
        return AppColors.borderBlue500;
      case _JourneySimulationStage.completed:
        return AppColors.borderGreen500;
    }
  }

  @override
  void initState() {
    super.initState();
    _startSimulationTimer();
  }

  void _startSimulationTimer() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_stage == _JourneySimulationStage.arrivedAtEndStop) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= _travelSimulationSeconds &&
            _stage == _JourneySimulationStage.onBus) {
          _stage = _JourneySimulationStage.oneStopBefore;
        } else if (_elapsedSeconds >= _totalSimulationSeconds &&
            _stage == _JourneySimulationStage.oneStopBefore) {
          _stage = _JourneySimulationStage.arrivedAtEndStop;
        }
      });
      if (_stage == _JourneySimulationStage.arrivedAtEndStop) {
        timer.cancel();
        _simulationTimer?.cancel();
      }
    });
  }

  void _completeJourney() {
    _simulationTimer?.cancel();
    setState(() {
      _stage = _JourneySimulationStage.completed;
      _elapsedSeconds = _totalSimulationSeconds;
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavigationBar.subPage(title: 'Yolculuk Başladı'),
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
                    const SizedBox(height: 8),
                    Semantics(
                      container: true,
                      liveRegion: true,
                      label:
                          'Yolculuk durumu. $_stageTitle. $_approachWarningMessage. '
                          'Hat: ${widget.journeyPlan.routeName}. '
                          'İniş durağı: ${widget.journeyPlan.endStopName}. '
                          'Hedef: ${widget.journeyPlan.destinationName}.',
                      child: ExcludeSemantics(
                        child: Container(
                              padding: const EdgeInsets.all(AppSpacing.p6),
                              decoration: BoxDecoration(
                                color: AppColors.gray800,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.rounded2xl,
                                ),
                                border: Border.all(color: _stageBorderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _stageTitle,
                                    style: AppTextStyles.buttonLabel.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Hat',
                                    style: AppTextStyles.screenSubtitle
                                        .copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.journeyPlan.routeName,
                                    style: AppTextStyles.buttonLabel.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'İniş Durağınız',
                                    style: AppTextStyles.screenSubtitle
                                        .copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.journeyPlan.endStopName,
                                    style: AppTextStyles.buttonLabel.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Hedef',
                                    style: AppTextStyles.screenSubtitle
                                        .copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.journeyPlan.destinationName,
                                    style: AppTextStyles.buttonLabel.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _approachWarningMessage,
                                    style: AppTextStyles.screenSubtitle
                                        .copyWith(
                                      fontSize: 17,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: _progressValue,
                                    backgroundColor: AppColors.gray700,
                                    color: _stageBorderColor,
                                    minHeight: 4,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                    if (_stage == _JourneySimulationStage.arrivedAtEndStop) ...[
                      const SizedBox(height: AppSpacing.spaceY4),
                      AppButton(
                        fullWidth: true,
                        size: 'xl',
                        minHeight: 72,
                        backgroundColor: AppColors.green600,
                        semanticsLabel: 'Yolculuğu tamamla',
                        onPressed: _completeJourney,
                        child: const Text('Yolculuğu Tamamla'),
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
