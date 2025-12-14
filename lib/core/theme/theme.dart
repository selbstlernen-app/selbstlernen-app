import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/theme/text_theme.dart';

class CustomTheme {
  CustomTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppPalette.sky,
      secondary: AppPalette.skyLight,
      onSecondary: Colors.white,
      tertiary: const Color(0xffF5F5F5),
      onTertiary: const Color(0xffA1A1A1),
      onSurface: const Color(0xff1E1E1E), // Main text color
      error: const Color(0xffFF2056),
      tertiaryContainer: const Color(0xffE5E5E5),
    ),
    scaffoldBackgroundColor: const Color(0xffF5F5F5),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xffF5F5F5)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xffF5F5F5),
    ),
    textTheme: GoogleFonts.urbanistTextTheme(CustomTextTheme.customTextTheme),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppPalette.sky,
      secondary: AppPalette.skyLight,
      tertiary: const Color(0xffF5F5F5),
      onTertiary: const Color(0xffA1A1A1),
      error: const Color(0xffFF2056),
      tertiaryContainer: const Color(0xffE5E5E5),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF121212),
    ),
    textTheme: GoogleFonts.urbanistTextTheme(CustomTextTheme.customTextTheme),
  );
}
