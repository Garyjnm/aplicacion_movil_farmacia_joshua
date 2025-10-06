import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Provider que guarda el estado del modo de tema
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// Función que devuelve el ThemeData correcto
ThemeData getThemeData(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
      return darkTheme;
    case ThemeMode.light:
      return lightTheme;
    default:
      return lightTheme;
  }
}
