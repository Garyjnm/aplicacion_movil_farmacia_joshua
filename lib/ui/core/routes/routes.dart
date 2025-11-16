import 'package:auto_route/auto_route.dart';
import '../routes/routes.gr.dart';
import 'auth_guard.dart';
import 'admin_guard.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|page|Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({required this.authGuard, required this.adminGuard});
  final AuthGuard authGuard;
  final AdminGuard adminGuard;

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, path: '/login'),

        AutoRoute(
          page: MainLayoutRoute.page,
          path: '/',
          guards: [authGuard],
          children: [
            AutoRoute(page: HomeRoute.page, path: 'home'),
            AutoRoute(
              page: CategoriasRoute.page,
              path: 'categorias',
              guards: [adminGuard],
            ),
            AutoRoute(
              page: UsuariosRoute.page,
              path: 'usuarios',
              guards: [adminGuard],
            ),
            AutoRoute(
              page: ProductosRoute.page,
              path: 'productos',
              guards: [adminGuard],
            ),
            AutoRoute(
              page: ClientesRoute.page,
              path: 'clientes',
            ),
            RedirectRoute(path: '', redirectTo: 'home'),
          ],
        ),
      ];
 
}