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
  );
  final TextEditingController _passwordController =
      TextEditingController(); 

  // Focus nodes y banderas para controlar cuándo mostrar errores (solo después de que el usuario toque y salga del campo)
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _usernameTouched = false;
  bool _passwordTouched = false;

  bool _obscurePassword = true;

  bool _isLoading = false;
  bool _isFormValid = false; 

  @override
  void initState() {
    super.initState();

    // Cuando el foco se pierde marcaremos el campo como "tocado" para mostrar errores
    _usernameFocus.addListener(() {
      if (!_usernameFocus.hasFocus) {
        setState(() {
          _usernameTouched = true;
        });
      }
    });

    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        setState(() {
          _passwordTouched = true;
        });
      }
    });

    // Escuchar cambios para actualizar el estado del botón inmediatamente
    _usernameController.addListener(_updateFormValidity);
    _passwordController.addListener(_updateFormValidity);
  }

  @override
  void dispose() {
    _usernameController
        .dispose(); 
    _passwordController
        .dispose(); 
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _updateFormValidity() {
    // Ahora solo requerimos que ambos campos no estén vacíos
    final valid = _usernameController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  void _login() async {
    final username =
        _usernameController.text; 
    final password =
        _passwordController.text; 
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
          true;
    });

    try {
      final authResponse = await _authRepository.login(username, password);
      if (!mounted) return;
      _showSuccessSnackBar('Bienvenido(a) ${authResponse.nombres}');
      context.router.replaceAll([const MainLayoutRoute()]);
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading =
              false;
        });
      }
    }
  }

  // --------------------- Snackbar helpers --------------------- //
  void _showSuccessSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.primaryContainer.withAlpha((0.95 * 255).round()),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary,
              radius: 16,
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ' $message',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.errorContainer.withAlpha((0.95 * 255).round()),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.error,
              radius: 16,
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error: $message',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onErrorContainer,
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

              // ------Formulario de login (validación mostrada solo tras tocar y salir del campo)---------
              Form(
                // Usamos AutovalidateMode.always pero los validators solo mostrarán
                // errores si el campo ha sido tocado (focus lost). Esto evita errores
                // inmediatos al entrar a la pantalla.
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      textInputAction: TextInputAction.next,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      validator: (value) {
                        if (!_usernameTouched) return null;
                        final String usernameValue = value?.trim() ?? '';
                        if (usernameValue.isEmpty) return 'Por favor ingrese su usuario';
                        return null;
                      },
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      decoration: InputDecoration(
                        labelText: 'Nombre de usuario',
                        hintText: 'Ingrese su nombre de usuario',
                        prefixIcon: Icon(Icons.person, color: colorScheme.onSurface),
                        errorStyle: TextStyle(color: colorScheme.error),
                        labelStyle: textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.secondaryContainer,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      validator: (value) {
                        if (!_passwordTouched) return null;
                        final String passwordValue = value ?? '';
                        if (passwordValue.isEmpty) return 'Por favor ingrese su contraseña';
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (_isFormValid && !_isLoading) _login();
                      },
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingrese su contraseña',
                        prefixIcon: Icon(Icons.lock, color: colorScheme.onSurface),
                        errorStyle: TextStyle(color: colorScheme.error),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        labelStyle: textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.secondaryContainer,
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
                  ],
                ),
              ),

              // ------Boton de login---------
              ElevatedButton(
                onPressed: (_isLoading || !_isFormValid) ? null : _login,
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
