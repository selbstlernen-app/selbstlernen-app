import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/theme/text_theme.dart';

class CustomTheme {
  CustomTheme._();

  static ThemeData getTheme({
    required bool isDark,
    required Color primaryColor,
  }) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final secondaryColor = AppPalette.getLightVariant(primaryColor);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: isDark ? const Color(0xff2A2A2A) : const Color(0xffF5F5F5),
        onTertiary: const Color(0xffA1A1A1),
        // TODO: fix issue with this not applying correctly
        surfaceTint: isDark ? null : Colors.transparent,
        onSurface: isDark ? const Color(0xffE5E5E5) : const Color(0xff1E1E1E),
        error: const Color(0xffFF2056),
        tertiaryContainer: isDark
            ? const Color(0xff3A3A3A)
            : const Color(0xffE5E5E5),
      ),
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xffF5F5F5),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xffF5F5F5),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xffF5F5F5),
      ),
      textTheme: GoogleFonts.urbanistTextTheme(
        CustomTextTheme.customTextTheme,
      ),
    );
  }

  // Helper to adjust color brightness
  static Color _adjustColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final adjusted = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return adjusted.toColor();
  }
}
