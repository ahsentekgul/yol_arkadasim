import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_spacing.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';
import 'package:yol_arkadasim/data/models/beacon_detection.dart';
import 'package:yol_arkadasim/services/beacon_scanner_service.dart';

class BeaconDebugScreen extends StatefulWidget {
  const BeaconDebugScreen({super.key});

  @override
  State<BeaconDebugScreen> createState() => _BeaconDebugScreenState();
}

class _BeaconDebugScreenState extends State<BeaconDebugScreen> {
  final BeaconScannerService _scanner = BeaconScannerService();

  StreamSubscription<List<BeaconDetection>>? _detectionsSubscription;

  List<BeaconDetection> _detections = [];
  bool _isScanning = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _detectionsSubscription = _scanner.detectionsStream.listen(
      (detections) {
        if (!mounted) {
          return;
        }
        setState(() {
          _detections = detections;
        });
      },
      onError: (Object error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _statusMessage = 'Stream hatası: $error';
        });
      },
    );
  }

  Future<void> _startScan() async {
    setState(() {
      _statusMessage = null;
    });

    try {
      await _scanner.startScan();
      if (!mounted) {
        return;
      }

      setState(() {
        _isScanning = _scanner.isScanning;
        if (!_isScanning) {
          _statusMessage =
              'Tarama başlatılamadı. Bluetooth, izinler veya konum servisini kontrol edin.';
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isScanning = false;
        _statusMessage = 'Tarama hatası: $e';
      });
    }
  }

  Future<void> _stopScan() async {
    try {
      await _scanner.stopScan();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Durdurma hatası: $e';
      });
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isScanning = _scanner.isScanning;
    });
  }

  @override
  void dispose() {
    _detectionsSubscription?.cancel();
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.gray800,
        title: Text('Beacon Debug', style: AppTextStyles.headerTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tarama durumu: ${_isScanning ? 'Taranıyor' : 'Taranmıyor'}',
                style: AppTextStyles.screenSubtitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.spaceY4),
              Text(
                'Bu ekran yalnızca beacon test/debug içindir.',
                style: AppTextStyles.screenSubtitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: AppSpacing.spaceY4),
                Text(
                  _statusMessage!,
                  style: const TextStyle(color: AppColors.orange600),
                ),
              ],
              const SizedBox(height: AppSpacing.spaceY4),
              AppButton(
                fullWidth: true,
                onPressed: _isScanning ? null : _startScan,
                disabled: _isScanning,
                child: const Text('Start Scan'),
              ),
              const SizedBox(height: AppSpacing.spaceX3),
              AppButton(
                fullWidth: true,
                variant: 'secondary',
                onPressed: _isScanning ? _stopScan : null,
                disabled: !_isScanning,
                child: const Text('Stop Scan'),
              ),
              const SizedBox(height: AppSpacing.spaceY4),
              Expanded(
                child: _detections.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: _detections.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.spaceY4),
                        itemBuilder: (context, index) {
                          return _BeaconDetectionCard(
                            detection: _detections[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Henüz proje beacon\'ı algılanmadı.\n'
        'Bluetooth açık mı, konum izni verildi mi ve beacon cihazları açık mı kontrol edin.',
        textAlign: TextAlign.center,
        style: AppTextStyles.screenSubtitle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BeaconDetectionCard extends StatelessWidget {
  final BeaconDetection detection;

  const _BeaconDetectionCard({required this.detection});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.gray800,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceY4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detection.readableLabel,
              style: AppTextStyles.headerTitle,
            ),
            const SizedBox(height: AppSpacing.spaceX3),
            _row('UUID', detection.uuid),
            _row('Major', detection.major.toString()),
            _row('Minor', detection.minor.toString()),
            _row('RSSI', detection.rssi.toString()),
            _row('Son 3 RSSI ortalaması', detection.averageRssi.toStringAsFixed(1)),
            _row('TX Power', detection.txPower?.toString() ?? '-'),
            _row('Device name', detection.deviceName ?? '-'),
            _row('Remote ID', detection.remoteId ?? '-'),
            _row('Detected at', detection.detectedAt.toIso8601String()),
            const SizedBox(height: AppSpacing.spaceX3),
            if (detection.isBus286) ...[
              Text(
                'Otobüs algılandı',
                style: AppTextStyles.screenSubtitle.copyWith(fontSize: 16),
              ),
              _row(
                'Yaklaşıyor mu',
                detection.isBusApproaching ? 'evet' : 'hayır',
              ),
              _row(
                'Çok yakın mı',
                detection.isBusVeryClose ? 'evet' : 'hayır',
              ),
            ],
            if (detection.isTargetStop) ...[
              Text(
                'Hedef durak algılandı',
                style: AppTextStyles.screenSubtitle.copyWith(fontSize: 16),
              ),
              _row(
                'Hedef durağa ulaşıldı mı',
                detection.isTargetStopReached ? 'evet' : 'hayır',
              ),
            ],
            _row('isBusApproaching', detection.isBusApproaching.toString()),
            _row('isBusVeryClose', detection.isBusVeryClose.toString()),
            _row('isTargetStopReached', detection.isTargetStopReached.toString()),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: AppTextStyles.screenSubtitle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
