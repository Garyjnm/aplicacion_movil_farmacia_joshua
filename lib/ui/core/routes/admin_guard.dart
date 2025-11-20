import 'package:auto_route/auto_route.dart';
import 'package:aplicacion_movil_farmacia_joshua/data/models/role.dart';
import 'package:aplicacion_movil_farmacia_joshua/data/repositories/auth_repository.dart';
import 'routes.gr.dart';

class AdminGuard extends AutoRouteGuard {
  AdminGuard(this.authRepository);
  final AuthRepository authRepository;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      final role = await authRepository.getCurrentRole();
      if (role.isAdmin) {
        resolver.next(true);
      } else {
        router.replace(const HomeRoute());
      }
    } catch (_) {
      router.replaceAll([const LoginRoute()]);
    }
  }
}
