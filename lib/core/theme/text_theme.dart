import 'package:flutter/material.dart';

class CustomTextTheme {
  CustomTextTheme._();

  static TextTheme lightTextTheme = const TextTheme(
    // Used for any large display texts like on appBars
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),

    // Used for any text not headline
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),

    // Used for buttons and textfield labels
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );

  static TextTheme darkTextTheme = const TextTheme();
}
