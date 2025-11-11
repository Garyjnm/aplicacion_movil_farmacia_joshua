import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/core/routes/routes.gr.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepository =
      AuthRepository(); //inicializamos el repositorio, la capa que vamos a usar

  final TextEditingController _usernameController = TextEditingController(
    text: '',
  ); //este controlador nos permite obtener el texto del campo de usuario
  final TextEditingController _passwordController =
      TextEditingController(); //este controlador nos permite obtener el texto del campo de contraseña

  bool _isLoading = false; //nuevo estado para controlar la animación del botón

  @override
  void dispose() {
    _usernameController
        .dispose(); //liberamos los recursos del controlador cuando ya no se necesita
    _passwordController
        .dispose(); //liberamos los recursos del controlador cuando ya no se necesita
    super.dispose();
  }

  void _login() async {
    final username =
        _usernameController.text; //obtenemos el texto del campo de usuario
    final password =
        _passwordController.text; //obtenemos el texto del campo de contraseña

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese usuario y contraseña'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading =
          true; //iniciamos el estado de carga y deshabilitamos el botón
    });

    try {
      final authResponse = await _authRepository.login(username, password);
      if (!mounted) return;
      _showSuccessSnackBar('Bienvenido(a) ${authResponse.nombres}');
      context.router.replaceAll([const MainLayoutRoute()]);
    } catch (e) {
      if (!mounted) {
        return; //verificamos que el widget aún esté en el árbol de widgets
      }
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading =
              false; //finalizamos el estado de carga y habilitamos el botón
        });
      }
    }
  }

  // --------------------- Snackbar helpers --------------------- //
  void _showSuccessSnackBar(String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  backgroundColor: cs.primaryContainer.withAlpha((0.95 * 255).round()),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primary,
              radius: 16,
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Login exitoso. $message',
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  backgroundColor: cs.errorContainer.withAlpha((0.95 * 255).round()),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.error,
              radius: 16,
              child: const Icon(Icons.error_outline, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error: $message',
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos el resizeToAvoidBottomInset: true por defecto, pero con SingleChildScrollView es más robusto
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          // Permite que el contenido sea desplazable cuando el teclado está visible
          padding: EdgeInsets.fromLTRB(
            24,
            50,
            24,
            24 + bottomInset,
          ), // Añadimos padding inferior para evitar que el teclado cubra el contenido

          child: Column(
            // Columna para organizar los elementos verticalmente
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // Estira los hijos para que ocupen todo el ancho disponible
            children: [
              // ----------Logo de la farmacia---------
              Image.asset(
                'assets/images/farmacia joshua logo definitivo.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // ------Apartado de Usuario---------
              TextField(
                controller:
                    _usernameController, //asociamos el controlador al campo de texto
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface, //color del texto según el tema
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  hintText: 'Ingrese su nombre de usuario',
                  prefixIcon: Icon(Icons.person, color: colorScheme.onSurface),
                  labelStyle: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), //borde redondeado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme
                          .secondaryContainer, //color del borde según el tema
                      width: 2, //grosor del borde
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ------Apartado de Contraseña---------
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface, //color del texto según el tema
                ),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingrese su contraseña',
                  prefixIcon: Icon(Icons.lock, color: colorScheme.onSurface),
                  labelStyle: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme
                          .secondaryContainer, //color del borde según el tema
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 10,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ------Boton de login---------
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme
                      .secondaryContainer, //color del botón según el tema
                  foregroundColor: colorScheme
                      .onSecondaryContainer, //color del texto según el tema
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        'Ingresar',
                        style: textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // ------Link de olvido contraseña---------
              TextButton(
                onPressed: () {},
                child: Text(
                  '¿Olvidó su contraseña?',
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.secondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
