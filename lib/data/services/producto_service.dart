import 'package:dio/dio.dart';
import '../models/producto.dart'; 

class ProductoService {
  final Dio _dio = Dio();
  // ¡IMPORTANTE! Cambia esta URL a la dirección correcta de tu API
  final String apiUrl = 'https://farmaciajoshua-f7bncqe5aaefdsfp.switzerlandnorth-01.azurewebsites.net/api/ProductoAlmacenado'; 

  ProductoService();

  // GET: Obtener todos los productos
  Future<List<ProductoModel>> getProductos() async {
    try {
      final response = await _dio.get(apiUrl); 
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductoModel.fromJson(json)).toList();
      } else {
        throw Exception('Fallo al cargar productos. Código: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión o API: ${e.message}');
    }
  }

  // POST: Agregar un nuevo producto
  Future<ProductoModel> addProducto(ProductoModel producto) async {
    try {
      final response = await _dio.post(apiUrl, data: producto.toJson());
      if (response.statusCode == 200) {
        return ProductoModel.fromJson(response.data); 
      } else {
        throw Exception('Fallo al agregar producto. Código: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error al agregar: ${e.message}');
    }
  }

  Future<void> updateProducto(int id, ProductoModel producto) async {
    try {
      await _dio.put('$apiUrl/$id', data: producto.toJson());
    } on DioException catch (e) {
      throw Exception('Error al actualizar: ${e.message}');
    }
  }

  Future<void> deleteProducto(int id) async {
    try {
      await _dio.delete('$apiUrl/$id');
    } on DioException catch (e) {
      throw Exception('Error al eliminar: ${e.message}');
    }
  }
}