import 'package:dio/dio.dart';
import '../models/auth_response.dart';

class AuthService {
  // Use the deployed Azure API as the base URL
  // Note: ensure the trailing '/api' matches your server routing (Keystone: the swagger URL uses '/swagger', API root usually '/api')
  final String baseUrl = 'http://10.0.2.2:50498/api';
  final Dio _dio = Dio(); // Instancia de Dio para realizar las solicitudes HTTP

  AuthService() { // Constructor para inicializar la configuración de Dio
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5), // Tiempo de espera para la conexión
      receiveTimeout: const Duration(seconds: 15), // Tiempo de espera para recibir datos
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  Future<AuthResponse> authenticate(String username, String password) async { // Método para autenticar al usuario
    const String endpoint = '/Auth'; // Endpoint de autenticación

    final Map<String, String> data = { // Datos a enviar en la solicitud
      'NombreUsuario': username,
      'Contraseña': password,
    };

    try {
      final response = await _dio.post( // Realiza la solicitud POST
        endpoint,
        data: data,
      );

      return AuthResponse.fromJson(response.data);
    }on DioException{
      rethrow;
    }
  }
}