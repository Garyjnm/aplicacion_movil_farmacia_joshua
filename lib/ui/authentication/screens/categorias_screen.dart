import 'package:flutter/material.dart'; // Importa Flutter para usar Widgets y Material Design
import '../../../data/models/categoria.dart'; // Modelo de datos Categoria
import '../../../data/services/categoria_service.dart'; // Servicio para operaciones CRUD de Categorias
import '../../core/widgets/paginacion_controls.dart'; // Widget personalizado para la paginación
import '../../core/widgets/custom_create_button.dart'; // Botón reutilizable para crear elementos
import '../../core/widgets/custom_card.dart'; // Card personalizado para mostrar elementos
import '../../core/widgets/custom_textfield.dart'; // TextField personalizado
import '../../core/widgets/custom_dialog.dart'; // Dialog personalizado

// Pantalla principal para gestionar categorías
class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({Key? key}) : super(key: key);

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService _service = CategoriaService(); // Servicio CRUD para categorías
  late Future<List<Categoria>> _futureCategorias; // Lista futura de categorías

  // Controladores de texto para los campos de diálogo
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Campo de búsqueda

  int _currentPage = 1; // Página actual en la paginación
  final int _itemsPerPage = 5; // Número de items por página

  @override
  void initState() {
    super.initState();
    _futureCategorias = _service.getCategorias(); // Inicializa la lista de categorías al cargar la pantalla
  }

  // Función para refrescar la lista de categorías
  void _refresh() {
    setState(() {
      _futureCategorias = _service.getCategorias();
    });
  }

  // Función para mostrar el diálogo de agregar o editar categoría
  void _mostrarDialogo({Categoria? categoria}) {
    if (categoria != null) {
      // Si se pasa una categoría, llenar los campos con sus datos
      _nombreController.text = categoria.nombre;
      _descripcionController.text = categoria.descripcion;
    } else {
      // Si no, limpiar los campos
      _nombreController.clear();
      _descripcionController.clear();
    }

    // Muestra un diálogo personalizado
    showCustomDialog(
      context: context,
      title: categoria == null ? "Agregar Categoría" : "Editar Categoría",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(controller: _nombreController, label: "Nombre"), // Campo nombre
          const SizedBox(height: 12), // Espacio entre campos
          CustomTextField(controller: _descripcionController, label: "Descripción"), // Campo descripción
        ],
      ),
      actions: [
        // Botón cancelar
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancelar", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
        // Botón guardar
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          onPressed: () async {
            if (categoria == null) {
              // Si no hay categoría, crear nueva
              await _service.addCategoria(Categoria(
                nombre: _nombreController.text,
                descripcion: _descripcionController.text,
              ));
            } else {
              // Si existe, actualizar
              await _service.updateCategoria(
                categoria.idCategoria!,
                Categoria(
                  idCategoria: categoria.idCategoria,
                  nombre: _nombreController.text,
                  descripcion: _descripcionController.text,
                ),
              );
            }
            Navigator.pop(context); // Cierra el diálogo
            _refresh(); // Refresca la lista
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }

  // Función para confirmar eliminación de categoría
  void _confirmarEliminar(Categoria categoria) {
    final colors = Theme.of(context).colorScheme;

    showCustomDialog(
      context: context,
      title: "Eliminar Categoría",
      content: Text("¿Seguro que deseas eliminar '${categoria.nombre}'?",
          style: TextStyle(color: colors.onSurface)), // Mensaje de confirmación
      actions: [
        // Botón cancelar
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancelar", style: TextStyle(color: colors.primary)),
        ),
        // Botón eliminar
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.onPrimaryContainer,
          ),
          onPressed: () async {
            await _service.deleteCategoria(categoria.idCategoria!); // Elimina categoría
            Navigator.pop(context); // Cierra el diálogo
            _refresh(); // Refresca la lista
          },
          child: const Text("Eliminar"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme; // Colores del tema actual
    final fonts = Theme.of(context).textTheme; // Tipografías del tema actual

    return Scaffold(
      backgroundColor: colors.surface, // Fondo de la pantalla
      appBar: AppBar(
        backgroundColor: colors.primaryContainer, // Color del AppBar
        title: Text("Categorías", style: fonts.titleMedium?.copyWith(color: colors.onPrimaryContainer)),
        iconTheme: IconThemeData(color: colors.onPrimaryContainer),
      ),
      body: FutureBuilder<List<Categoria>>(
        future: _futureCategorias, // Lista de categorías futura
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator()); // Muestra spinner mientras carga
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}")); // Muestra error si hay
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text("No hay categorías", style: fonts.bodyMedium)); // Mensaje si no hay datos

          final categorias = snapshot.data!; // Lista de categorías
          final query = _searchController.text.toLowerCase(); // Texto de búsqueda
          final filtered = categorias
              .where((cat) =>
                  cat.nombre.toLowerCase().contains(query) ||
                  cat.descripcion.toLowerCase().contains(query)) // Filtra por nombre o descripción
              .toList();

          // Paginación
          final totalPages = (filtered.length / _itemsPerPage).ceil(); // Total de páginas
          final startIndex = (_currentPage - 1) * _itemsPerPage; // Índice inicial
          final endIndex = (_currentPage * _itemsPerPage).clamp(0, filtered.length); // Índice final
          final categoriasPagina = filtered.sublist(startIndex, endIndex); // Sublista de la página actual

          return Column(
            children: [
              // Campo de búsqueda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomTextField(controller: _searchController, label: "Buscar categoría..."),
              ),
              // Botón para agregar categoría
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CustomCreateButton(
                  label: "Agregar Categoría",
                  onPressed: () => _mostrarDialogo(),
                ),
              ),
              // Lista de categorías paginadas
              Expanded(
                child: ListView.builder(
                  itemCount: categoriasPagina.length,
                  itemBuilder: (context, index) {
                    final categoria = categoriasPagina[index];
                    return CustomCard(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(categoria.nombre,
                            style: fonts.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(categoria.descripcion, style: fonts.bodyMedium),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit), // Botón editar
                              onPressed: () => _mostrarDialogo(categoria: categoria),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete), // Botón eliminar
                              onPressed: () => _confirmarEliminar(categoria),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Controles de paginación
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: PaginacionControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page; // Cambia de página
                    });
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
