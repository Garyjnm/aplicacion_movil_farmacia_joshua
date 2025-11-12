import 'package:flutter/material.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/services/cliente_service.dart';
import '../../../data/services/producto_service.dart';
import '../../../data/models/venta.dart';
import '../../../data/models/detalle_venta.dart';
import '../../../data/models/cliente.dart';
import '../../../data/models/producto.dart';
import '../../core/widgets/custom_card.dart';
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
        SnackBar(content: Text("Error al cargar datos iniciales: ${e.toString()}")),
      );
    }
  }

  void _refresh() async {
    await _loadData();
  }

  void _mostrarDialogo({Venta? venta}) {
    final bool isEdit = venta != null;

    ClienteModel? clienteSeleccionado;
    if (isEdit) {
      try {
        clienteSeleccionado = _clientes.firstWhere(
          (c) => c.idCliente == venta!.idCliente,
          orElse: () => _clientes.first,
        );
      } catch (_) {
        clienteSeleccionado = null;
      }
    }
    
    final usuarioController = TextEditingController(
        text: isEdit ? venta!.idUsuario.toString() : '');
    final fechaController = TextEditingController(
        text: isEdit
            ? venta!.fechaVenta.toIso8601String()
            : DateTime.now().toIso8601String());

    List<Map<String, dynamic>> detalles = []; 

    if (isEdit && venta!.ventaDetalle.isNotEmpty) {
      for (var d in venta.ventaDetalle) {
        final producto = _productos.firstWhere(
            (p) => p.almcId == d.idProducto,
            orElse: () => ProductoModel(almcId: d.idProducto, nombreProducto: 'No Encontrado'));
        detalles.add({
          'idDetalleVenta': d.idDetalleVenta, 
          'producto': producto,
          'cantidad': d.cantidad.toString(),
          'precio': d.precioUnitario.toString(),
        });
      }
    } else {
      detalles.add({
        'idDetalleVenta': 0, 
        'producto': null, 
        'cantidad': '', 
        'precio': ''
      });
    }

    void _agregarProducto(void Function(void Function()) setDialogState) {
      setDialogState(() {
        detalles.add({'idDetalleVenta': 0, 'producto': null, 'cantidad': '', 'precio': ''});
      });
    }

    Future<void> _calcularTotalYGuardar() async {
      final dialogContext = context; 
      try {
        double total = 0;
        final List<DetalleVenta> detalleList = [];

        for (var item in detalles) {
          final producto = item['producto'] as ProductoModel?;
          final cantidad = int.tryParse(item['cantidad'] ?? '0') ?? 0;
          final precio = double.tryParse(item['precio'] ?? '0') ?? 0;
          
          if (producto != null && cantidad > 0 && precio > 0) { 
            detalleList.add(
              DetalleVenta(
                idDetalleVenta: item['idDetalleVenta'] as int? ?? 0, 
                idVenta: isEdit ? venta!.idVenta : 0,
                idProducto: producto.almcId ?? 0,
                cantidad: cantidad,
                precioUnitario: precio,
                subtotal: cantidad * precio,
              ),
            );
            total += cantidad * precio;
          }
        }
        
        if (clienteSeleccionado == null || clienteSeleccionado!.idCliente == 0) {
            throw Exception("Debe seleccionar un cliente.");
        }
        if (detalleList.isEmpty) {
            throw Exception("Debe agregar al menos un producto con cantidad y precio válidos.");
        }

        final ventaNueva = Venta(
          idVenta: isEdit ? venta!.idVenta : 0,
          idCliente: clienteSeleccionado?.idCliente ?? 0,
          idUsuario: int.tryParse(usuarioController.text) ?? 0,
          fechaVenta: DateTime.tryParse(fechaController.text) ?? DateTime.now(),
          total: total,
          ventaDetalle: detalleList,
        );

        if (isEdit) {
          await _ventaService.updateVenta(ventaNueva);
        } else {
          await _ventaService.createVenta(ventaNueva);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Venta ${isEdit ? "actualizada" : "creada"} correctamente.")),
        );
        
        _refresh(); 
        
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error al guardar: ${e.toString().replaceAll('Exception: ', '')}")));
      }
    }

    showCustomDialog(
      context: context,
      title: isEdit ? "Editar Venta #${venta!.idVenta}" : "Nueva Venta",
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<ClienteModel>(
                  value: clienteSeleccionado,
                  items: _clientes.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${c.nombre} ${c.apellido}'),
                    );
                  }).toList(),
                  onChanged: (v) => setDialogState(() => clienteSeleccionado = v),
                  decoration: const InputDecoration(labelText: 'Cliente'),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                    controller: usuarioController, 
                    label: "ID Usuario",
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                CustomTextField(
                    controller: fechaController, label: "Fecha Venta"),
                const Divider(),
                const Text("Productos", style: TextStyle(fontWeight: FontWeight.bold)),
                ...detalles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final productoSeleccionado = item['producto'] as ProductoModel?;
                  final cantidadController =
                      TextEditingController(text: item['cantidad']);
                  final precioController =
                      TextEditingController(text: item['precio']);
                  
                  cantidadController.addListener(() {
                    item['cantidad'] = cantidadController.text;
                  });
                  precioController.addListener(() {
                    item['precio'] = precioController.text;
                  });

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<ProductoModel>(
                            value: productoSeleccionado,
                            items: _productos.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(p.nombreProducto ?? 'Sin nombre'), 
                              );
                            }).toList(),
                            onChanged: (v) {
                              setDialogState(() {
                                item['producto'] = v;
                                item['precio'] =
                                    v?.almcPrecioVenta?.toStringAsFixed(2) ?? '';
                                precioController.text = item['precio']; 
                              });
                            },
                            decoration:
                                const InputDecoration(labelText: 'Producto'),
                          ),
                          const SizedBox(height: 6),
                          CustomTextField(
                              controller: cantidadController, 
                              label: "Cantidad",
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 6),
                          CustomTextField(
                              controller: precioController,
                              label: "Precio Unitario",
                              keyboardType: TextInputType.numberWithOptions(decimal: true)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setDialogState(() {
                                  detalles.removeAt(index);
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(), 
                TextButton.icon(
                  onPressed: () => _agregarProducto(setDialogState),
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar producto"),
                ),
              ],
            ),
          );
        },
      ),
      onSave: _calcularTotalYGuardar, 
    );
  }

  void _eliminarVenta(Venta venta) {
    showCustomDialog(
      context: context,
      title: "Eliminar Venta",
      content: Text("¿Seguro que deseas eliminar la venta #${venta.idVenta}?"),
      onSave: () async {
        try {
          await _ventaService.deleteVenta(venta.idVenta);
          _refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Venta eliminada correctamente.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al eliminar: ${e.toString().replaceAll('Exception: ', '')}")),
          );
          throw e; 
        }
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogo(),
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
             return Center(child: Text("Error al cargar ventas: ${snapshot.error.toString()}"));
          }

          return Column(
            children: [
              Expanded(
                child: ventasPagina.isEmpty
                    ? const Center(child: Text("No hay ventas registradas."))
                    : ListView.builder(
                        itemCount: ventasPagina.length,
                        itemBuilder: (context, index) {
                          final venta = ventasPagina[index];
                          final cliente = _clientes.firstWhere(
                              (c) => c.idCliente == venta.idCliente,
                              orElse: () => ClienteModel(
                                  nombre: 'Desconocido', apellido: ''));
                          
                          // Lógica para mostrar los productos 
                          String productosInfo = "Sin productos";
                          if (venta.ventaDetalle.isNotEmpty) {
                              final primerDetalle = venta.ventaDetalle.first;
                              final productoAsociado = _productos.firstWhere(
                                  (p) => p.almcId == primerDetalle.idProducto,
                                  orElse: () => ProductoModel(nombreProducto: 'Producto Desconocido')); 

                              productosInfo = "${primerDetalle.cantidad}x ${productoAsociado.nombreProducto ?? 'N/D'}";
                              
                              if (venta.ventaDetalle.length > 1) {
                                  productosInfo += " (+${venta.ventaDetalle.length - 1} más)";
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
                                "Total: \$${venta.total.toStringAsFixed(2)}\n",
                                style: fonts.bodySmall,
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
                                    icon:
                                        Icon(Icons.delete, color: colors.error),
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