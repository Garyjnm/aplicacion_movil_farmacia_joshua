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

  // Variable que almacena las categorías furturas
  late Future<List<Categoria>> _futureCategorias;

  // Controladores para los campos de texto en el diálogo nombre y descripción
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

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

  //  ventana para agregar o editar
  void _mostrarDialogo({Categoria? categoria}) {
   // Si categoria es null, estamos agregando una nueva categoría
    if (categoria != null) {
      _nombreController.text = categoria.nombre;
      _descripcionController.text = categoria.descripcion;
    } else {
      //limpiar los controladores si es una nueva categoría
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
          // Botón para guardar la categoría (nuevo o editado)
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

  //  Confirmación para eliminar
  void _confirmarEliminar(Categoria categoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar Categoría"),
        content: Text("¿Seguro que deseas eliminar '${categoria.nombre}'?"),
        actions: [
          // Botón para cancelar y cerrar el diálogo
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
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
      // Barra de superior de la pantalla
      appBar: AppBar(title: Text("Categorías")),

      // Cuerpo de la pantalla con la lista de categorías
      body: FutureBuilder<List<Categoria>>(
        future: _futureCategorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No hay categorías"));

          // Muestra la lista de categorías
          final categorias = snapshot.data!;
          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
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
