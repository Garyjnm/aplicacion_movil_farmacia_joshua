import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/services/cliente_service.dart';
import '../../../data/services/producto_service.dart';
import '../../../data/models/venta.dart';
import '../../../data/models/cliente.dart';
import '../../../data/models/producto.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/paginacion_controls.dart';
import 'venta_form_screen.dart'; 
import 'detalle_venta_screen.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final VentaService _ventaService = VentaService();
  final ClientesService _clienteService = ClientesService();
  final ProductoService _productoService = ProductoService();

  List<Venta> _allVentas = [];
  List<ClienteModel> _clientes = [];
  List<ProductoModel> _productos = [];

  late Future<void> _loadFuture;

  // Paginación
  int currentPage = 1;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      final ventas = await _ventaService.fetchVentas();
      final clientes = await _clienteService.getClientes();
      final productos = await _productoService.getProductos();

      if (!mounted) return;

      setState(() {
        _allVentas = ventas;
        _clientes = clientes;
        _productos = productos;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar datos: $e")),
      );
    }
  }

  void _refresh() async {
    await _loadData();
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

          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar ventas: ${snapshot.error}"),
            );
          }

          return Column(
            children: [
              // Botón "Nueva Venta" arriba de la lista
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VentaFormScreen(),
                          ),
                        );
                        if (result == true) _refresh();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Nueva Venta"),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ventasPagina.isEmpty
                    ? const Center(
                        child: Text("No hay ventas registradas."),
                      )
                    : ListView.builder(
                        itemCount: ventasPagina.length,
                        itemBuilder: (context, index) {
                          final venta = ventasPagina[index];

                          final cliente = _clientes.firstWhere(
                            (c) => c.idCliente == venta.idCliente,
                            orElse: () => ClienteModel(
                              nombre: 'Desconocido',
                              apellido: '',
                            ),
                          );

                          String productosInfo = "Sin productos";
                          if (venta.ventaDetalle.isNotEmpty) {
                            final primer = venta.ventaDetalle.first;
                            final productoAsociado = _productos.firstWhere(
                              (p) => p.almcId == primer.idProducto,
                              orElse: () => ProductoModel(
                                nombreProducto: 'Producto Desconocido',
                              ),
                            );

                            productosInfo =
                                "${primer.cantidad}x ${productoAsociado.nombreProducto}";

                            if (venta.ventaDetalle.length > 1) {
                              productosInfo +=
                                  " (+${venta.ventaDetalle.length - 1} más)";
                            }
                          }

                          return CustomCard(
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long),
                              title: Text(
                                "Venta #${venta.idVenta}",
                                style: fonts.titleMedium,
                              ),
                              subtitle: Text(
                                "Cliente: ${cliente.nombre} ${cliente.apellido}\n"
                                "Total: \$${venta.total.toStringAsFixed(2)}\n"
                                "Productos: $productosInfo",
                                style: fonts.bodySmall,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: colors.secondary),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VentaFormScreen(venta: venta),
                                        ),
                                      );
                                      if (result == true) _refresh();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: colors.error),
                                    onPressed: () async {
                                      final confirmar = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Confirmar eliminación'),
                                              content: Text(
                                                '¿Seguro que deseas eliminar la venta #${venta.idVenta}? Esta acción no se puede deshacer.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: colors.error,
                                                  ),
                                                  onPressed: () => Navigator.of(ctx).pop(true),
                                                  child: const Text('Eliminar'),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;

                                      if (!confirmar) return;

                                      try {
                                        await _ventaService.deleteVenta(venta.idVenta);
                                        _refresh();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Venta eliminada.")),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error al eliminar: $e")),
                                        );
                                      }
                                    },
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

              // Paginación un poco más arriba del borde inferior
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: PaginacionControls(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: (page) {
                      setState(() => currentPage = page);
                    },
                  ),
                ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
