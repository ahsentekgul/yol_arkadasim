import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Geçici doğrulama: Firestore `places` koleksiyonu okunabiliyor mu?
/// Firebase bağlantısı doğrulandıktan sonra bu dosya ve main.dart'taki çağrı silinecek.
Future<void> runTempFirestorePlacesReadTest() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('places').get();

    debugPrint(
      '[TEMP Firestore test] places belge sayisi: ${snapshot.docs.length}',
    );

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final name = data['name'] ?? data['placeName'] ?? '(name yok)';
      debugPrint('[TEMP Firestore test] ${doc.id}: $name');
    }
  } catch (e, st) {
    debugPrint('[TEMP Firestore test] HATA: $e');
    debugPrint('[TEMP Firestore test] $st');
  }
}
