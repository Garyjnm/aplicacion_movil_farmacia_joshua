import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/models/venta.dart';
import '../../../data/models/detalle_venta.dart';
import 'detalle_venta_screen.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_create_button.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/paginacion_controls.dart'; // 👈 Importamos tu widget de paginación

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final VentaService service = VentaService();
  late Future<List<Venta>> _ventas;

  // Paginación
  int currentPage = 1;
  final int itemsPerPage = 5; // 👈 Número de ventas por página

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
      currentPage = 1; // Reiniciamos a la primera página
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
    final colors = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text("Eliminar venta", style: TextStyle(color: colors.onSurface)),
        content: Text(
          "¿Deseas eliminar esta venta permanentemente?",
          style: TextStyle(color: colors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: colors.secondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primaryContainer,
        title: Text(
          "Ventas",
          style: textTheme.titleLarge?.copyWith(color: colors.onPrimaryContainer),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.onPrimaryContainer),
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
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: colors.onSurface)),
            );
          }

          final ventas = snapshot.data ?? [];
          if (ventas.isEmpty) {
            return Center(
              child: Text('No hay ventas registradas.',
                  style: TextStyle(color: colors.onSurface)),
            );
          }

          // --- Paginación local ---
          final totalPages =
              (ventas.length / itemsPerPage).ceil().clamp(1, double.infinity).toInt();
          final startIndex = (currentPage - 1) * itemsPerPage;
          final endIndex = (startIndex + itemsPerPage).clamp(0, ventas.length);
          final ventasPagina = ventas.sublist(startIndex, endIndex);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: ventasPagina.length,
                  itemBuilder: (context, index) {
                    final venta = ventasPagina[index];
                    return CustomCard(
                      child: ListTile(
                        leading: Icon(Icons.receipt_long,
                            color: colors.onPrimaryContainer),
                        title: Text(
                          "Venta #${venta.idVenta}",
                          style: textTheme.titleMedium
                              ?.copyWith(color: colors.onPrimaryContainer),
                        ),
                        subtitle: Text(
                          "Cliente: ${venta.idCliente} | Usuario: ${venta.idUsuario}\nTotal: \$${venta.total.toStringAsFixed(2)}",
                          style: textTheme.bodySmall
                              ?.copyWith(color: colors.onPrimaryContainer),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: colors.secondary),
                              onPressed: () => _editarVenta(venta),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: colors.error),
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
                ),
              ),
              const SizedBox(height: 8),
              // --- Widget de paginación ---
              PaginacionControls(
                currentPage: currentPage,
                totalPages: totalPages,
                onPageChanged: (page) {
                  setState(() => currentPage = page);
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
