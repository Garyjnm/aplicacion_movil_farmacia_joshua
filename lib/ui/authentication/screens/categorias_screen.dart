import 'package:flutter/material.dart';
import '../../../data/models/categoria.dart';
import '../../../data/services/categoria_service.dart';


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

  // Variables para manejar la paginación
  int _currentPage = 1; // Página actual
  final int _itemsPerPage = 5; // Número de categorías que se mostrarán por página

  @override
  void initState() {
    super.initState();

    // Inicializa la lista de categorías al cargar la pantalla
    _futureCategorias = _service.getCategorias();
  }

  // Refresca la lista de categorías
  void _refresh() {
    setState(() {
      _futureCategorias = _service.getCategorias();
    });
  }

  // Ventana para agregar o editar
  void _mostrarDialogo({Categoria? categoria}) {
    // Si categoria es null, estamos agregando una nueva categoría
    if (categoria != null) {
      _nombreController.text = categoria.nombre;
      _descripcionController.text = categoria.descripcion;
    } else {
      // Limpiar los controladores si es una nueva categoría
      _nombreController.clear();
      _descripcionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Título del diálogo
        title: Text(categoria == null ? "Agregar Categoría" : "Editar Categoría"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: "Descripción"),
            ),
          ],
        ),
        actions: [
          // Botón para cancelar y cerrar el diálogo
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          // Botón para guardar la categoría (nueva o editada)
          ElevatedButton(
            onPressed: () async {
              if (categoria == null) {
                // Crear nueva categoría
                await _service.addCategoria(
                  Categoria(
                    nombre: _nombreController.text,
                    descripcion: _descripcionController.text,
                  ),
                );
              } else {
                // Actualizar existente
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
        // Título del cuadro de confirmación
        title: Text("Eliminar Categoría"),
        content: Text("¿Seguro que deseas eliminar '${categoria.nombre}'?"),
        actions: [
          // Botón para cancelar y cerrar el cuadro
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          // Botón para confirmar la eliminación
          ElevatedButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la pantalla
      appBar: AppBar(title: Text("Categorías")),

      // Cuerpo de la pantalla con la lista de categorías
      body: FutureBuilder<List<Categoria>>(
        future: _futureCategorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No hay categorías"));

          // Lista completa de categorías obtenidas
          final categorias = snapshot.data!;

          // Calcular el total de páginas
          final totalPages = (categorias.length / _itemsPerPage).ceil();

          // Calcular inicio y fin de los índices para mostrar solo 5 categorías por página
          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = (_currentPage * _itemsPerPage).clamp(0, categorias.length);
          final categoriasPagina = categorias.sublist(startIndex, endIndex);

          return Column(
            children: [
              // Lista de categorías de la página actual
              Expanded(
                child: ListView.builder(
                  itemCount: categoriasPagina.length,
                  itemBuilder: (context, index) {
                    final categoria = categoriasPagina[index];
                    return Card(
                      child: ListTile(
                        // Muestra el nombre y descripción de la categoría
                        title: Text(categoria.nombre),
                        subtitle: Text(categoria.descripcion),
                        // Acciones para editar o eliminar la categoría
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón para editar la categoría
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _mostrarDialogo(categoria: categoria),
                            ),
                            // Botón para eliminar la categoría
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarEliminar(categoria),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Controles de paginación (botones con números)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  children: List.generate(totalPages, (index) {
                    final page = index + 1;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == page ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      child: Text("$page"),
                    );
                  }),
                ),
              )
            ],
          );
        },
      ),

      // Botón flotante para agregar una nueva categoría
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogo(),
        child: Icon(Icons.add),
      ),
    );
  }
}
