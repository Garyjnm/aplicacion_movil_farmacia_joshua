// ...existing code...
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

  Future<Venta?> createVenta(Venta venta) async {
    try {
      final body = venta.toJson(
        includeId: false, // idVenta lo asigna backend
        includeDetalle: true,
        includeIdVentaEnDetalle: false, // usualmente backend infiere idVenta
      );

      final response = await _dio.post('/venta', data: body);

      if (response.data is Map<String, dynamic>) {
        return Venta.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión. Verifica el servidor.';
      if (e.response != null) {
        errorMessage =
            'Error del servidor (${e.response!.statusCode}): ${e.response!.data.toString()}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error desconocido al crear la venta: $e');
    }
  }

  Future<Venta?> updateVenta(
    Venta venta, {
    List<int> detallesEliminados = const [],
  }) async {
    try {
      final body = venta.toJson(
        includeId: true,
        includeDetalle: true,
        includeIdVentaEnDetalle: true,
      );

      if (detallesEliminados.isNotEmpty) {
        body['detallesEliminados'] = detallesEliminados;
      }

      final response = await _dio.put('/venta/${venta.idVenta}', data: body);

      if (response.data is Map<String, dynamic>) {
        return Venta.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión. Verifica el servidor.';
      if (e.response != null) {
        errorMessage =
            'Error del servidor (${e.response!.statusCode}): ${e.response!.data.toString()}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error desconocido al actualizar la venta: $e');
    }
  }

  Future<void> deleteVenta(int idVenta) async {
    try {
      await _dio.delete('/venta/$idVenta');
    } on DioException catch (e) {
      String errorMessage = 'Error al eliminar. Verifica el servidor.';
      if (e.response != null) {
        errorMessage =
            'Error del servidor (${e.response!.statusCode}): ${e.response!.data.toString()}';
      }
      throw Exception(errorMessage);
    }
  }
}
// ...existing code...