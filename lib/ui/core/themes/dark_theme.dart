import 'package:flutter/material.dart';

final ColorScheme _darkColorScheme = const ColorScheme(
  brightness: Brightness.dark, 
  primary: Color(0xFF040325), 
  onPrimary: Color(0xFFE6F2F9), 
  primaryContainer: Color(0xFF1B194B),
  onPrimaryContainer: Colors.white,
  secondary: Color(0xFFA3BECD), 
  onSecondary: Color(0xFF1B194B), 
  error: Color(0xFFE6F2F9), 
  onError: Color(0xFF4D0A0F), 
  surface: Color.fromARGB(255, 0, 0, 0), 
  onSurface: Colors.white,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: _darkColorScheme,
  fontFamily: "Segoe UI",
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 24),
    titleMedium: TextStyle(fontSize: 22),
    titleSmall: TextStyle(fontSize: 20),
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    bodySmall: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontSize: 12),
    labelMedium: TextStyle(fontSize: 11),
    labelSmall: TextStyle(fontSize: 10),
  ),
  useMaterial3: true,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(_darkColorScheme.primaryContainer),
      foregroundColor: WidgetStatePropertyAll(_darkColorScheme.onPrimaryContainer),
        textStyle: WidgetStatePropertyAll(
      const TextStyle(fontSize: 17), // <-- tamaño del texto
    ),
    ),
  ),
);

