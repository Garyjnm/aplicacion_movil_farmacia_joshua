import 'package:flutter/material.dart';
import '../../../data/models/categoria.dart';
import '../../../data/services/categoria_service.dart';
import '../../core/widgets/paginacion_controls.dart';
import '../../core/widgets/custom_create_button.dart';

// Pantalla principal para gestionar categorías
class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({Key? key}) : super(key: key);

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  // Servicio para las operaciones CRUD
  final CategoriaService _service = CategoriaService();

  // Variable que almacena las categorías futuras
  late Future<List<Categoria>> _futureCategorias;

  // Controladores para los campos de texto en el diálogo nombre y descripción
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Controlador de búsqueda

  // Variables para manejar la paginación
  int _currentPage = 1; // Página actual
  final int _itemsPerPage = 5; // Número de categorías por página

  // Lista filtrada según búsqueda
  List<Categoria> _filteredCategorias = [];

  @override
  void initState() {
    super.initState();

    // Inicializa la lista de categorías al cargar la pantalla
    _futureCategorias = _service.getCategorias();

    // Escucha cambios en el campo de búsqueda
    _searchController.addListener(() {
      setState(() {
        _filterCategorias();
      });
    });
  }

  // Refresca la lista de categorías
  void _refresh() {
    setState(() {
      _futureCategorias = _service.getCategorias();
    });
  }

  // Filtra las categorías según el texto ingresado
  void _filterCategorias() {
    final query = _searchController.text.toLowerCase();
    _filteredCategorias = _filteredCategorias
        .where((cat) =>
            cat.nombre.toLowerCase().contains(query) ||
            cat.descripcion.toLowerCase().contains(query))
        .toList();
  }

  // Ventana para agregar o editar
  void _mostrarDialogo({Categoria? categoria}) {
    if (categoria != null) {
      _nombreController.text = categoria.nombre;
      _descripcionController.text = categoria.descripcion;
    } else {
      _nombreController.clear();
      _descripcionController.clear();
    }

    // Muestra el diálogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFF4F4F4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          categoria == null ? "Agregar Categoría" : "Editar Categoría",
          style: TextStyle(color: Color(0xFF4D0A0F), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: "Nombre",
                labelStyle: TextStyle(color: Color(0xFF1B194B)),
                filled: true,
                fillColor: Color(0xFFE6F2F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            // Campo para la descripción
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: "Descripción",
                labelStyle: TextStyle(color: Color(0xFF1B194B)),
                filled: true,
                fillColor: Color(0xFFE6F2F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Botones Cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Color(0xFF4D0A0F))),
          ),
          // Botón Guardar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFBED6E3),
              foregroundColor: Color(0xFF1B194B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              if (categoria == null) {
                await _service.addCategoria(
                  Categoria(
                    nombre: _nombreController.text,
                    descripcion: _descripcionController.text,
                  ),
                );
              } else {
                // Actualiza la categoría existente
                await _service.updateCategoria(
                  categoria.idCategoria!,
                  Categoria(
                    idCategoria: categoria.idCategoria,
                    nombre: _nombreController.text,
                    descripcion: _descripcionController.text,
                  ),
                );
              }
              Navigator.pop(context);
              _refresh();
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // Confirmación para eliminar
  void _confirmarEliminar(Categoria categoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar Categoría"),
        content: Text("¿Seguro que deseas eliminar '${categoria.nombre}'?"),
        actions: [
          // Botón Cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Color(0xFF4D0A0F))),
          ),
          // Botón Eliminar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFBED6E3),
              foregroundColor: Color(0xFF1B194B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              await _service.deleteCategoria(categoria.idCategoria!);
              Navigator.pop(context);
              _refresh();
            },
            child: Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  // Construye la interfaz de usuario de la pantalla 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Color(0xFFE6F2F9),
        title: Text(
          "Categorías",
          style: TextStyle(color: Color(0xFF4D0A0F)),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1B194B)),
      ),
      body: FutureBuilder<List<Categoria>>(
        future: _futureCategorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text("No hay categorías"));
          // Lista completa de categorías
          final categorias = snapshot.data!;
          // Filtrar categorías por búsqueda
          final query = _searchController.text.toLowerCase();
          final filtered = categorias
              .where((cat) =>
                  cat.nombre.toLowerCase().contains(query) ||
                  cat.descripcion.toLowerCase().contains(query))
              .toList();
          // Cálculo de paginación y categorías a mostrar
          final totalPages = (filtered.length / _itemsPerPage).ceil();
          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = (_currentPage * _itemsPerPage).clamp(0, filtered.length);
          final categoriasPagina = filtered.sublist(startIndex, endIndex);
          // UI de la pantalla
          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar categoría...",
                    prefixIcon: Icon(Icons.search, color: Color(0xFF1B194B)),
                    filled: true,
                    fillColor: Color(0xFFE6F2F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Botón de agregar categoría
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CustomCreateButton(
                  label: "Agregar Categoría", // Texto que quieras mostrar
                  onPressed: () => _mostrarDialogo(), // Acción que hará el botón
                ),
              ),

              // Lista de categorías paginada
              Expanded(
                child: ListView.builder(
                  itemCount: categoriasPagina.length,
                  itemBuilder: (context, index) {
                    final categoria = categoriasPagina[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          categoria.nombre,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF4D0A0F)),
                        ),
                        subtitle: Text(
                          categoria.descripcion,
                          style: TextStyle(color: Color(0xFF1B194B), fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón Editar
                            IconButton(
                                icon: Icon(Icons.edit, color: Color(0xFF1B194B)),
                                onPressed: () => _mostrarDialogo(categoria: categoria)),
                            // Botón Eliminar
                            IconButton(
                                icon: Icon(Icons.delete, color: Color(0xFF4D0A0F)),
                                onPressed: () => _confirmarEliminar(categoria)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Paginación
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
          );
        },
      ),
    );
  }
}
