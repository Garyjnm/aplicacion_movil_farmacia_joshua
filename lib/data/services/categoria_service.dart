import 'package:dio/dio.dart';
import '../models/categoria.dart';

// Servicio para manejar las operaciones CRUD de Categoría
class CategoriaService {
  // Instancia de Dio para las solicitudes HTTP
  final Dio _dio = Dio();
  // URL base de la API
  final String apiUrl = "http://10.0.2.2:50498/api/categoria";

  // Obtiene la lista de categorías, filtrando por estado (1=activo, 0=inactivo)
  Future<List<Categoria>> getCategorias({int estado = 1}) async {
    final response = await _dio.get("$apiUrl/estado/$estado");
   // Convierte la respuesta JSON en una lista de objetos Categoria
    List data = response.data;
    return data.map((json) => Categoria.fromJson(json)).toList();
  }

  // Obtiene una categoría por su ID
  Future<Categoria> getCategoriaById(int id) async {
    final response = await _dio.get("$apiUrl/$id");
    return Categoria.fromJson(response.data);
  }

  // Agrega una nueva categoría
  Future<void> addCategoria(Categoria categoria) async {
    await _dio.post(apiUrl, data: categoria.toJson());
  }

  // Actualiza una categoría existente por su ID
  Future<void> updateCategoria(int id, Categoria categoria) async {
    await _dio.put("$apiUrl/$id", data: categoria.toJson());
  }

  // Elimina (o desactiva) una categoría por su ID, cambiando su estado
  Future<void> deleteCategoria(int id, {int estado = 0}) async {
    // Cambia el estado de la categoría
    // Si estado=0, se desactiva; si estado=1, se reactiva
    await _dio.delete("$apiUrl/$id", queryParameters: {"estado": estado});
  }
}
