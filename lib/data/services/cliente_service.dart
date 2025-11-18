import 'package:dio/dio.dart';
import '../models/cliente.dart'; 

class ClientesService {
  final Dio _dio = Dio();
  
  final String apiUrl = 'https://farmaciajoshua-f7bncqe5aaefdsfp.switzerlandnorth-01.azurewebsites.net/api/Clientes';

  Future<List<ClienteModel>> getClientes({int estado = 1}) async {
    try {
      final response = await _dio.get("$apiUrl/estado/$estado");
      print(response.data);
      
      List data = response.data;
      return data.map((json) => ClienteModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Fallo al obtener clientes: ${e.message}');
    }
  }


  Future<ClienteModel> getClienteById(int id) async {
    try {
      final response = await _dio.get("$apiUrl/$id");
      return ClienteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Fallo al obtener cliente por ID: ${e.message}');
    }
  }


  Future<void> addCliente(ClienteModel cliente) async {
    try {
      await _dio.post(apiUrl, data: cliente.toJson());
    } on DioException catch (e) {
      throw Exception('Fallo al agregar cliente: ${e.message}');
    }
  }

  Future<void> updateCliente(int id, ClienteModel cliente) async {
    try {
      await _dio.put("$apiUrl/$id", data: cliente.toJson());
    } on DioException catch (e) {
      throw Exception('Fallo al actualizar cliente: ${e.message}');
    }
  }


  Future<void> deleteCliente(int id, {int estado = 0}) async {
    try {
      await _dio.delete("$apiUrl/$id", queryParameters: {"estado": estado});
    } on DioException catch (e) {
      throw Exception('Fallo al cambiar estado del cliente: ${e.message}');
    }
  }
}