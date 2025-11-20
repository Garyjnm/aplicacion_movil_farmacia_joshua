import 'package:flutter/material.dart';

final ColorScheme _darkColorScheme = const ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF040325),
  onPrimary: Color(0xFFE6F2F9),
  primaryContainer: Color(0xFF1B194B),
  onPrimaryContainer: Colors.white,
  secondary: Color(0xFFA3BECD),
  onSecondary: Color(0xFF1B194B),
  // Color de error para modo oscuro (visibilidad en fondos oscuros)
  error: Color(0xFFB00020),
  onError: Color(0xFFFFFFFF),
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
      backgroundColor: WidgetStatePropertyAll(
        _darkColorScheme.primaryContainer,
      ),
      foregroundColor: WidgetStatePropertyAll(
        _darkColorScheme.onPrimaryContainer,
      ),
      textStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 17), // <-- tamaño del texto
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: _darkColorScheme.onSurface),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _darkColorScheme.tertiary, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _darkColorScheme.onSurface),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _darkColorScheme.onError, width: 2),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Color(0xFFFFFFFF), // color del cursor
    selectionColor: Color(0xFF1B194B),
    selectionHandleColor: _darkColorScheme.secondary, // “bolita” de selección
  ),
  cardTheme: CardThemeData(
    color: _darkColorScheme.primary, // fondo por default de los Card
    elevation: 4,
    // shadowColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
