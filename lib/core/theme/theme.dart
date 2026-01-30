import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/theme/text_theme.dart';

class CustomTheme {
  CustomTheme._();

  static ThemeData lightTheme({required Color primaryColor}) {
    final secondaryColor = AppPalette.getLightVariant(primaryColor);

    /// Returns the dark theme with no surface tint enabled
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: const Color(0xffF5F5F5),
        onTertiary: const Color(0xffA1A1A1),
        onSurface: const Color(0xff1E1E1E),
        error: const Color(0xffFF2056),
        tertiaryContainer: const Color(0xffE5E5E5),
      ),
      scaffoldBackgroundColor: const Color(0xffF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xffF5F5F5),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: const CardThemeData(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        color: Colors.white,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.white,
      ),
      dialogTheme: const DialogThemeData(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xffF5F5F5),
      ),
      textTheme: GoogleFonts.urbanistTextTheme(
        CustomTextTheme.customTextTheme,
      ),
    );
  }

  /// Returns the dark theme
  static ThemeData darkTheme({required Color primaryColor}) {
    final secondaryColor = AppPalette.getLightVariant(primaryColor);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: const Color(0xff2A2A2A),
        onTertiary: const Color(0xffA1A1A1),
        onSurface: const Color(0xffE5E5E5),
        error: const Color(0xffFF2056),
        tertiaryContainer: const Color(0xff3A3A3A),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
      ),
      textTheme: GoogleFonts.urbanistTextTheme(
        CustomTextTheme.customTextTheme,
      ),
    );
  }
}
