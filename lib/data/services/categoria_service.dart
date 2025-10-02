import 'package:dio/dio.dart';
import '../models/categoria.dart';


class CategoriaService {
  final Dio _dio = Dio();
  final String apiUrl = "http://10.0.2.2:50498/api/categoria"; 
 

  Future<List<Categoria>> getCategorias({int estado = 1}) async {
    final response = await _dio.get("$apiUrl/estado/$estado");
    List data = response.data;
    return data.map((json) => Categoria.fromJson(json)).toList();
  }

  Future<Categoria> getCategoriaById(int id) async {
    final response = await _dio.get("$apiUrl/$id");
    return Categoria.fromJson(response.data);
  }

  Future<void> addCategoria(Categoria categoria) async {
    await _dio.post(apiUrl, data: categoria.toJson());
  }

  Future<void> updateCategoria(int id, Categoria categoria) async {
    await _dio.put("$apiUrl/$id", data: categoria.toJson());
  }

  Future<void> deleteCategoria(int id, {int estado = 0}) async {
    await _dio.delete("$apiUrl/$id", queryParameters: {"estado": estado});
  }
}
