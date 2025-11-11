import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/home_page.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/login_screen.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/categorias_screen.dart';
import 'package:auto_route/auto_route.dart';
import '../routes/routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|page|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, path: LoginScreen.routeName, initial: true),
        AutoRoute(page: HomeRoute.page, path: HomePage.routeName),
        AutoRoute(page: CategoriasRoute.page, path: CategoriasScreen.routeName),
        
      ];
 
}