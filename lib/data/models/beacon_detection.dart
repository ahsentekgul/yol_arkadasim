enum BeaconType {
  bus286,
  targetStop,
  unknown,
}

class BeaconDetection {
  static const String projectUuid = 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0';

  static const int busApproachingThreshold = -75;
  static const int busVeryCloseThreshold = -60;
  static const int targetStopReachedThreshold = -65;

  final String uuid;
  final int major;
  final int minor;
  final int rssi;
  final double averageRssi;
  final int? txPower;
  final String? deviceName;
  final String? remoteId;
  final DateTime detectedAt;
  final BeaconType type;

  const BeaconDetection({
    required this.uuid,
    required this.major,
    required this.minor,
    required this.rssi,
    required this.averageRssi,
    this.txPower,
    this.deviceName,
    this.remoteId,
    required this.detectedAt,
    required this.type,
  });

  bool get isBus286 => type == BeaconType.bus286;

  bool get isTargetStop => type == BeaconType.targetStop;

  bool get isBusApproaching =>
      isBus286 && averageRssi >= busApproachingThreshold;

  bool get isBusVeryClose =>
      isBus286 && averageRssi >= busVeryCloseThreshold;

  bool get isTargetStopReached =>
      isTargetStop && averageRssi >= targetStopReachedThreshold;

  String get readableLabel {
    switch (type) {
      case BeaconType.bus286:
        return '286 otobüsü algılandı';
      case BeaconType.targetStop:
        return 'Hedef/iniş durağı algılandı';
      case BeaconType.unknown:
        return 'Bilinmeyen beacon';
    }
  }
}
