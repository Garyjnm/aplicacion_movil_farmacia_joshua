import 'package:dio/dio.dart';
import '../models/categoria.dart';

/// Servicio para manejar las operaciones CRUD de Categoría
/// Se agregan headers de autorización (si existe token) y manejo básico de errores.
class CategoriaService {
  final Dio _dio = Dio();
  final String apiUrl =
      'https://farmaciajoshua-f7bncqe5aaefdsfp.westus3-01.azurewebsites.net/api/categoria';

  Future<List<Categoria>> getCategorias({int estado = 1}) async {
    try {
      final response = await _dio.get("$apiUrl/estado/$estado");
      if (response.data is List) {
        final data = response.data as List;
        return data.map((json) => Categoria.fromJson(json)).toList();
      }
      throw Exception('Formato de respuesta inesperado al listar categorías.');
    } on DioException catch (e) {
      throw Exception(_mapDioError(e, 'listar categorías'));
    }
  }

  Future<Categoria> getCategoriaById(int id) async {
    try {
      final response = await _dio.get("$apiUrl/$id");
      return Categoria.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_mapDioError(e, 'obtener categoría'));
    }
  }

  Future<void> addCategoria(Categoria categoria) async {
    try {
      await _dio.post(apiUrl, data: categoria.toJson());
    } on DioException catch (e) {
      throw Exception(_mapDioError(e, 'crear categoría'));
    }
  }

  Future<void> updateCategoria(int id, Categoria categoria) async {
    try {
      await _dio.put("$apiUrl/$id", data: categoria.toJson());
    } on DioException catch (e) {
      throw Exception(_mapDioError(e, 'actualizar categoría'));
    }
  }

  Future<void> deleteCategoria(int id, {int estado = 0}) async {
    try {
      await _dio.delete("$apiUrl/$id", queryParameters: {"estado": estado});
    } on DioException catch (e) {
      throw Exception(_mapDioError(e, 'eliminar categoría'));
    }
  }

  String _mapDioError(DioException e, String accion) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de conexión agotado al $accion.';
    }
    if (status != null) {
      return 'Error ($status) al $accion.';
    }
    return 'Fallo de red al $accion: ${e.message}';
  }
}
