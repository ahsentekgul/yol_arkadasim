import 'package:flutter/material.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/widgets/app_button.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

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
                onPressed: () => debugPrint('Ana Menü (demo)'),
                semanticsLabel: 'Ana menüye dön',
                child: const Text('Ana Menü'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
