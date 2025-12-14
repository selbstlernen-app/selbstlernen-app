import 'package:flutter/material.dart';

class CustomTextTheme {
  CustomTextTheme._();

  static TextTheme customTextTheme = const TextTheme(
    // Used for any large display texts like on appBars
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),

    // Used for any text not headline
    bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),

    // Used for buttons and textfield labels
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );
}
