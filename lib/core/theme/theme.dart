import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/theme/text_theme.dart';

class CustomTheme {
  CustomTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Urbanist",
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Colors.lightBlueAccent, //Color(0xff00BCFF)
      onPrimary: Colors.white,
      secondary: Colors.lightBlue[100]!, //Color(0xff74d4ff),
      onSecondary: Colors.white, // Texts/Icons on secondary
      tertiary: const Color(0xffF5F5F5), // grey used for inputs etc
      onTertiary: const Color(0xffA1A1A1),
      surface: Colors.white,
      onSurface: const Color(0xff1E1E1E), // Main text color
      error: const Color(0xffFF2056),
      onError: Colors.white,
      tertiaryContainer: const Color(0xffE5E5E5),
    ),
    // Background of all general items in off-white (#FAFAFA)
    scaffoldBackgroundColor: const Color(0xffFAFAFA),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xffFAFAFA)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xffFAFAFA),
    ),

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
