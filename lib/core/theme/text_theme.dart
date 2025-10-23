import 'package:flutter/material.dart';

class CustomTextTheme {
  CustomTextTheme._();

  static TextTheme lightTextTheme = const TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),

    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
  );

  static TextTheme darkTextTheme = const TextTheme();
}
