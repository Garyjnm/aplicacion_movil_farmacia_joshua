import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/venta.dart';
import '../services/metric_buffer.dart';

class TokenStore {
  static Future<String?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token;
  }
}

class VentaService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          'https://farmaciajoshua-f7bncqe5aaefdsfp.westus3-01.azurewebsites.net/api',
    ),
  );

  VentaService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStore.get();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

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
    final start = DateTime.now().millisecondsSinceEpoch;
    try {
      final response = await _dio.post(
        '/venta',
        data: {
          'idCliente': venta.idCliente,
          'idUsuario': venta.idUsuario,
          'fechaVenta': venta.fechaVenta.toIso8601String(),
          'total': venta.total,
          'ventaDetalle': venta.ventaDetalle
              .map(
                (d) => {
                  'idProducto': d.idProducto,
                  'cantidad': d.cantidad,
                  'precioUnitario': d.precioUnitario,
                  'subtotal': d.subtotal,
                },
              )
              .toList(),
        },
      );
      final duration = DateTime.now().millisecondsSinceEpoch - start;

      MetricBuffer().addMetric({
        "name": "sale_client_duration_ms",
        "value": duration,
        "tags": {"action": "create", "result": "success"},
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric",
      });

      if (response.data is Map<String, dynamic>) {
        return Venta.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      MetricBuffer().addMetric({
        "name": "sale_client_duration_ms",
        "value": duration,
        "tags": {"action": "create", "result": "error"},
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric",
      });
      String errorMessage = 'Error de conexión. Verifica el servidor.';
      if (e.response != null) {
        errorMessage = 'Error del servidor (${e.response!.statusCode})';
      }
      throw Exception(errorMessage);
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      MetricBuffer().addMetric({
        "name": "sale_client_duration_ms",
        "value": duration,
        "tags": {"action": "create", "result": "error"},
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric",
      });
      throw Exception('Error desconocido al crear la venta: $e');
    }
  }

  Future<Venta?> updateVenta(Venta venta) async {
    try {
      final response = await _dio.put(
        '/venta/${venta.idVenta}',
        data: {
          'idVenta': venta.idVenta,
          'idCliente': venta.idCliente,
          'idUsuario': venta.idUsuario,
          'fechaVenta': venta.fechaVenta.toIso8601String(),
          'total': venta.total,
          'ventaDetalle': venta.ventaDetalle
              .map(
                (d) => {
                  'idDetalleVenta': d.idDetalleVenta,
                  'idProducto': d.idProducto,
                  'cantidad': d.cantidad,
                  'precioUnitario': d.precioUnitario,
                  'subtotal': d.subtotal,
                },
              )
              .toList(),
        },
      );

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
    final start = DateTime.now().millisecondsSinceEpoch;
    try {
      await _dio.delete('/venta/$idVenta');
      final duration = DateTime.now().millisecondsSinceEpoch - start;

      MetricBuffer().addMetric({
        "name": "sale_client_duration_ms",
        "value": duration,
        "tags": {"action": "delete", "result": "success"},
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric",
      });
    } on DioException catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      MetricBuffer().addMetric({
        "name": "sale_client_duration_ms",
        "value": duration,
        "tags": {"action": "delete", "result": "error"},
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric",
      });
      String errorMessage = 'Error al eliminar. Verifica el servidor.';
      if (e.response != null) {
        errorMessage = 'Error del servidor (${e.response!.statusCode})';
      }
      throw Exception(errorMessage);
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      MetricBuffer().addMetric({
        "name": "sale_client_duration_ms",
        "value": duration,
        "tags": {"action": "delete", "result": "error"},
        "timestamp": DateTime.now().toIso8601String(),
        "type": "metric",
      });
      throw Exception('Error desconocido al eliminar la venta: $e');
    }
  }
}
