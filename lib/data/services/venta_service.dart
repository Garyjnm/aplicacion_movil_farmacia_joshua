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

  Future<Venta> createVenta(Venta venta) async {
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
    return Venta.fromJson(response.data);
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
