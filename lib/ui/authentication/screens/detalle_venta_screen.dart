import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/services/cliente_service.dart'; 
import '../../../data/services/producto_service.dart'; 
import '../../../data/models/venta.dart';
import '../../../data/models/cliente.dart'; 
import '../../../data/models/producto.dart'; 
import '../../core/widgets/custom_card.dart';

class DetalleVentaScreen extends StatefulWidget {
  final int idVenta;
  const DetalleVentaScreen({super.key, required this.idVenta});

  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  final VentaService _ventaService = VentaService();
  final ClientesService _clienteService = ClientesService(); 
  final ProductoService _productoService = ProductoService(); 

  late Future<Map<String, dynamic>> _loadFuture;

  Venta? _venta;
  List<ClienteModel> _clientes = [];
  List<ProductoModel> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadAllData();
  }

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

  String _getNombreCliente(int idCliente) {
    try {
      final cliente = _clientes.firstWhere((c) => c.idCliente == idCliente);
      return '${cliente.nombre} ${cliente.apellido}';
    } catch (_) {
      return 'Cliente Desconocido ($idCliente)';
    }
  }

  String _getNombreProducto(int idProducto) {
    try {
      final producto = _productos.firstWhere((p) => p.almcId == idProducto); 
      return producto.nombreProducto ?? 'Producto Sin Nombre'; 
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
        title: const Text("Detalle de Venta"),
        backgroundColor: colors.primaryContainer,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || _venta == null) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error ?? "Datos no encontrados"}'));
          }

          final venta = _venta!; 
          
          final nombreCliente = _getNombreCliente(venta.idCliente);
          
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
                Text("Cliente: $nombreCliente",
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
                      final nombreProducto = _getNombreProducto(detalle.idProducto);

                      return CustomCard(
                        child: ListTile(
                          title: Text(
                            nombreProducto,
                            style: TextStyle(color: colors.onPrimaryContainer),
                          ),
                          subtitle: Text(
                            "Cantidad: ${detalle.cantidad} - Precio: \$${detalle.precioUnitario.toStringAsFixed(2)}",
                            style: TextStyle(color: colors.onPrimaryContainer),
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