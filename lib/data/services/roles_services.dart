import 'package:dio/dio.dart';
import '../models/roles.dart';

// Servicio para manejar las operaciones CRUD de Roles
class RolesServices {
  // Instancia de Dio para las solicitudes HTTP
  final Dio _dio = Dio();
  // URL base de la API
  final String apiUrl = "http://192.168.1.221:5000/api/Rol";

  // Obtiene la lista de roles, filtrando por estado (1=activo, 0=inactivo)
  Future<List<Roles>> getRol({int estado = 1}) async {
    final response = await _dio.get("$apiUrl/estado/$estado");
    // Convierte la respuesta JSON en una lista de objetos de roles
    List data = response.data;
    return data.map((json) => Roles.fromJson(json)).toList();
  }

  // Obtiene Roles por su ID
  Future<Roles> getRolById(int id) async {
    final response = await _dio.get("$apiUrl/$id");
    return Roles.fromJson(response.data);
  }

  // Agrega una nueva Roles
  Future<void> addRol(Roles roles) async {
    await _dio.post(apiUrl, data: roles.toJson());
  }

  // Actualiza roles existente por su ID
  Future<void> updateRol(int id, Roles roles) async {
    await _dio.put("$apiUrl/$id", data: roles.toJson());
  }

  // Elimina (o desactiva) roles por su ID, cambiando su estado
  Future<void> deleteRol(int id, {int estado = 0}) async {
    // Cambia el estado de los Roles
    // Si estado=0, se desactiva; si estado=1, se reactiva
    await _dio.delete("$apiUrl/$id", queryParameters: {"estado": estado});
  }
}
