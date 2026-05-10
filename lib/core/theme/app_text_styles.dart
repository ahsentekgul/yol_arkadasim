import 'package:flutter/material.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headerTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle screenTitle = TextStyle(
    color: Colors.white,
   fontSize: 30,
  fontWeight: FontWeight.w800,
  );

  static const TextStyle screenSubtitle = TextStyle(
    color:AppColors.subtitleTextColor,
    fontSize: 23,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static const TextStyle buttonLabel = TextStyle(
  color: Colors.white,
  fontSize: 32,
  fontWeight: FontWeight.w700,
);
}
