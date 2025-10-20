import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/models/venta.dart';
import '../../../data/models/detalle_venta.dart';
import 'detalle_venta_screen.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_create_button.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../core/widgets/custom_textfield.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final VentaService service = VentaService();
  late Future<List<Venta>> _ventas;

  // Controladores
  final clienteController = TextEditingController();
  final usuarioController = TextEditingController();
  final fechaController = TextEditingController();
  final productoController = TextEditingController();
  final cantidadController = TextEditingController();
  final precioController = TextEditingController();
  final totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ventas = service.fetchVentas();
  }

  void _refreshVentas() {
    setState(() {
      _ventas = service.fetchVentas();
    });
  }

  // Crear venta
  void _crearVenta() {
    clienteController.clear();
    usuarioController.clear();
    fechaController.text = DateTime.now().toString();
    productoController.clear();
    cantidadController.clear();
    precioController.clear();
    totalController.clear();

    showCustomDialog(
      context: context,
      title: "Nueva Venta",

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: clienteController, label: "ID Cliente"),
            const SizedBox(height: 10),
            CustomTextField(controller: usuarioController, label: "ID Usuario"),
            const SizedBox(height: 10),
            CustomTextField(controller: fechaController, label: "Fecha Venta"),
            const SizedBox(height: 10),
            CustomTextField(controller: productoController, label: "ID Producto"),
            const SizedBox(height: 10),
            CustomTextField(controller: cantidadController, label: "Cantidad"),
            const SizedBox(height: 10),
            CustomTextField(controller: precioController, label: "Precio Unitario"),
            const SizedBox(height: 10),
            CustomTextField(controller: totalController, label: "Total"),
          ],
        ),
      ),
      onSave: () async {
        if (clienteController.text.isEmpty ||
            usuarioController.text.isEmpty ||
            productoController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Por favor completa todos los campos.")),
          );
          return;
        }

        final detalle = DetalleVenta(
          idDetalleVenta: 0,
          idVenta: 0,
          idProducto: int.tryParse(productoController.text) ?? 0,
          cantidad: int.tryParse(cantidadController.text) ?? 0,
          precioUnitario: double.tryParse(precioController.text) ?? 0,
          subtotal: (int.tryParse(cantidadController.text) ?? 0) *
              (double.tryParse(precioController.text) ?? 0),
        );

        final venta = Venta(
          idVenta: 0,
          idCliente: int.tryParse(clienteController.text) ?? 0,
          idUsuario: int.tryParse(usuarioController.text) ?? 0,
          fechaVenta: DateTime.now(),
          total: double.tryParse(totalController.text) ?? 0.0,
          ventaDetalle: [detalle],
        );

        try {
          await service.createVenta(venta);
          _refreshVentas();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Venta creada correctamente.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al crear venta: $e")),
          );
        }
      },
    );
  }

  // Editar venta
  void _editarVenta(Venta venta) {
    clienteController.text = venta.idCliente.toString();
    usuarioController.text = venta.idUsuario.toString();
    fechaController.text = venta.fechaVenta.toString();

    if (venta.ventaDetalle.isNotEmpty) {
      productoController.text = venta.ventaDetalle[0].idProducto.toString();
      cantidadController.text = venta.ventaDetalle[0].cantidad.toString();
      precioController.text =
          venta.ventaDetalle[0].precioUnitario.toStringAsFixed(2);
    } else {
      productoController.clear();
      cantidadController.clear();
      precioController.clear();
    }

    totalController.text = venta.total.toStringAsFixed(2);

    showCustomDialog(
      context: context,
      title: "Editar Venta #${venta.idVenta}",
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: clienteController, label: "ID Cliente"),
            const SizedBox(height: 10),
            CustomTextField(controller: usuarioController, label: "ID Usuario"),
            const SizedBox(height: 10),
            CustomTextField(controller: fechaController, label: "Fecha Venta"),
            const SizedBox(height: 10),
            CustomTextField(controller: productoController, label: "ID Producto"),
            const SizedBox(height: 10),
            CustomTextField(controller: cantidadController, label: "Cantidad"),
            const SizedBox(height: 10),
            CustomTextField(controller: precioController, label: "Precio Unitario"),
            const SizedBox(height: 10),
            CustomTextField(controller: totalController, label: "Total"),
          ],
        ),
      ),
      onSave: () async {
        final detalleActualizado = DetalleVenta(
          idDetalleVenta: venta.ventaDetalle.isNotEmpty
              ? venta.ventaDetalle[0].idDetalleVenta
              : 0,
          idVenta: venta.idVenta,
          idProducto: int.tryParse(productoController.text) ?? 0,
          cantidad: int.tryParse(cantidadController.text) ?? 0,
          precioUnitario: double.tryParse(precioController.text) ?? 0,
          subtotal: (int.tryParse(cantidadController.text) ?? 0) *
              (double.tryParse(precioController.text) ?? 0),
        );

        final ventaEditada = Venta(
          idVenta: venta.idVenta,
          idCliente: int.tryParse(clienteController.text) ?? venta.idCliente,
          idUsuario: int.tryParse(usuarioController.text) ?? venta.idUsuario,
          fechaVenta: DateTime.tryParse(fechaController.text) ?? venta.fechaVenta,
          total: double.tryParse(totalController.text) ?? venta.total,
          ventaDetalle: [detalleActualizado],
        );

        try {
          await service.updateVenta(ventaEditada);
          _refreshVentas();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Venta actualizada correctamente.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al actualizar: $e")),
          );
        }
      },
    );
  }

  // Eliminar venta
  void _eliminarVenta(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar venta"),
        content: const Text("¿Deseas eliminar esta venta permanentemente?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await service.deleteVenta(id);
      _refreshVentas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Venta eliminada correctamente.")),
      );
    }
  }

  //  UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Ventas", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshVentas,
          )
        ],
      ),
      floatingActionButton: CustomCreateButton(
        label: "Nueva Venta",
        onPressed: _crearVenta,
      ),
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
              return CustomCard(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.teal),
                  title: Text("Venta #${venta.idVenta}"),
                  subtitle: Text(
                    "Cliente: ${venta.idCliente} | Usuario: ${venta.idUsuario}\nTotal: \$${venta.total.toStringAsFixed(2)}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarVenta(venta),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarVenta(venta.idVenta),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetalleVentaScreen(idVenta: venta.idVenta),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
