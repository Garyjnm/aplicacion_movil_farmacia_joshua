import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final AuthRepository _authRepository = AuthRepository(); //inicializamos el repositorio, la capa que vamos a usar

  final TextEditingController _usernameController = TextEditingController(text: '',); //este controlador nos permite obtener el texto del campo de usuario
  final TextEditingController _passwordController = TextEditingController(); //este controlador nos permite obtener el texto del campo de contraseña

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
    final username = _usernameController.text; //obtenemos el texto del campo de usuario
    final password = _passwordController.text; //obtenemos el texto del campo de contraseña

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor ingrese usuario y contraseña',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; //iniciamos el estado de carga y deshabilitamos el botón
    });

    try{
      final authResponse = await _authRepository.login(username, password);

      if (!mounted) return; //verificamos que el widget aún esté en el árbol de widgets

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Login exitoso. Bienvenido(a) ${authResponse.nombres}!'),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 3),
        ),
      );
      
    }catch(e){
      if (!mounted) return; //verificamos que el widget aún esté en el árbol de widgets

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
    }finally{
      if (mounted) { 
        setState(() {
          _isLoading = false; //finalizamos el estado de carga y habilitamos el botón
        });
      } 
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //color de fondo de la pantalla
      body: SafeArea( //evita que el contenido se superponga con la barra de estado o la barra de navegación
        child: Padding( 
          padding: const EdgeInsets.symmetric(horizontal: 24),//padding horizontal de 24
          child: Column( //columna para organizar los elementos verticalmente
            mainAxisAlignment: MainAxisAlignment.center, //centrar los elementos verticalmente
            crossAxisAlignment: CrossAxisAlignment.stretch, //estirar los elementos horizontalmente
            children: [
              Image.asset( //Propiedad para cargar una imagen desde los assets
                'assets/images/farmacia joshua logo definitivo.png',
                width: 250, //ancho de la imagen
                height: 250, //alto de la imagen
                fit: BoxFit.contain, //ajustar la imagen dentro del contenedor sin recortarla
              ),
              const SizedBox(height: 40),//espacio entre la imagen y el campo de usuario

              // ------Apartado de Usuario---------
              TextField(
                controller: _usernameController, //asociamos el controlador al campo de usuario
                decoration: InputDecoration( //decoracion del campo de usuario
                  labelText: 'Nombre de usuario', //etiqueta del campo de usuario
                  hintText: 'Ingrese su nombre de usuario', //texto de sugerencia dentro del campo de usuario
                  prefixIcon: const Icon(Icons.person), //icono al inicio del campo de usuario
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), //redondeo de los bordes del campo de usuario
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),//padding vertical dentro del campo de usuario
                ),
              ),
              const SizedBox(height: 16),//espacio entre el campo de usuario y el campo de contraseña

              // ------Apartado de Contraseña---------
              TextField(
                controller: _passwordController, //asociamos el controlador al campo de contraseña
                obscureText: true, //oculta el texto ingresado en el campo de contraseña
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingrese su contraseña',
                  prefixIcon: const Icon(Icons.lock), //icono al inicio del campo de contraseña
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), //redondeo de los bordes del campo de contraseña
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16), //padding vertical dentro del campo de contraseña
                ),
              ),
              const SizedBox(height: 24),//espacio entre el campo de contraseña y el botón login

              // ------Boton de login---------
              ElevatedButton(
                onPressed: _isLoading ? null :_login, //llama a la función _login cuando se presiona el botón
                style: ElevatedButton.styleFrom( //estilo del botón
                  backgroundColor: Colors.teal, //color de prueba del fondo del botón de
                  foregroundColor: Colors.white, //color de prueba del texto del botón
                  padding: const EdgeInsets.symmetric(vertical: 16), //padding vertical dentro del botón
                  shape: RoundedRectangleBorder(//forma del botón
                    borderRadius: BorderRadius.circular(8), //redondeo de los bordes del botón
                  ),
                  elevation: 2,//sombra del botón
                ),
                child: _isLoading
                    // Mostrar CircularProgressIndicator mientras carga
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text( 
                        'Ingresar', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
               ), 
               const SizedBox(height: 16),

              // ------Link de olvido contraseña (de momento no estara funcional)---------
              TextButton(
                onPressed: () {},
                child: const Text(
                  '¿Olvidó su contraseña?',
                  style: TextStyle(color: Colors.teal, fontSize: 14), //estilo del texto del link de prueba
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
