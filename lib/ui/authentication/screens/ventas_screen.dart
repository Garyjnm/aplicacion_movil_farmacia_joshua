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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VentaFormScreen(),
            ),
          );
          if (result == true) _refresh();
        },
        label: const Text("Nueva Venta"),
        icon: const Icon(Icons.add),
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
                                nombre: 'Desconocido', apellido: ''),
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
                                    icon:
                                        Icon(Icons.edit, color: colors.secondary),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              VentaFormScreen(venta: venta),
                                        ),
                                      );
                                      if (result == true) _refresh();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: colors.error,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await _ventaService.deleteVenta(
                                            venta.idVenta);
                                        _refresh();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Venta eliminada."),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text("Error al eliminar: $e"),
                                          ),
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

              if (totalPages > 1)
                PaginacionControls(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: (page) {
                    setState(() => currentPage = page);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
