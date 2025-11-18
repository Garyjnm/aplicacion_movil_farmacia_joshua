import 'package:flutter/material.dart';
import '../../../data/models/categoria.dart';
import '../../../data/services/categoria_service.dart';
import '../../core/widgets/paginacion_controls.dart';
import '../../core/widgets/custom_create_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/custom_dialog.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService _service = CategoriaService();
  late Future<List<Categoria>> _futureCategorias;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  final int _itemsPerPage = 5;

  List<Categoria> _allCategorias = [];
  List<Categoria> _filteredCategorias = [];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    _searchController.addListener(_filterCategorias);
  }

  void _loadCategorias() {
    _futureCategorias = _service.getCategorias();
    _futureCategorias.then((data) {
      _allCategorias = data;
      _filteredCategorias = List.from(_allCategorias);
      setState(() {});
    });
  }

  void _refresh() {
    _loadCategorias();
  }

  void _filterCategorias() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredCategorias = List.from(_allCategorias);
    } else {
      _filteredCategorias = _allCategorias
          .where((cat) =>
              cat.nombre.toLowerCase().contains(query) ||
              cat.descripcion.toLowerCase().contains(query))
          .toList();
    }
    _currentPage = 1;
    setState(() {});
  }

  //  Diálogo Agregar / Editar Categoría
  void _mostrarDialogo({Categoria? categoria}) {
    if (categoria != null) {
      _nombreController.text = categoria.nombre;
      _descripcionController.text = categoria.descripcion;
    } else {
      _nombreController.clear();
      _descripcionController.clear();
    }

    showCustomDialog(
      context: context,
      title: categoria == null ? "Agregar Categoría" : "Editar Categoría",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(controller: _nombreController, label: "Nombre"),
          const SizedBox(height: 12),
          CustomTextField(controller: _descripcionController, label: "Descripción"),
        ],
      ),
      onSave: () async {
        if (categoria == null) {
          await _service.addCategoria(
            Categoria(
              nombre: _nombreController.text,
              descripcion: _descripcionController.text,
            ),
          );
        } else {
          await _service.updateCategoria(
            categoria.idCategoria!,
            Categoria(
              idCategoria: categoria.idCategoria,
              nombre: _nombreController.text,
              descripcion: _descripcionController.text,
            ),
          );
        }
        _refresh();
      },
    );
  }

  // Confirmar eliminación
  void _confirmarEliminar(Categoria categoria) {
    final colors = Theme.of(context).colorScheme;

    showCustomDialog(
      context: context,
      title: "Eliminar Categoría",
      content: Text(
        "¿Seguro que deseas eliminar '${categoria.nombre}'?",
        style: TextStyle(color: colors.onSurface),
      ),
      onSave: () async {
        await _service.deleteCategoria(categoria.idCategoria!);
        _refresh();
      },
      saveLabel: "Eliminar",
    );
  
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    final totalPages = (_filteredCategorias.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        (_currentPage * _itemsPerPage).clamp(0, _filteredCategorias.length);
    final categoriasPagina = _filteredCategorias.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Campo de búsqueda
          CustomTextField(
            controller: _searchController,
            label: "Buscar categoría...",
          ),
          const SizedBox(height: 8),
          // Botón agregar
          Align(
            alignment: Alignment.centerLeft,
            child: CustomCreateButton(
              label: "Agregar Categoría",
              onPressed: () => _mostrarDialogo(),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 8),
          //  Lista de categorías
          Expanded(
            child: _filteredCategorias.isEmpty
                ? Center(
                    child: Text(
                      "No hay categorías",
                      style: fonts.bodyMedium?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: categoriasPagina.length,
                    itemBuilder: (context, index) {
                      final categoria = categoriasPagina[index];
                      return CustomCard(
                        title: categoria.nombre,
                        subtitle: categoria.descripcion,
                        actions: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: Icon(
                              Icons.edit,
                              color: colors.secondaryContainer,
                            ),
                            onPressed: () => _mostrarDialogo(categoria: categoria),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: Icon(
                              Icons.delete,
                              color: colors.error,
                            ),
                            onPressed: () => _confirmarEliminar(categoria),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          //  Controles de paginación
          if (totalPages > 1)
            Padding(
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
        ],
      ),
    );
  }
}
