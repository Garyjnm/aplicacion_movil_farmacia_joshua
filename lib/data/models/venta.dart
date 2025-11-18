// ...existing code...
import 'detalle_venta.dart';

class Venta {
  final int idVenta;
  int idCliente;
  final int idUsuario;
  final DateTime fechaVenta;
  double total;
  final List<DetalleVenta> ventaDetalle;

  Venta({
    required this.idVenta,
    required this.idCliente,
    required this.idUsuario,
    required this.fechaVenta,
    required this.total,
    required this.ventaDetalle,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    var detalleList = <DetalleVenta>[];
    if (json['ventaDetalle'] != null) {
      detalleList = List<Map<String, dynamic>>.from(json['ventaDetalle'])
          .map((e) => DetalleVenta.fromJson(e))
          .toList();
    }

    return Venta(
      idVenta: json['idVenta'],
      idCliente: json['idCliente'],
      idUsuario: json['idUsuario'],
      fechaVenta: DateTime.parse(json['fechaVenta']),
      total: (json['total'] as num).toDouble(),
      ventaDetalle: detalleList,
    );
  }

  Map<String, dynamic> toJson({
    bool includeId = true,
    bool includeDetalle = true,
    bool includeIdVentaEnDetalle = true,
  }) {
    return {
      if (includeId) 'idVenta': idVenta,
      'idCliente': idCliente,
      'idUsuario': idUsuario,
      'fechaVenta': fechaVenta.toIso8601String(),
      'total': total,
      if (includeDetalle)
        'ventaDetalle': ventaDetalle
            .map((d) => d.toJson(includeIdVenta: includeIdVentaEnDetalle))
            .toList(),
    };
  }
}
// ...existing code...