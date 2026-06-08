import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yol_arkadasim/business/home/home_screen.dart';
import 'package:yol_arkadasim/debug/beacon_debug_screen.dart';
import 'package:yol_arkadasim/firebase_options.dart';

/// Geçici beacon debug girişi. Test bitince `false` yapın.
const bool showBeaconDebugOnStart = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: showBeaconDebugOnStart
          ? const BeaconDebugScreen()
          : const HomeScreen(),
    );
  }
}
