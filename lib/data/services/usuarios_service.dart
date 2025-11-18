import 'package:dio/dio.dart';
import '../models/usuario.dart';

class UsuarioService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:50498/api/usuario',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Obtener todos los usuarios por estado
  Future<List<Usuario>> getUsuariosByEstado(int estado) async {
    try {
      final response = await _dio.get('/estado/$estado');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((u) => Usuario.fromJson(u)).toList();
      } else {
        throw Exception('Error al obtener los usuarios');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // Obtener usuario por ID
  Future<Usuario> getUsuarioById(int id) async {
    try {
      final response = await _dio.get('/$id');

      if (response.statusCode == 200) {
        return Usuario.fromJson(response.data);
      } else {
        throw Exception('Usuario no encontrado');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // Agregar usuario
  Future<void> addUsuario(Usuario usuario) async {
    try {
      final body = {
        'nombres': usuario.nombres,
        'apellidos': usuario.apellidos,
        'nombreUsuario': usuario.nombreUsuario,
        'contraseña': usuario.contrasena,
        'idRol': usuario.idRol,
      };

      final response = await _dio.post('', data: body);

      if (response.statusCode != 200) {
        throw Exception('Error al agregar usuario: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // Actualizar usuario
  Future<void> updateUsuario(int id, Usuario usuario) async {
    try {
      final response = await _dio.put(
        '/$id',
        data: usuario.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar usuario: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // Eliminar usuario (o cambiar estado)
  Future<void> deleteUsuario(int id, int estado) async {
    try {
      final response = await _dio.delete('/$id', queryParameters: {'estado': estado});

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar usuario: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }
}
