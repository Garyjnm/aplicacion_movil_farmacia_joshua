import 'package:aplicacion_movil_farmacia_joshua/data/services/metric_buffer.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import 'package:aplicacion_movil_farmacia_joshua/data/models/role.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  static const String _authTokenKey = 'auth_token';
  static const String _roleIdKey = 'role_id';
  static const String _userFirstNameKey = 'user_first_name';
  static const String _userLastNameKey = 'user_last_name';

  Future<AuthResponse> login(String username, String password) async {
    final int start = DateTime.now().millisecondsSinceEpoch;

    try {
      final authResponse = await _authService.authenticate(username, password);

      // Guardar datos del usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, authResponse.token);
      await prefs.setInt(_roleIdKey, authResponse.idRol);
      await prefs.setString(_userFirstNameKey, authResponse.nombres);
      await prefs.setString(_userLastNameKey, authResponse.apellidos);

      // Métrica de éxito
      final int duration = DateTime.now().millisecondsSinceEpoch - start;
      MetricBuffer().addMetric({
        "name": "login_time_ms",
        "value": duration,
        "tags": {
          "user": username,
          "result": "success",
        },
        "timestamp": DateTime.now().toUtc().toIso8601String(),
        "type": "metric"
      });

      return authResponse;
    } on DioException catch (e) {
      final int duration = DateTime.now().millisecondsSinceEpoch - start;

      String errorMessage = 'Fallo en la conexión: ${e.message}';
      String resultTag = 'failure';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Error de conexión. Intente nuevamente.';
        resultTag = 'network_error';
      } else if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data?['message'] ?? 'Usuario o contraseña incorrectos';
        resultTag = 'failure';
      } else if (e.response?.statusCode != null) {
        errorMessage = 'Error del servidor: ${e.response?.statusCode}.';
        resultTag = 'server_error';
      }

      // Métrica de fallo
      MetricBuffer().addMetric({
        "name": "login_time_ms",
        "value": duration,
        "tags": {
          "user": username,
          "result": resultTag,
        },
        "timestamp": DateTime.now().toUtc().toIso8601String(),
        "type": "metric"
      });

      // Propagar un mensaje amigable
      throw Exception(errorMessage);
    } catch (e) {
      final int duration = DateTime.now().millisecondsSinceEpoch - start;

      // Métrica de error inesperado
      MetricBuffer().addMetric({
        "name": "login_time_ms",
        "value": duration,
        "tags": {
          "user": username,
          "result": "error",
        },
        "timestamp": DateTime.now().toUtc().toIso8601String(),
        "type": "metric"
      });

      throw Exception('Ocurrió un error inesperado durante el login.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_roleIdKey);
    await prefs.remove(_userFirstNameKey);
    await prefs.remove(_userLastNameKey);
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

    String firstName = '';
    if (nombresRaw.isNotEmpty) {
      final parts = nombresRaw.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) firstName = parts.first;
    }

    String firstLastName = '';
    if (apellidosRaw.isNotEmpty) {
      final parts = apellidosRaw.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) firstLastName = parts.first;
    }

    final result = ('$firstName $firstLastName').trim();
    return result.isEmpty ? 'Usuario' : result;
  }
}