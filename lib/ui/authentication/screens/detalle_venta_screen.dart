import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/models/venta.dart';

class DetalleVentaScreen extends StatefulWidget {
  final int idVenta;
  const DetalleVentaScreen({super.key, required this.idVenta});

  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  final VentaService service = VentaService();
  late Future<Venta> _venta;

  @override
  void initState() {
    super.initState();
    _venta = service.fetchDetalle(widget.idVenta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Venta")),
      body: FutureBuilder<Venta>(
        future: _venta,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final venta = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Venta #${venta.idVenta}",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text("Cliente: ${venta.idCliente}"),
                Text("Usuario: ${venta.idUsuario}"),
                Text(
                    "Fecha: ${venta.fechaVenta.day}/${venta.fechaVenta.month}/${venta.fechaVenta.year}"),
                Text("Total: \$${venta.total.toStringAsFixed(2)}"),
                const SizedBox(height: 16),
                Text("Detalle de Productos:",
                    style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: venta.ventaDetalle.length,
                    itemBuilder: (context, index) {
                      final detalle = venta.ventaDetalle[index];
                      return ListTile(
                        title: Text("Producto #${detalle.idProducto}"),
                        subtitle:
                            Text("Cantidad: ${detalle.cantidad} - Precio: \$${detalle.precioUnitario.toStringAsFixed(2)}"),
                        trailing: Text(
                            "Subtotal: \$${detalle.subtotal.toStringAsFixed(2)}"),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
