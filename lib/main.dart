import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yol_arkadasim/business/home/home_screen.dart';
import 'package:yol_arkadasim/debug/temp_firestore_places_read_test.dart';
import 'package:yol_arkadasim/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Geçici: Firestore okuma testi — doğrulama sonrası silinecek.
  runTempFirestorePlacesReadTest();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
