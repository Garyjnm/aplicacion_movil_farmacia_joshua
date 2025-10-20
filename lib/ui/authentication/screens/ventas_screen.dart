import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/models/venta.dart';
import 'detalle_venta_screen.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen ({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final VentaService service = VentaService();
  late Future<List<Venta>> _ventas;

  @override
  void initState() {
    super.initState();
    _ventas = service.fetchVentas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ventas")),
      body: FutureBuilder<List<Venta>>(
        future: _ventas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ventas = snapshot.data ?? [];
          if (ventas.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }

          return ListView.builder(
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              final venta = ventas[index];
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text("Venta #${venta.idVenta}"),
                subtitle: Text(
                    "Cliente: ${venta.idCliente} - Total: \$${venta.total.toStringAsFixed(2)}"),
                trailing: Text(
                    "${venta.fechaVenta.day}/${venta.fechaVenta.month}/${venta.fechaVenta.year}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleVentaScreen(idVenta: venta.idVenta),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
