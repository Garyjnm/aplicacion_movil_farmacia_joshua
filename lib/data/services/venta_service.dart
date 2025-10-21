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

    // Si la API devolvió un String plano, no intentes parsear como JSON
    if (data is String) {
      print('Respuesta del servidor (texto): $data');
      return null; // o podrías devolver una Venta vacía si prefieres
    }

    // Si devolvió un Map (JSON), entonces sí parseamos correctamente
    if (data is Map<String, dynamic>) {
      return Venta.fromJson(data);
    }

    // Si devolvió algo inesperado (por ejemplo lista), manejamos seguro
    print('Respuesta inesperada: $data');
    return null;
  } catch (e) {
    print('Error procesando respuesta: $e');
    rethrow;
  }
}

  Future<Venta> updateVenta(Venta venta) async {
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
    return Venta.fromJson(response.data);
  }

  Future<void> deleteVenta(int idVenta) async {
    await _dio.delete('/venta/$idVenta');
  }
}
