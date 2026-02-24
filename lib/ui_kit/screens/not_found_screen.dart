import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../design_system/app_colors.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '404',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bu sayfa oluşturulmadı',
                style: TextStyle(color: AppColors.gray300, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                child: const Text('Ana Menü'),
                onPressed: () => debugPrint('Ana Menü (demo)'),
                semanticsLabel: 'Ana menüye dön',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

