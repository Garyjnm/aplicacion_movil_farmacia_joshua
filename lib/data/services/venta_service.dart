import 'package:dio/dio.dart';
import '../models/venta.dart';

class VentaService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:50498/api'));

  Future<List<Venta>> fetchVentas() async {
    final response = await _dio.get('/venta');
    final List data = response.data;
    return data.map((e) => Venta.fromJson(e)).toList();
  }

  Future<Venta> fetchDetalle(int id) async {
    final response = await _dio.get('/venta/$id');
    return Venta.fromJson(response.data);
  }
}
