import 'ui/authentication/screens/categorias_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/core/themes/theme_provider.dart';
import 'ui/core/themes/light_theme.dart';
import 'ui/core/themes/dark_theme.dart';
// import 'ui/authentication/screens/home_page.dart';
import 'ui/core/routes/routes.dart';

final AppRouter appRouter = AppRouter();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'FarmaciaJoshua_demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.config(),
    );
  }
}