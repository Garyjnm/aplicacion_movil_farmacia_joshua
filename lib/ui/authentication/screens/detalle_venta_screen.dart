import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/models/venta.dart';
import '../../core/widgets/custom_card.dart';

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
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Venta"),
        backgroundColor: colors.primaryContainer,
      ),
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
                Text(
                  "Venta #${venta.idVenta}",
                  style: fonts.headlineMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Cliente: ${venta.idCliente}",
                    style: TextStyle(color: colors.onPrimaryContainer)),
                Text("Usuario: ${venta.idUsuario}",
                    style: TextStyle(color: colors.onPrimaryContainer)),
                Text(
                    "Fecha: ${venta.fechaVenta.day}/${venta.fechaVenta.month}/${venta.fechaVenta.year}",
                    style: TextStyle(color: colors.onPrimaryContainer)),
                Text("Total: \$${venta.total.toStringAsFixed(2)}",
                    style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 16),
                Text("Detalle de Productos:",
                    style: fonts.titleMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: venta.ventaDetalle.length,
                    itemBuilder: (context, index) {
                      final detalle = venta.ventaDetalle[index];
                      return CustomCard(
                        child: ListTile(
                          title: Text(
                            "Producto #${detalle.idProducto}",
                            style:
                                TextStyle(color: colors.onPrimaryContainer),
                          ),
                          subtitle: Text(
                            "Cantidad: ${detalle.cantidad} - Precio: \$${detalle.precioUnitario.toStringAsFixed(2)}",
                            style:
                                TextStyle(color: colors.onPrimaryContainer),
                          ),
                          trailing: Text(
                            "Subtotal: \$${detalle.subtotal.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: colors.secondary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
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
