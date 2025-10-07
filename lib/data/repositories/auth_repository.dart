import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService(); //Se realiza una inyeccion del servicio

  Future<AuthResponse> login(String username, String password) async {
    try {
      return await _authService.authenticate(username, password);
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
}
