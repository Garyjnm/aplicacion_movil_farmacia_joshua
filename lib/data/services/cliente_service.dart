import 'package:dio/dio.dart';
import '../models/cliente.dart';

class ClienteService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:50498/api'));

  Future<List<Cliente>> fetchClientes() async {
    try {
      final response = await _dio.get('/clientes');
      final List data = response.data;
      return data.map((e) => Cliente.fromJson(e)).toList();
    } catch (e) {
      print('Error al obtener clientes: $e');
      rethrow;
    }
  }
}
