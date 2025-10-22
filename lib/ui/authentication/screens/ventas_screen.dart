import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/models/venta.dart';
import '../../../data/models/detalle_venta.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_create_button.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/paginacion_controls.dart';
import 'detalle_venta_screen.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final VentaService _service = VentaService();
  List<Venta> _allVentas = [];
  late Future<void> _loadFuture;

  // Controladores
  final clienteController = TextEditingController();
  final usuarioController = TextEditingController();
  final fechaController = TextEditingController();
  final productoController = TextEditingController();
  final cantidadController = TextEditingController();
  final precioController = TextEditingController();
  final totalController = TextEditingController();

  // Paginación
  int currentPage = 1;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadVentas();
  }

  Future<void> _loadVentas() async {
    final data = await _service.fetchVentas();
    setState(() {
      _allVentas = data;
    });
  }

  void _refresh() async {
    await _loadVentas();
  }

  //Mostrar diálogo de crear o editar
  void _mostrarDialogo({Venta? venta}) {
    final bool isEdit = venta != null;

    if (isEdit) {
      clienteController.text = venta!.idCliente.toString();
      usuarioController.text = venta.idUsuario.toString();
      fechaController.text = venta.fechaVenta.toIso8601String();

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
    } else {
      clienteController.clear();
      usuarioController.clear();
      fechaController.text = DateTime.now().toIso8601String();
      productoController.clear();
      cantidadController.clear();
      precioController.clear();
      totalController.clear();
    }

    showCustomDialog(
      context: context,
      title: isEdit ? "Editar Venta #${venta!.idVenta}" : "Nueva Venta",
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
        try {
          final detalle = DetalleVenta(
            idDetalleVenta: isEdit && venta!.ventaDetalle.isNotEmpty
                ? venta.ventaDetalle[0].idDetalleVenta
                : 0,
            idVenta: isEdit ? venta!.idVenta : 0,
            idProducto: int.tryParse(productoController.text) ?? 0,
            cantidad: int.tryParse(cantidadController.text) ?? 0,
            precioUnitario: double.tryParse(precioController.text) ?? 0,
            subtotal: (int.tryParse(cantidadController.text) ?? 0) *
                (double.tryParse(precioController.text) ?? 0),
          );

          final ventaNueva = Venta(
            idVenta: isEdit ? venta!.idVenta : 0,
            idCliente: int.tryParse(clienteController.text) ?? 0,
            idUsuario: int.tryParse(usuarioController.text) ?? 0,
            fechaVenta: DateTime.tryParse(fechaController.text) ?? DateTime.now(),
            total: double.tryParse(totalController.text) ?? 0.0,
            ventaDetalle: [detalle],
          );

          if (isEdit) {
            await _service.updateVenta(ventaNueva);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Venta actualizada correctamente.")),
            );
          } else {
            await _service.createVenta(ventaNueva);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Venta creada correctamente.")),
            );
          }

          _refresh();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      },
    );
  }

  void _eliminarVenta(Venta venta) async {
    final colors = Theme.of(context).colorScheme;
    showCustomDialog(
      context: context,
      title: "Eliminar Venta",
      content: Text(
        "¿Seguro que deseas eliminar la venta #${venta.idVenta}?",
        style: TextStyle(color: colors.onSurface),
      ),
      onSave: () async {
        await _service.deleteVenta(venta.idVenta);
        _refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Venta eliminada correctamente.")),
        );
      },
      saveLabel: "Eliminar",
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    final totalPages =
        (_allVentas.length / itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, _allVentas.length);
    final ventasPagina = _allVentas.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primaryContainer,
        title: Text(
          "Ventas",
          style: fonts.titleLarge?.copyWith(color: colors.onPrimaryContainer),
        ),
        iconTheme: IconThemeData(color: colors.onPrimaryContainer),
      ),
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _allVentas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Botón “Nueva Venta”
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CustomCreateButton(
                  label: "Nueva Venta",
                  onPressed: () => _mostrarDialogo(),
                ),
              ),
              Expanded(
                child: ventasPagina.isEmpty
                    ? Center(
                        child: Text(
                          "No hay ventas registradas.",
                          style: fonts.bodyMedium?.copyWith(color: colors.onSurface),
                        ),
                      )
                    : ListView.builder(
                        itemCount: ventasPagina.length,
                        itemBuilder: (context, index) {
                          final venta = ventasPagina[index];
                          return CustomCard(
                            child: ListTile(
                              leading: Icon(Icons.receipt_long,
                                  color: colors.onPrimaryContainer),
                              title: Text(
                                "Venta #${venta.idVenta}",
                                style: fonts.titleMedium?.copyWith(
                                    color: colors.onPrimaryContainer),
                              ),
                              subtitle: Text(
                                "Cliente: ${venta.idCliente} | Usuario: ${venta.idUsuario}\nTotal: \$${venta.total.toStringAsFixed(2)}",
                                style: fonts.bodySmall
                                    ?.copyWith(color: colors.onPrimaryContainer),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: colors.secondary),
                                    onPressed: () =>
                                        _mostrarDialogo(venta: venta),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: colors.error),
                                    onPressed: () => _eliminarVenta(venta),
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
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: PaginacionControls(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: (page) {
                      setState(() => currentPage = page);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
