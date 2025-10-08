import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import '../models/usuario.dart'; 

class UsuarioService {
  // URL base del backend .NET 
  static const String baseUrl = 'https://10.0.2.2:50498/api/usuario';

  // Obtener todos los usuarios por estado (1 = activos, 0 = inactivos, etc.)
  Future<List<Usuario>> getUsuariosByEstado(int estado) async {
    final response = await http.get(Uri.parse('$baseUrl/estado/$estado'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((u) => Usuario.fromJson(u)).toList();
    } else {
      throw Exception('Error al obtener los usuarios: ${response.statusCode}');
    }
  }

  // Obtener un usuario por su ID
  Future<Usuario> getUsuarioById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Usuario no encontrado');
    }
  }

  // Agregar un nuevo usuario
  Future<void> addUsuario(Usuario usuario) async {
    // Usamos el formato esperado por tu DTO (UsuarioDto)
    final body = jsonEncode({
      'nombres': usuario.nombres,
      'apellidos': usuario.apellidos,
      'nombreUsuario': usuario.nombreUsuario,
      'contraseña': usuario.contrasena,
      'idRol': usuario.idRol,
    });

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al agregar usuario: ${response.body}');
    }
  }

  // Actualizar un usuario existente
  Future<void> updateUsuario(int id, Usuario usuario) async {
    final body = jsonEncode(usuario.toJson());

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario: ${response.body}');
    }
  }

  // Eliminar (o desactivar) un usuario
  Future<void> deleteUsuario(int id, int estado) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id?estado=$estado'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar usuario: ${response.body}');
    }
  }
}
