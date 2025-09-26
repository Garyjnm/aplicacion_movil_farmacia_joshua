import 'package:flutter/material.dart';

final ColorScheme _lightColorScheme = const ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFE6F2F9),
  onPrimary: Color(0xFF1B194B),
  primaryContainer: Color(0xFFBED6E3),
  onPrimaryContainer: Color(0xFF1B194B),
  secondary: Color(0xFFA3BECD),
  onSecondary: Color(0xFF1B194B),
  secondaryContainer: Color(0xFF6D8D9F),
  onSecondaryContainer: Color(0xFFF4F4F4),
  tertiary: Color(0xFF4D0A0F),
  error: Color(0xFFE6F2F9),
  onError: Color(0xFF4D0A0F),
  surface: Color(0xFFF4F4F4),
  onSurface: Color(0xFF1B194B),
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: _lightColorScheme,
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
      backgroundColor: WidgetStatePropertyAll(
        _lightColorScheme.primaryContainer,
      ),
      foregroundColor: WidgetStatePropertyAll(
        _lightColorScheme.onPrimaryContainer,
      ),
      textStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 17), // <-- tamaño del texto
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: _lightColorScheme.onSurface),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _lightColorScheme.tertiary, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _lightColorScheme.onSurface),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _lightColorScheme.onError, width: 2),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Color(0xFF1B194B), // color del cursor
    selectionColor: _lightColorScheme.primary,
    selectionHandleColor: Color(0xFF1B194B) // “bolita” de selección
  ),
  cardTheme: CardThemeData(
      color: _lightColorScheme.surface,  // fondo por default de los Card
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
  ),
);
