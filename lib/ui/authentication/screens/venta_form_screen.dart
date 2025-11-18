import 'package:flutter/material.dart';
import '../../../data/models/venta.dart';
import '../../../data/models/detalle_venta.dart';
import '../../../data/models/cliente.dart';
import '../../../data/models/producto.dart';
import '../../../data/services/venta_service.dart';
import '../../../data/services/cliente_service.dart';
import '../../../data/services/producto_service.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/custom_dialog.dart';

// Auxiliar: item seleccionado en la UI
class _ProductoSeleccionado {
  final ProductoModel producto;
  final int cantidad;
  final int? idDetalleVenta; // null => nuevo detalle

  _ProductoSeleccionado({
    required this.producto,
    required this.cantidad,
    this.idDetalleVenta,
  });

  _ProductoSeleccionado copyWith({
    ProductoModel? producto,
    int? cantidad,
    int? idDetalleVenta,
  }) {
    return _ProductoSeleccionado(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      idDetalleVenta: idDetalleVenta ?? this.idDetalleVenta,
    );
  }
}

class VentaFormScreen extends StatefulWidget {
  final Venta? venta;

  const VentaFormScreen({Key? key, this.venta}) : super(key: key);

  @override
  State<VentaFormScreen> createState() => _VentaFormScreenState();
}

class _VentaFormScreenState extends State<VentaFormScreen>
    with SingleTickerProviderStateMixin {
  final ClientesService _clienteService = ClientesService();
  final ProductoService _productoService = ProductoService();
  final VentaService _ventaService = VentaService();

  List<ClienteModel> _clientes = [];
  List<ProductoModel> _productos = [];

  ClienteModel? _clienteSeleccionado;
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  bool _cargando = true;
  late TabController _tabController;

  // Productos elegidos en la venta (conserva idDetalleVenta si ya existe)
  List<_ProductoSeleccionado> _productosSeleccionados = [];
  // Mantener los ids de detalles eliminados cuando estamos editando
  final List<int> _detallesEliminados = [];

  // Para agregar nuevos productos
  ProductoModel? _productoParaAgregar;
  final TextEditingController _cantidadParaAgregarCtrl =
      TextEditingController(text: '1');

  bool get isEdit => widget.venta != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final clientes = await _clienteService.getClientes();
      final productos = await _productoService.getProductos();

      // Seleccionar primer cliente si existe (solo para nueva venta)
      _clienteSeleccionado = clientes.isNotEmpty ? clientes.first : null;

      if (isEdit) {
        final v = widget.venta!;

        // Seleccionar el cliente de la venta (si existe en el catálogo)
        try {
          _clienteSeleccionado =
              clientes.firstWhere((c) => c.idCliente == v.idCliente);
        } catch (_) {
          // Si no se encuentra, se mantiene el que estaba (o null)
        }

        _usuarioController.text = v.idUsuario.toString();
        // Solo fecha YYYY-MM-DD
        _fechaController.text = v.fechaVenta.toIso8601String().substring(0, 10);

        // Cargar detalles existentes en la lista editable
        for (var det in v.ventaDetalle) {
          // Intentar recuperar el producto del catálogo
          final prod = _buscarProductoPorId(productos, det.idProducto) ??
              ProductoModel(
                almcId: det.idProducto,
                nombreProducto: 'Producto Desconocido',
                almcPrecioVenta: det.precioUnitario,
              );

          _productosSeleccionados.add(
            _ProductoSeleccionado(
              producto: prod,
              cantidad: det.cantidad,
              idDetalleVenta: det.idDetalleVenta,
            ),
          );
        }
      } else {
        // Nueva venta
        _fechaController.text = DateTime.now().toIso8601String().substring(0, 10);
        if (_usuarioController.text.isEmpty) {
          _usuarioController.text = '1';
        }
      }

      setState(() {
        _clientes = clientes;
        _productos = productos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
      Navigator.of(context).pop();
    }
  }

  ProductoModel? _buscarProductoPorId(List<ProductoModel> lista, int id) {
    try {
      return lista.firstWhere((p) => (p.almcId ?? 0) == id);
    } catch (_) {
      return null;
    }
  }

  double _calcularTotal() {
    double total = 0;
    for (var p in _productosSeleccionados) {
      final precio = p.producto.almcPrecioVenta ?? 0.0;
      total += precio * p.cantidad;
    }
    return total;
  }

  void _agregarProductoALista() {
    if (_productoParaAgregar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione un producto para agregar')));
      return;
    }

    final cantidad = int.tryParse(_cantidadParaAgregarCtrl.text) ?? 0;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('La cantidad debe ser un número entero positivo')));
      return;
    }

    setState(() {
      final existenteIndex = _productosSeleccionados
          .indexWhere((e) => e.producto.almcId == _productoParaAgregar!.almcId);

      if (existenteIndex >= 0) {
        // Si ya existe en la lista, sumamos cantidad, conservando idDetalleVenta
        final actual = _productosSeleccionados[existenteIndex];
        _productosSeleccionados[existenteIndex] =
            actual.copyWith(cantidad: actual.cantidad + cantidad);
      } else {
        // Nuevo item; idDetalleVenta: null para que el backend lo cree
        _productosSeleccionados.add(
          _ProductoSeleccionado(
            producto: _productoParaAgregar!,
            cantidad: cantidad,
            idDetalleVenta: null,
          ),
        );
      }

      _productoParaAgregar = null;
      _cantidadParaAgregarCtrl.text = '1';
    });
  }

  void _confirmarEliminarProducto(int index) {
    final item = _productosSeleccionados[index];
    final nombreProducto = item.producto.nombreProducto ?? 'este producto';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
            '¿Seguro que deseas eliminar "$nombreProducto" de la lista de venta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                // Si estamos editando y el detalle existe en backend, marcar para eliminar
                if (isEdit && (item.idDetalleVenta ?? 0) > 0) {
                  _detallesEliminados.add(item.idDetalleVenta!);
                }
                _productosSeleccionados.removeAt(index);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editarCantidadIndex(int index) {
    final item = _productosSeleccionados[index];
    final controller = TextEditingController(text: item.cantidad.toString());

    showCustomDialog(
      context: context,
      title: 'Editar Cantidad',
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Nueva Cantidad'),
      ),
      onSave: () async {
        final nueva = int.tryParse(controller.text) ?? 0;
        if (nueva <= 0) {
          throw 'La cantidad debe ser un número entero positivo.';
        }
        setState(() {
          _productosSeleccionados[index] = item.copyWith(cantidad: nueva);
        });
      },
      saveLabel: 'Aplicar',
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatFechaHora(DateTime dt) {
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}';
  }

  Future<bool?> _mostrarConfirmacionVenta() async {
    final fechaSolo =
        DateTime.tryParse(_fechaController.text) ?? DateTime.now();
    final ahora = DateTime.now();
    final fechaHora = DateTime(
        fechaSolo.year, fechaSolo.month, fechaSolo.day, ahora.hour, ahora.minute, ahora.second);
    final total = _calcularTotal();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;
        final text = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, 24 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Icon(Icons.check_circle, size: 56, color: colors.primaryContainer),
                const SizedBox(height: 8),
                Text(
                  isEdit ? 'Confirmar cambios' : 'Confirmar Venta',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fecha y hora', style: text.bodyMedium),
                    Text(
                      _formatFechaHora(fechaHora),
                      style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Importe a pagar', style: text.bodyMedium),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(isEdit ? 'Actualizar venta' : 'Confirmar venta'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performSave() async {
    if (_clienteSeleccionado == null) {
      throw 'ERROR: Debe seleccionar un cliente.';
    }
    if (_productosSeleccionados.isEmpty) {
      throw 'ERROR: Debe agregar al menos un producto para la venta.';
    }
    if (!isEdit &&
        (int.tryParse(_usuarioController.text) == null ||
            int.tryParse(_usuarioController.text)! <= 0)) {
      throw 'ERROR: El campo ID Usuario debe ser un número entero positivo.';
    }

    // Mapear items seleccionados a DetalleVenta, preservando idDetalleVenta si existe.
    final List<DetalleVenta> detalles = _productosSeleccionados.map((p) {
      final precio = p.producto.almcPrecioVenta ?? 0.0;
      return DetalleVenta(
        idDetalleVenta: p.idDetalleVenta, // null => nuevo
        idVenta: isEdit ? widget.venta!.idVenta : 0, // backend usualmente ignora en create
        idProducto: p.producto.almcId ?? 0,
        cantidad: p.cantidad,
        precioUnitario: precio,
        subtotal: p.cantidad * precio,
      );
    }).toList();

    final venta = Venta(
      idVenta: isEdit ? widget.venta!.idVenta : 0,
      idCliente: _clienteSeleccionado!.idCliente!,
      idUsuario: isEdit
          ? widget.venta!.idUsuario
          : int.parse(_usuarioController.text),
      fechaVenta: DateTime.parse(_fechaController.text),
      total: _calcularTotal(),
      ventaDetalle: detalles,
    );

    if (isEdit) {
      await _ventaService.updateVenta(
        venta,
        detallesEliminados: _detallesEliminados,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta actualizada correctamente')),
      );
    } else {
      await _ventaService.createVenta(venta);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta creada correctamente')),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _guardarVenta() async {
    try {
      if (_clienteSeleccionado == null || _productosSeleccionados.isEmpty) {
        throw 'Debe seleccionar un cliente y agregar al menos un producto.';
      }
      final ok = await _mostrarConfirmacionVenta();
      if (ok == true) {
        await _performSave();
      }
    } on String catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _fechaController.dispose();
    _cantidadParaAgregarCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(isEdit ? 'Editar Venta' : 'Nueva Venta'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Datos'), Tab(text: 'Productos')],
          labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.65),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          indicatorColor: Theme.of(context).colorScheme.secondary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Datos
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<ClienteModel>(
                  value: _clienteSeleccionado,
                  items: _clientes.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${c.nombre ?? ''} ${c.apellido ?? ''}'.trim()),
                    );
                  }).toList(),
                  onChanged: isEdit
                      ? null
                      : (v) => setState(() => _clienteSeleccionado = v),
                  decoration: const InputDecoration(labelText: 'Cliente *'),
                ),
                const SizedBox(height: 12),
                // En edición no permitimos modificar el usuario
                CustomTextField(
                  controller: _usuarioController,
                  label: 'ID Usuario *',
                  keyboardType: TextInputType.number,
                  readOnly: isEdit,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final current =
                        DateTime.tryParse(_fechaController.text) ?? DateTime.now();
                    final pick = await showDatePicker(
                      context: context,
                      initialDate: current,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pick != null) {
                      setState(() {
                        _fechaController.text =
                            pick.toIso8601String().substring(0, 10);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _fechaController,
                      label: 'Fecha de venta',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total: \$${_calcularTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _guardarVenta,
                      icon: const Icon(Icons.save),
                      label: Text(isEdit ? 'Actualizar' : 'Guardar Venta'),
                    )
                  ],
                ),
              ],
            ),
          ),

          // Tab Productos
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Agregar producto',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<ProductoModel>(
                  value: _productoParaAgregar,
                  isExpanded: true,
                  menuMaxHeight: 400,
                  items: _productos.map((p) {
                    final precio = p.almcPrecioVenta?.toStringAsFixed(2) ?? '0.00';
                    final nombre = p.nombreProducto ?? 'Sin nombre';
                    return DropdownMenuItem(
                      value: p,
                      child: Text('$nombre — \$ $precio'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _productoParaAgregar = v),
                  decoration: const InputDecoration(
                    hintText: 'Producto',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _cantidadParaAgregarCtrl,
                        label: 'Cantidad',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _agregarProductoALista,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Productos agregados (${_productosSeleccionados.length}) *',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (_productosSeleccionados.isEmpty)
                  const Text(
                      'No hay productos agregados. Debe agregar al menos uno para guardar la venta.'),
                ..._productosSeleccionados.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final precio = item.producto.almcPrecioVenta ?? 0.0;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title:
                          Text(item.producto.nombreProducto ?? 'Sin nombre'),
                      subtitle: Text(
                          'Cantidad: ${item.cantidad}  •  Precio: \$${precio.toStringAsFixed(2)}  •  Subtotal: \$${(precio * item.cantidad).toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editarCantidadIndex(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarEliminarProducto(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}