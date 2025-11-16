import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import 'package:aplicacion_movil_farmacia_joshua/core/utils/roles.dart';

class AuthRepository {
  final AuthService _authService = AuthService(); //Se realiza una inyeccion del servicio

  static const String _authTokenKey = 'auth_token';
  static const String _roleIdKey = 'role_id';
  static const String _userFirstNameKey = 'user_first_name';
  static const String _userLastNameKey = 'user_last_name';

  Future<AuthResponse> login(String username, String password) async {
    try {
      final authResponse = await _authService.authenticate(username, password);

      // Guardar token, rol y datos básicos del usuario en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, authResponse.token);
      await prefs.setInt(_roleIdKey, authResponse.idRol);
      await prefs.setString(_userFirstNameKey, authResponse.nombres);
      await prefs.setString(_userLastNameKey, authResponse.apellidos);

      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data?['message'] ?? 'Usuario o contraseña incorrectos';
        throw Exception(errorMessage);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Error de conexión. Por favor, intente nuevamente más tarde.',
        );
      } else if (e.response?.statusCode != null) {
        throw Exception(
          'Error en la respuesta del servidor: ${e.response?.statusCode}. Por favor, intente nuevamente más tarde.',
        );
      }

      throw Exception('Fallo en la conexion: ${e.message}');
    }catch (e) {
      throw Exception('Ocurrió un error inesperado durante el login.');
    }
  }

  Future<void> logout() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      await prefs.remove(_roleIdKey);
      await prefs.remove(_userFirstNameKey);
      await prefs.remove(_userLastNameKey);
    }catch(e){
      throw Exception('Error al limpiar la session local.');
    }
  }

  Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) ?? '';
  }

  Future<int> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_roleIdKey) ?? 0;
  }

  Future<Role> getCurrentRole() async {
    final id = await getRoleId();
    return roleFromId(id);
  }

  // Devuelve "PrimerNombre PrimerApellido" del usuario logueado.
  // Buenas prácticas aplicadas:
  // - Acceso único a SharedPreferences dentro del método.
  // - Limpieza de espacios (trim) y manejo de posibles valores vacíos.
  // - División por cualquier cantidad de espacios usando RegExp.
  // - Fallback seguro a "Usuario" si no hay datos.
  Future<String> getUserShortName() async {
    final prefs = await SharedPreferences.getInstance();
    final nombresRaw = (prefs.getString(_userFirstNameKey) ?? '').trim();
    final apellidosRaw = (prefs.getString(_userLastNameKey) ?? '').trim();

    // Obtiene el primer token (palabra) de nombres y apellidos si existen.
    String firstNombre = '';
    if (nombresRaw.isNotEmpty) {
      final partesNombre = nombresRaw.split(RegExp(r'\s+'));
      if (partesNombre.isNotEmpty) firstNombre = partesNombre.first;
    }

    String firstApellido = '';
    if (apellidosRaw.isNotEmpty) {
      final partesApellido = apellidosRaw.split(RegExp(r'\s+'));
      if (partesApellido.isNotEmpty) firstApellido = partesApellido.first;
    }

    final resultado = ('$firstNombre $firstApellido').trim();
    return resultado.isEmpty ? 'Usuario' : resultado;
  }
}
