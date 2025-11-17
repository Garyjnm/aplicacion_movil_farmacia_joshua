import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/services/cliente_service.dart';
import '../../../data/services/producto_service.dart';
import '../../../data/models/venta.dart';
import '../../../data/models/cliente.dart';
import '../../../data/models/producto.dart';
import '../../core/widgets/custom_card2.dart';

class DetalleVentaScreen extends StatefulWidget {
  final int idVenta;
  const DetalleVentaScreen({super.key, required this.idVenta});

  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  // Servicios para obtener datos
  final VentaService _ventaService = VentaService();
  final ClientesService _clienteService = ClientesService();
  final ProductoService _productoService = ProductoService();

  late Future<Map<String, dynamic>> _loadFuture; // Future combinando cargas
  Venta? _venta;
  List<ClienteModel> _clientes = [];
  List<ProductoModel> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadAllData(); // dispara la carga inicial
  }

  // Carga en paralelo venta, clientes y productos
  Future<Map<String, dynamic>> _loadAllData() async {
    final ventaFuture = _ventaService.fetchDetalle(widget.idVenta);
    final clientesFuture = _clienteService.getClientes();
    final productosFuture = _productoService.getProductos();

    final results = await Future.wait([ventaFuture, clientesFuture, productosFuture]);

    if (!mounted) return {};

    setState(() {
      _venta = results[0] as Venta;
      _clientes = results[1] as List<ClienteModel>;
      _productos = results[2] as List<ProductoModel>;
    });

    return {
      'venta': _venta,
      'clientes': _clientes,
      'productos': _productos,
    };
  }

  // Obtiene nombre completo de cliente
  String _getNombreCliente(int idCliente) {
    try {
      final c = _clientes.firstWhere((e) => e.idCliente == idCliente);
      return '${c.nombre} ${c.apellido}';
    } catch (_) {
      return 'Cliente Desconocido ($idCliente)';
    }
  }

  // Obtiene nombre del producto
  String _getNombreProducto(int idProducto) {
    try {
      final p = _productos.firstWhere((e) => e.almcId == idProducto);
      return p.nombreProducto ?? 'Producto Sin Nombre';
    } catch (_) {
      return 'Producto Desconocido ($idProducto)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        backgroundColor: colors.primaryContainer,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // estado de carga
          }
          if (snapshot.hasError || !snapshot.hasData || _venta == null) {
            return Center(
              child: Text('Error al cargar datos: ${snapshot.error ?? "Datos no encontrados"}'),
            );
          }

          final venta = _venta!;
          final nombreCliente = _getNombreCliente(venta.idCliente);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de la venta
                Text(
                  'Venta #${venta.idVenta}',
                  style: fonts.headlineMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Cliente: $nombreCliente', style: TextStyle(color: colors.onPrimaryContainer)),
                Text('Usuario: ${venta.idUsuario}', style: TextStyle(color: colors.onPrimaryContainer)),
                Text(
                  'Fecha: ${venta.fechaVenta.day}/${venta.fechaVenta.month}/${venta.fechaVenta.year}',
                  style: TextStyle(color: colors.onPrimaryContainer),
                ),
                Text(
                  'Total: \$${venta.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Detalle de Productos:',
                  style: fonts.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                // Lista de detalles
                Expanded(
                  child: ListView.builder(
                    itemCount: venta.ventaDetalle.length,
                    itemBuilder: (context, index) {
                      final detalle = venta.ventaDetalle[index];
                      final nombreProducto = _getNombreProducto(detalle.idProducto);

                      return CustomCard2(
                        // Card adaptativo al tema (alwaysWhite:false por defecto)
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del producto
                            Row(
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 22, color: colors.onSurface),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    nombreProducto,
                                    style: fonts.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Cantidad
                            RichText(
                              text: TextSpan(
                                style: fonts.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Cantidad: ',
                                    style: fonts.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  TextSpan(text: '${detalle.cantidad}'),
                                ],
                              ),
                            ),
                            // Precio
                            RichText(
                              text: TextSpan(
                                style: fonts.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Precio: ',
                                    style: fonts.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  TextSpan(text: '\$${detalle.precioUnitario.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                            // Subtotal
                            RichText(
                              text: TextSpan(
                                style: fonts.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Subtotal: ',
                                    style: fonts.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  TextSpan(text: '\$${detalle.subtotal.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ],
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