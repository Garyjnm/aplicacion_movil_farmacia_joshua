import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/home_page.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/login_screen.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/categorias_screen.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/roles_screen.dart';
import 'package:auto_route/auto_route.dart';
import '../routes/routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|page|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, path: LoginScreen.routeName),
    AutoRoute(page: HomeRoute.page, path: HomePage.routeName, initial: true),
    AutoRoute(page: CategoriasRoute.page, path: CategoriasScreen.routeName),
    AutoRoute(page: RolesRoute.page, path: RolesScreen.routeName),
  ];
}
