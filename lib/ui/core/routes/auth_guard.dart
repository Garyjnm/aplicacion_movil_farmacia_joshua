import 'package:auto_route/auto_route.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/core/routes/routes.gr.dart';
import 'package:aplicacion_movil_farmacia_joshua/data/repositories/auth_repository.dart';

class AuthGuard extends AutoRouteGuard {
  AuthGuard(this.authRepository);
  final AuthRepository authRepository;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      final token = await authRepository.getAuthToken();
      final hasToken = token.isNotEmpty;

      if(hasToken){
        resolver.next(true);
      } else {
        router.replaceAll([const LoginRoute()]);
      }
    } catch (e) {
      router.replaceAll([const LoginRoute()]);
    }
  }
}
