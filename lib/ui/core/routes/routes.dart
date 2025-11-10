import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/home_page.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/login_screen.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/categorias_screen.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/core/layouts/main_layout.dart';
import 'package:auto_route/auto_route.dart';
import '../routes/routes.gr.dart';
import 'auth_guard.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|page|Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({required this.authGuard});
  final AuthGuard authGuard;

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, path: '/login'),

        AutoRoute(
          page: MainLayoutRoute.page,
          path: '/',
          guards: [authGuard],
          children: [
            AutoRoute(page: HomeRoute.page, path: 'home'),
            AutoRoute(page: CategoriasRoute.page, path: 'categorias'),
            RedirectRoute(path: '', redirectTo: 'home'),
          ],
        ),
      ];
 
}