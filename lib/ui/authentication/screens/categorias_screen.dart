import 'package:flutter/material.dart';
import '../../../data/models/categoria.dart';
import '../../../data/services/categoria_service.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({Key? key}) : super(key: key);

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService _service = CategoriaService();
  late Future<List<Categoria>> _futureCategorias;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureCategorias = _service.getCategorias();
  }

  void _refresh() {
    setState(() {
      _futureCategorias = _service.getCategorias();
    });
  }

  //  ventana para agregar o editar
  void _mostrarDialogo({Categoria? categoria}) {
    if (categoria != null) {
      _nombreController.text = categoria.nombre;
      _descripcionController.text = categoria.descripcion;
    } else {
      _nombreController.clear();
      _descripcionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (categoria == null) {
                // Crear nueva
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
      appBar: AppBar(title: Text("Categorías")),
      body: FutureBuilder<List<Categoria>>(
        future: _futureCategorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No hay categorías"));

          final categorias = snapshot.data!;
          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return Card(
                child: ListTile(
                  title: Text(categoria.nombre),
                  subtitle: Text(categoria.descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarDialogo(categoria: categoria),
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogo(),
        child: Icon(Icons.add),
      ),
    );
  }
}
