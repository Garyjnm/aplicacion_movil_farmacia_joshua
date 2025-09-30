import 'package:flutter/material.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  final List<String> categorias = [
    "Antiinflamatorios",
    "Anticonceptivos",
    "Cuidado ocular",
    "Cuidado bucal",
    "Productos cosméticos",
  ];

  final TextEditingController _buscarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(  // Menú lateral
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Farmacia Joshua',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("CATEGORÍAS"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Buscar Categorías
            TextField(
              controller: _buscarController,
              decoration: InputDecoration(
                hintText: "Buscar Categorías",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Botón Agregar Categoría
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                // Acción para agregar categoría
              },
              icon: const Icon(Icons.add),
              label: const Text("Agregar Categorías"),
            ),

            const SizedBox(height: 10),

            // Lista de Categorías
            Expanded(
              child: ListView.builder(
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.lightBlue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(categorias[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black87),
                            onPressed: () {
                              // Acción editar
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.black87),
                            onPressed: () {
                              setState(() {
                                categorias.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Paginación (ejemplo simple)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("1"),
                const SizedBox(width: 8),
                TextButton(onPressed: () {}, child: const Text("2")),
                TextButton(onPressed: () {}, child: const Text("3")),
                const Text("..."),
                TextButton(onPressed: () {}, child: const Text("67")),
                TextButton(onPressed: () {}, child: const Text("68")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
