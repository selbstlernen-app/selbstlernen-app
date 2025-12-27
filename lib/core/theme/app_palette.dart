import 'package:flutter/material.dart';

class AppPalette {
  static Color skyLight = const Color(0xFF74D4FF);
  static Color sky = const Color(0xFF00BCFF);

  static Color blueLight = const Color(0xFF8EC5FF);
  static Color blue = const Color(0xFF51A2FF);

  static Color limeLight = const Color(0xFFBBF451);
  static Color lime = const Color(0xFF9AE600);

  static Color greenLight = const Color(0xFF7BF1A8);
  static Color green = const Color(0xFF05DF72);

  static Color emeraldLight = const Color(0xFF5EE9B5); // Emerald 300
  static Color emerald = const Color(0xFF00D492); // Emerald 400

  static const Color tealLight = Color(0xFF53EAFD);
  static const Color teal = Color(0xFF00D3F2);

  static const Color indigoLight = Color(0xFFA3B3FF);
  static const Color indigo = Color(0xFF7C86FF);

  static const Color purpleLight = Color(0xFFC4B4FF);
  static const Color purple = Color(0xFFA684FF);

  static const Color fuchsiaLight = Color(0xFFF4A8FF);
  static const Color fuchsia = Color(0xFFED6AFF);

  static const Color pinkLight = Color(0xFFFDA5D5); // Pink 300
  static const Color pink = Color(0xFFfb64b6); // Pink 400

  static const Color roseLight = Color(0xFFffa1ad);
  static const Color rose = Color(0xFFff637e);

  static Color redLight = const Color(0xFFFFA2A2);
  static Color red = const Color(0xFFFF6467);

  static const Color orangeLight = Color(0xFFffb86a);
  static const Color orange = Color(0xFFff8904);

  static const Color amberLight = Color(0xFFFFD230);
  static const Color amber = Color(0xFFFFB900);

  static const Color yellowLight = Color(0xFFFFDF20);
  static const Color yellow = Color(0xFFFDC700);

  static Color grey = Colors.grey[600]!;
  static Color darkGrey = Colors.grey[800]!;

  // List of all available theme colors in the settings
  static List<Color> themeColors = [
    sky,
    blue,
    green,
    lime,
    emerald,
    teal,
    indigo,
    purple,
    fuchsia,
    pink,
    rose,
    red,
  ];

  static Color getLightVariant(Color primary) {
    if (primary == sky) return skyLight;
    if (primary == blue) return blueLight;
    if (primary == emerald) return emeraldLight;
    if (primary == teal) return tealLight;
    if (primary == indigo) return indigoLight;
    if (primary == purple) return purpleLight;
    if (primary == fuchsia) return fuchsiaLight;
    if (primary == pink) return pinkLight;
    if (primary == rose) return roseLight;
    if (primary == red) return redLight;
    if (primary == amber) return amberLight;
    if (primary == yellow) return yellowLight;
    if (primary == orange) return orangeLight;
    if (primary == green) return greenLight;
    if (primary == lime) return limeLight;
    return skyLight;
  }
}
