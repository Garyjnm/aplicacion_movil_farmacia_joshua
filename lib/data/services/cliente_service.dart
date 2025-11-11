import 'package:dio/dio.dart';
import '../models/cliente.dart'; // Importamos el modelo de Cliente

// Servicio para manejar las operaciones CRUD de Clientes
class ClientesService {
  // Instancia de Dio para las solicitudes HTTP
  final Dio _dio = Dio();
  
  // URL base de la API. (Asegúrate de cambiar el puerto y la IP si es necesario)
  final String apiUrl = 'http://10.0.2.2:50498/api/Clientes';

  // Obtiene la lista de clientes, filtrando por estado (1=activo, 0=inactivo)
  // Corresponde a tu endpoint: [HttpGet("estado/{estado}")]
  Future<List<ClienteModel>> getClientes({int estado = 1}) async {
    try {
      final response = await _dio.get("$apiUrl/estado/$estado");
      print(response.data);
      
      // Manejo de 200 OK
      List data = response.data;
      return data.map((json) => ClienteModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // Manejo específico si la API devuelve 404 (No hay clientes)
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Fallo al obtener clientes: ${e.message}');
    }
  }

  // Obtiene un cliente por su ID
  // Corresponde a tu endpoint: [HttpGet("{id}")]
  Future<ClienteModel> getClienteById(int id) async {
    try {
      final response = await _dio.get("$apiUrl/$id");
      return ClienteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Fallo al obtener cliente por ID: ${e.message}');
    }
  }

  // Agrega un nuevo cliente
  // Corresponde a tu endpoint: [HttpPost]
  Future<void> addCliente(ClienteModel cliente) async {
    try {
      await _dio.post(apiUrl, data: cliente.toJson());
    } on DioException catch (e) {
      throw Exception('Fallo al agregar cliente: ${e.message}');
    }
  }

  // Actualiza un cliente existente por su ID
  // Corresponde a tu endpoint: [HttpPut("{id}")]
  // Nota: Pasamos el 'id' por URL y los datos por 'data'
  Future<void> updateCliente(int id, ClienteModel cliente) async {
    try {
      await _dio.put("$apiUrl/$id", data: cliente.toJson());
    } on DioException catch (e) {
      throw Exception('Fallo al actualizar cliente: ${e.message}');
    }
  }

  // Elimina (o desactiva/activa) un cliente por su ID, cambiando su estado
  // Corresponde a tu endpoint: [HttpDelete("{id}")]
  Future<void> deleteCliente(int id, {int estado = 0}) async {
    try {
      // Tu API usa 'estado' como query parameter para indicar si se desactiva (0) o activa (1)
      await _dio.delete("$apiUrl/$id", queryParameters: {"estado": estado});
    } on DioException catch (e) {
      throw Exception('Fallo al cambiar estado del cliente: ${e.message}');
    }
  }
}