import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yol_arkadasim/data/models/beacon_detection.dart';

class _ParsedIBeacon {
  final String uuid;
  final int major;
  final int minor;
  final int txPower;

  const _ParsedIBeacon({
    required this.uuid,
    required this.major,
    required this.minor,
    required this.txPower,
  });
}

class BeaconScannerService {
  static const int _appleCompanyId = 0x004C;
  static const int _iBeaconType = 0x02;
  static const int _iBeaconLength = 0x15;

  final StreamController<List<BeaconDetection>> _detectionsController =
      StreamController<List<BeaconDetection>>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  final Map<String, List<int>> _rssiHistory = {};
  final Map<String, BeaconDetection> _activeDetections = {};

  bool _scanning = false;

  Stream<List<BeaconDetection>> get detectionsStream =>
      _detectionsController.stream;

  bool get isScanning => _scanning;

  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      const permissions = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ];

      for (final permission in permissions) {
        final status = await permission.status;
        if (status.isGranted) {
          continue;
        }

        final result = await permission.request();
        if (!result.isGranted) {
          debugPrint(
            'BeaconScannerService: permission denied: $permission',
          );
          return false;
        }
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('BeaconScannerService: permission error: $e');
      debugPrint('$stackTrace');
      return false;
    }
  }

  Future<void> startScan() async {
    if (_scanning) {
      debugPrint('BeaconScannerService: scan already in progress');
      return;
    }

    final hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      debugPrint('BeaconScannerService: permissions not granted');
      return;
    }

    try {
      var adapterState = FlutterBluePlus.adapterStateNow;
      if (adapterState == BluetoothAdapterState.unknown) {
        adapterState = await FlutterBluePlus.adapterState.firstWhere(
          (state) => state != BluetoothAdapterState.unknown,
        );
      }

      if (adapterState != BluetoothAdapterState.on) {
        debugPrint(
          'BeaconScannerService: Bluetooth adapter is off ($adapterState)',
        );
        return;
      }

      _scanResultsSubscription ??=
          FlutterBluePlus.onScanResults.listen(
        _handleScanResults,
        onError: (Object error) {
          debugPrint('BeaconScannerService: scan stream error: $error');
        },
      );

      await FlutterBluePlus.startScan(
        androidUsesFineLocation: true,
        continuousUpdates: true,
      );

      _scanning = true;
      debugPrint('BeaconScannerService: scan started');
    } catch (e, stackTrace) {
      _scanning = false;
      debugPrint('BeaconScannerService: startScan error: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> stopScan() async {
    if (!_scanning && !FlutterBluePlus.isScanningNow) {
      return;
    }

    try {
      await FlutterBluePlus.stopScan();
    } catch (e, stackTrace) {
      debugPrint('BeaconScannerService: stopScan error: $e');
      debugPrint('$stackTrace');
    } finally {
      _scanning = false;
      debugPrint('BeaconScannerService: scan stopped');
    }
  }

  void dispose() {
    unawaited(stopScan());
    _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
    _detectionsController.close();
    _rssiHistory.clear();
    _activeDetections.clear();
  }

  void _handleScanResults(List<ScanResult> results) {
    try {
      var updated = false;

      for (final result in results) {
        final parsed = _parseIBeacon(result.advertisementData.manufacturerData);
        if (parsed == null) {
          continue;
        }

        if (parsed.uuid != BeaconDetection.projectUuid) {
          continue;
        }

        final key = _beaconKey(parsed.uuid, parsed.major, parsed.minor);
        _updateRssiHistory(key, result.rssi);

        final averageRssi = _calculateAverageRssi(_rssiHistory[key] ?? []);
        final type = _resolveBeaconType(parsed.major, parsed.minor);
        final detection = BeaconDetection(
          uuid: parsed.uuid,
          major: parsed.major,
          minor: parsed.minor,
          rssi: result.rssi,
          averageRssi: averageRssi,
          txPower: parsed.txPower,
          deviceName: _nonEmpty(result.advertisementData.advName),
          remoteId: result.device.remoteId.str,
          detectedAt: DateTime.now(),
          type: type,
        );

        _activeDetections[key] = detection;
        updated = true;

        debugPrint(
          'BeaconScannerService: uuid=${detection.uuid} '
          'major=${detection.major} minor=${detection.minor} '
          'rssi=${detection.rssi} averageRssi=${detection.averageRssi} '
          'type=${detection.type}',
        );
      }

      if (updated) {
        _emitDetections();
      }
    } catch (e, stackTrace) {
      debugPrint('BeaconScannerService: handleScanResults error: $e');
      debugPrint('$stackTrace');
    }
  }

  void _emitDetections() {
    if (_detectionsController.isClosed) {
      return;
    }

    final detections = _activeDetections.values.toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

    _detectionsController.add(detections);
  }

  _ParsedIBeacon? _parseIBeacon(Map<int, List<int>> manufacturerData) {
    for (final entry in manufacturerData.entries) {
      final parsed = _parseIBeaconPayload(entry.key, entry.value);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  _ParsedIBeacon? _parseIBeaconPayload(int manufacturerId, List<int> data) {
    if (manufacturerId == _appleCompanyId) {
      final parsed = _tryParseIBeaconBytes(data, includeCompanyId: false);
      if (parsed != null) {
        return parsed;
      }
    }

    if (data.length >= 2 &&
        data[0] == (_appleCompanyId & 0xFF) &&
        data[1] == ((_appleCompanyId >> 8) & 0xFF)) {
      return _tryParseIBeaconBytes(data, includeCompanyId: true);
    }

    return null;
  }

  _ParsedIBeacon? _tryParseIBeaconBytes(
    List<int> bytes, {
    required bool includeCompanyId,
  }) {
    final offset = includeCompanyId ? 2 : 0;
    if (bytes.length < offset + 23) {
      return null;
    }

    if (bytes[offset] != _iBeaconType || bytes[offset + 1] != _iBeaconLength) {
      return null;
    }

    final uuidBytes = bytes.sublist(offset + 2, offset + 18);
    final major = (bytes[offset + 18] << 8) | bytes[offset + 19];
    final minor = (bytes[offset + 20] << 8) | bytes[offset + 21];
    final txPower = _signedByte(bytes[offset + 22]);

    return _ParsedIBeacon(
      uuid: _formatUuid(uuidBytes),
      major: major,
      minor: minor,
      txPower: txPower,
    );
  }

  String _formatUuid(List<int> bytes) {
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  int _signedByte(int value) => value >= 128 ? value - 256 : value;

  String _beaconKey(String uuid, int major, int minor) =>
      '$uuid-$major-$minor';

  void _updateRssiHistory(String key, int rssi) {
    final history = _rssiHistory.putIfAbsent(key, () => []);
    history.add(rssi);
    if (history.length > 3) {
      history.removeAt(0);
    }
  }

  double _calculateAverageRssi(List<int> values) {
    if (values.isEmpty) {
      return 0;
    }

    final sum = values.fold<int>(0, (total, value) => total + value);
    return sum / values.length;
  }

  BeaconType _resolveBeaconType(int major, int minor) {
    if (major == 1 && minor == 286) {
      return BeaconType.bus286;
    }
    if (major == 2 && minor == 1) {
      return BeaconType.targetStop;
    }
    return BeaconType.unknown;
  }

  String? _nonEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
