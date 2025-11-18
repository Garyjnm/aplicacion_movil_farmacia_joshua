import 'package:aplicacion_movil_farmacia_joshua/data/services/metric_buffer.dart';
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
    final int start = DateTime.now().millisecondsSinceEpoch;

    try {
      final authResponse = await _authService.authenticate(username, password);

      // Guardar token, rol y datos básicos del usuario en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, authResponse.token);
      await prefs.setInt(_roleIdKey, authResponse.idRol);
      await prefs.setString(_userFirstNameKey, authResponse.nombres);
      await prefs.setString(_userLastNameKey, authResponse.apellidos);

      // Tiempo total
      final int duration = DateTime.now().millisecondsSinceEpoch - start;
       // Agregar métrica y log al buffer (no bloqueo)
      MetricBuffer().addMetric({
        "name": "login_time_ms",
        "value": duration,
        "tags": {
          "user": username,
          "endpoint": "/Auth",
          "result": "success"
        },
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric" // opcional para distinguir payloads en uploader
      });

      MetricBuffer().addMetric({
        "level": "info",
        "controller": "AuthController",
        "action": "Login",
        "user": username,
        "ip": "", // backend llenará ip real; cliente puede dejar vacío o poner device ip
        "request": {"username": username},
        "response": {"nombres": authResponse.nombres, "idRol": authResponse.idRol},
        "durationMs": duration,
        "timestamp": DateTime.now().toIso8601String(),
        "type": "log" // marca que es log estructurado
      });

      return authResponse;
    } on DioException catch (e) {
      final int duration = DateTime.now().millisecondsSinceEpoch - start;

      // Normalizar mensaje de error (como ya tenías)
      String errorMessage = 'Fallo en la conexion: ${e.message}';
      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data?['message'] ?? 'Usuario o contraseña incorrectos';
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Error de conexión. Por favor, intente nuevamente más tarde.';
      } else if (e.response?.statusCode != null) {
        errorMessage = 'Error en la respuesta del servidor: ${e.response?.statusCode}.';
      }

      // Métrica & log de fallo
      MetricBuffer().addMetric({
        "name": "login_time_ms",
        "value": duration,
        "tags": {
          "user": username,
          "endpoint": "/Auth",
          "result": "failure"
        },
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric"
      });

      MetricBuffer().addMetric({
        "level": "error",
        "controller": "AuthController",
        "action": "Login",
        "user": username,
        "ip": "",
        "request": {"username": username},
        "response": {"error": errorMessage},
        "durationMs": duration,
        "timestamp": DateTime.now().toIso8601String(),
        "stackTrace": e.stackTrace?.toString(),
        "type": "log"
      });

      // relanzar la excepción con el mensaje amigable
      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?['message'] ?? 'Usuario o contraseña incorrectos';
        throw Exception(errorMsg);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Error de conexión. Por favor, intente nuevamente más tarde.');
      } else if (e.response?.statusCode != null) {
        throw Exception('Error en la respuesta del servidor: ${e.response?.statusCode}. Por favor, intente nuevamente más tarde.');
      }

      throw Exception('Fallo en la conexion: ${e.message}');
    } catch (e, st) {
      final int duration = DateTime.now().millisecondsSinceEpoch - start;

      MetricBuffer().addMetric({
        "name": "login_time_ms",
        "value": duration,
        "tags": {
          "user": username,
          "endpoint": "/Auth",
          "result": "error"
        },
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric"
      });

      MetricBuffer().addMetric({
        "level": "error",
        "controller": "AuthController",
        "action": "Login",
        "user": username,
        "ip": "",
        "request": {"username": username},
        "response": {"error": e.toString()},
        "durationMs": duration,
        "timestamp": DateTime.now().toIso8601String(),
        "stackTrace": st.toString(),
        "type": "log"
      });

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

  Future<String> getUserShortName() async {
    final prefs = await SharedPreferences.getInstance();
    final nombresRaw = (prefs.getString(_userFirstNameKey) ?? '').trim();
    final apellidosRaw = (prefs.getString(_userLastNameKey) ?? '').trim();

    // Obtiene el primer token (palabra) de nombres y apellidos si existen.
    String firstName = '';
    if (nombresRaw.isNotEmpty) {
      final name = nombresRaw.split(RegExp(r'\s+'));
      if (name.isNotEmpty) firstName = name.first;
    }

    String firstLastName = '';
    if (apellidosRaw.isNotEmpty) {
      final lastName = apellidosRaw.split(RegExp(r'\s+'));
      if (lastName.isNotEmpty) firstLastName = lastName.first;
    }

    final resultado = ('$firstName $firstLastName').trim();
    return resultado.isEmpty ? 'Usuario' : resultado;
  }
}
