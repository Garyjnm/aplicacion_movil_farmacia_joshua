import 'package:flutter/material.dart';
import '../../../data/models/producto.dart'; 
import '../../../data/services/producto_service.dart'; 
import '../../core/widgets/paginacion_controls.dart';
import '../../core/widgets/custom_create_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/custom_dialog.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ProductosScreen extends StatefulWidget {
  static const String routeName = '/Productos';
  const ProductosScreen({Key? key}) : super(key: key);

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _service = ProductoService();
  late Future<List<ProductoModel>> _futureProductos; 

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioVentaController = TextEditingController();
  final TextEditingController _existenciaController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  final int _itemsPerPage = 5; 

  List<ProductoModel> _allProductos = []; 
  List<ProductoModel> _filteredProductos = []; 

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _searchController.addListener(_filterProductos);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProductos);
    _searchController.dispose();
    _nombreController.dispose();
    _precioVentaController.dispose();
    _existenciaController.dispose();
    super.dispose();
  }


  void _loadProductos() {
    _futureProductos = _service.getProductos(); 
    _futureProductos.then((data) {
      _allProductos = data;
      _filterProductos(); 
      setState(() {});
    }).catchError((error) {
      print("Error al cargar productos: $error");
      setState(() {
        _allProductos = [];
        _filteredProductos = [];
      });
    });
  }

  void _refresh() {
    _loadProductos();
  }

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredProductos = List.from(_allProductos);
    } else {
      _filteredProductos = _allProductos
          .where((producto) =>
              (producto.nombreProducto ?? '').toLowerCase().contains(query) ||
              (producto.detalleDescripcion ?? '').toLowerCase().contains(query))
          .toList();
    }
    _currentPage = 1; 
    setState(() {});
  }


  void _mostrarDialogo({ProductoModel? producto}) {
    // Inicializar controladores
    if (producto != null) {
      _nombreController.text = producto.nombreProducto ?? '';
      _precioVentaController.text = (producto.almcPrecioVenta ?? 0.0).toStringAsFixed(2);
      _existenciaController.text = (producto.almcExistencia ?? 0).toString();
    } else {
      _nombreController.clear();
      _precioVentaController.clear();
      _existenciaController.clear();
    }

    showCustomDialog(
      context: context,
      title: producto == null ? "Agregar Producto" : "Editar Producto",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // NOTA: El nombre no se edita en la tabla ProductoAlmacenado.
          CustomTextField(controller: _nombreController, label: "Nombre "),
          const SizedBox(height: 12),
          CustomTextField(controller: _precioVentaController, label: "Precio Venta", keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          CustomTextField(controller: _existenciaController, label: "Existencia", keyboardType: TextInputType.number),
        ],
      ),
      onSave: () async {
        final int detalleId = producto?.almcDetalleId ?? 1; 
        final int proveedorId = producto?.almcProveedorId ?? 1;

        final newProducto = ProductoModel(
          almcId: producto?.almcId, 
          almcDetalleId: detalleId, 
          almcProveedorId: proveedorId, 
          almcLote: producto?.almcLote ?? 'LOTE_DEF', 
          almcExistencia: int.tryParse(_existenciaController.text),
          almcPrecioCompra: producto?.almcPrecioCompra ?? 0.0, 
          almcPrecioVenta: double.tryParse(_precioVentaController.text),
          almcEstado: producto?.almcEstado ?? true,
        );

        if (producto == null) {
          await _service.addProducto(newProducto);
        } else {
          await _service.updateProducto(producto.almcId!, newProducto); 
        }
        _refresh();
      },
      saveLabel: producto == null ? "Guardar" : "Actualizar",
    );
  }

  void _confirmarEliminar(ProductoModel producto) {
    final colors = Theme.of(context).colorScheme;

    showCustomDialog(
      context: context,
      title: "Eliminar Producto",
      content: Text(
        "¿Seguro que deseas eliminar la entrada de inventario para '${producto.nombreProducto ?? 'Producto sin nombre'}' (ID: ${producto.almcId})?",
        style: TextStyle(color: colors.onSurface),
      ),
      onSave: () async {
        await _service.deleteProducto(producto.almcId!); 
        _refresh();
      },
      saveLabel: "Eliminar",
    );
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    final totalPages = (_filteredProductos.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage).clamp(0, _filteredProductos.length);
    final productosPagina = _filteredProductos.sublist(startIndex, endIndex);

    return Column(
        children: [
        // Barra superior con buscador y botón refrescar (opcional)
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _searchController,
                  label: "Buscar producto por nombre o descripción...",
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refrescar',
                onPressed: _refresh,
              ),
            ],
          ),
        ),
          // Campo de búsqueda
        // (Ya integrado arriba en la fila)
          // Botón agregar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomCreateButton(
              label: "Agregar Producto",
              onPressed: () => _mostrarDialogo(),
              alignment: Alignment.centerLeft,
            ),
          ),
          // Lista de productos
        Expanded(
            child: FutureBuilder<List<ProductoModel>>(
              future: _futureProductos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                   return Center(child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center));
                }

                if (_allProductos.isEmpty) {
                   return Center(child: Text("No hay productos en inventario.", style: fonts.bodyMedium));
                }
                
                if (_filteredProductos.isEmpty) {
                    return Center(child: Text("No se encontraron resultados para la búsqueda.", style: fonts.bodyMedium));
                }

                return ListView.builder(
                  itemCount: productosPagina.length,
                  itemBuilder: (context, index) {
                    final producto = productosPagina[index];
                    return CustomCard(
                      title: producto.nombreProducto ?? 'Producto sin nombre',
                      subtitle: 'Existencia: ${producto.almcExistencia ?? 0} | Precio Venta: \$${(producto.almcPrecioVenta ?? 0.0).toStringAsFixed(2)}',
                      bodyLines: [
                        'Vencimiento: ${producto.detalleFechaVencimiento != null ? 
                          '${producto.detalleFechaVencimiento!.day.toString().padLeft(2, '0')}/${producto.detalleFechaVencimiento!.month.toString().padLeft(2, '0')}/${producto.detalleFechaVencimiento!.year.toString()}' : 'N/A'}',
                        'ID Inventario: ${producto.almcId ?? 'N/A'} | Lote: ${producto.almcLote ?? 'N/A'}',
                      ],
                      actions: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: Icon(Icons.edit, color: colors.secondaryContainer),
                          onPressed: () => _mostrarDialogo(producto: producto),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: Icon(Icons.delete, color: colors.error),
                          onPressed: () => _confirmarEliminar(producto),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // Controles de paginación
          if (totalPages > 1)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: PaginacionControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ),
            ),
        ],
      );
  }
}