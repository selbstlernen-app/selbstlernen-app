import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/text_theme.dart';

class CustomTheme {
  CustomTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Urbanist",
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xff00BCFF),
      onPrimary: Colors.white,
      secondary: Color(0xff74d4ff),
      onSecondary: Colors.white, // Texts/Icons on secondary
      tertiary: Color(0xffF5F5F5), // grey used for inputs etc
      onTertiary: Color(0xffA1A1A1),
      surface: Color(0xffFAFAFA),
      onSurface: Color(0xff1E1E1E), // Main text color
      error: Color(0xffFF2056),
      onError: Colors.white,
      tertiaryContainer: Color(0xffE5E5E5),
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: CustomTextTheme.lightTextTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Urbanist",
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: CustomTextTheme.darkTextTheme,
  );
}
