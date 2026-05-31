import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

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

  String get _progressSemanticValue {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return 'Otobüstesiniz. İneceğiniz durağa doğru ilerliyorsunuz.';
      case _JourneySimulationStage.oneStopBefore:
        return 'İnilecek durağa yaklaşıyorsunuz. İnmenize 1 durak kaldı.';
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
      case _JourneySimulationStage.arrivedAtEndStop:
        return 'İniş durağına ulaştınız';
      case _JourneySimulationStage.completed:
        return 'Yolculuk tamamlandı';
    }
  }

  String get _approachWarningMessage {
    switch (_stage) {
      case _JourneySimulationStage.onBus:
        return 'İneceğiniz durağa yaklaştığınızda sizi uyaracağız.';
      case _JourneySimulationStage.oneStopBefore:
        return 'İnmeye hazırlanın. Bir sonraki durakta ineceksiniz: ${widget.journeyPlan.endStopName}.';
      case _JourneySimulationStage.arrivedAtEndStop:
        return '${widget.journeyPlan.endStopName} durağına geldiniz. Bu durak, ineceğiniz duraktır. Lütfen güvenli şekilde inin.';
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

  void _announceStageChange(_JourneySimulationStage stage) {
    final String? message;
    switch (stage) {
      case _JourneySimulationStage.onBus:
        return;
      case _JourneySimulationStage.oneStopBefore:
        message =
            'İnmenize 1 durak kaldı. İnmeye hazırlanın. Bir sonraki durakta ineceksiniz: ${widget.journeyPlan.endStopName}.';
      case _JourneySimulationStage.arrivedAtEndStop:
        message =
            'İniş durağına ulaştınız. ${widget.journeyPlan.endStopName} durağına geldiniz. Bu durak, ineceğiniz duraktır. Lütfen güvenli şekilde inin.';
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
      if (_stage == _JourneySimulationStage.arrivedAtEndStop) {
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
          _stage = _JourneySimulationStage.arrivedAtEndStop;
        }
      });
      if (_stage != previousStage) {
        _announceStageChange(_stage);
      }
      if (_stage == _JourneySimulationStage.arrivedAtEndStop) {
        timer.cancel();
        _simulationTimer?.cancel();
      }
    });
  }

  void _completeJourney() {
    _simulationTimer?.cancel();
    final previousStage = _stage;
    setState(() {
      _stage = _JourneySimulationStage.completed;
      _elapsedSeconds = _totalSimulationSeconds;
    });
    if (_stage != previousStage) {
      _announceStageChange(_stage);
    }
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    double labelFontSize = 19,
    double valueFontSize = 22,
    FontWeight valueFontWeight = FontWeight.w700,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Semantics(
        label: '$label: $value',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Text(
                label,
                style: AppTextStyles.screenSubtitle.copyWith(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w700,
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
                ),
              ),
            ),
          ],
        ),
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
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildOnBusContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          label: 'İneceğiniz durak',
          value: widget.journeyPlan.endStopName,
          labelFontSize: 20,
          valueFontSize: 34,
          valueFontWeight: FontWeight.w800,
        ),
        _buildInfoRow(
          label: 'Gideceğiniz yer',
          value: widget.journeyPlan.destinationName,
          labelFontSize: 19,
          valueFontSize: 22,
        ),
        Semantics(
          label: 'Bilgilendirme: $_approachWarningMessage',
          child: ExcludeSemantics(
            child: Text(
              _approachWarningMessage,
              style: AppTextStyles.screenSubtitle.copyWith(
                fontSize: 21,
                height: 1.35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildWarningContent() {
    final stopName = widget.journeyPlan.endStopName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              'Uyarı: İnmeye hazırlanın. Bir sonraki durakta ineceksiniz: $stopName.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Text(
                  'İnmeye hazırlanın',
                  style: AppTextStyles.buttonLabel.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ExcludeSemantics(
                child: Text(
                  'Bir sonraki durakta ineceksiniz:',
                  style: AppTextStyles.screenSubtitle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ExcludeSemantics(
                child: Text(
                  stopName,
                  style: AppTextStyles.buttonLabel.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildArrivedContent() {
    final stopName = widget.journeyPlan.endStopName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              'İniş durağına ulaştınız. $stopName durağına geldiniz. Bu durak, ineceğiniz duraktır. Lütfen güvenli şekilde inin.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Text(
                  '$stopName durağına geldiniz.',
                  style: AppTextStyles.buttonLabel.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ExcludeSemantics(
                child: Text(
                  'Bu durak, ineceğiniz duraktır.',
                  style: AppTextStyles.screenSubtitle.copyWith(
                    fontSize: 22,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ExcludeSemantics(
                child: Text(
                  'Lütfen güvenli şekilde inin.',
                  style: AppTextStyles.screenSubtitle.copyWith(
                    fontSize: 22,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildCompletedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              'Yolculuk tamamlandı. Rota bilgilerinizi tekrar incelemek için geri dönebilirsiniz.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Text(
                  'Yolculuk tamamlandı.',
                  style: AppTextStyles.buttonLabel.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ExcludeSemantics(
                child: Text(
                  'Rota bilgilerinizi tekrar incelemek için geri dönebilirsiniz.',
                  style: AppTextStyles.screenSubtitle.copyWith(
                    fontSize: 20,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
      case _JourneySimulationStage.arrivedAtEndStop:
        return _buildArrivedContent();
      case _JourneySimulationStage.completed:
        return _buildCompletedContent();
    }
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
                    Semantics(
                      header: true,
                      child: Text(
                        _stageTitle,
                        style: AppTextStyles.screenTitle.copyWith(fontSize: 28),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceY4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(
                          AppRadius.rounded2xl,
                        ),
                        border: Border.all(color: _stageBorderColor),
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
