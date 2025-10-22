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
    final response = await _dio.post('/venta', data: {
      'idCliente': venta.idCliente,
      'idUsuario': venta.idUsuario,
      'fechaVenta': venta.fechaVenta.toIso8601String(),
      'total': venta.total,
      'ventaDetalle': venta.ventaDetalle
          .map((d) => {
                'idProducto': d.idProducto,
                'cantidad': d.cantidad,
                'precioUnitario': d.precioUnitario,
                'subtotal': d.subtotal,
              })
          .toList(),
    });

    try {
      final data = response.data;

      if (data is String) {
        print('Respuesta texto (createVenta): $data');
        return null;
      }

      if (data is Map<String, dynamic>) {
        return Venta.fromJson(data);
      }

      print('Respuesta inesperada (createVenta): $data');
      return null;
    } catch (e) {
      print('Error procesando respuesta createVenta: $e');
      rethrow;
    }
  }

  Future<Venta?> updateVenta(Venta venta) async {
    final response = await _dio.put('/venta/${venta.idVenta}', data: {
      'idCliente': venta.idCliente,
      'idUsuario': venta.idUsuario,
      'fechaVenta': venta.fechaVenta.toIso8601String(),
      'total': venta.total,
      'ventaDetalle': venta.ventaDetalle
          .map((d) => {
                'idProducto': d.idProducto,
                'cantidad': d.cantidad,
                'precioUnitario': d.precioUnitario,
                'subtotal': d.subtotal,
              })
          .toList(),
    });

    final data = response.data;

    if (data is String) {
      print('Respuesta texto (updateVenta): $data');
      return null;
    }

    if (data is Map<String, dynamic>) {
      return Venta.fromJson(data);
    }

    print('Respuesta inesperada en updateVenta: $data');
    return null;
  }

  Future<void> deleteVenta(int idVenta) async {
    await _dio.delete('/venta/$idVenta');
  }
}
