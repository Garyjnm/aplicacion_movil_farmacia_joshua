import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CategoriasScreen(),
    );
  }
}

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({Key? key}) : super(key: key);
  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<String> categorias = [
    "Antiinflamatorios",
    "Anticonceptivos",
    "Cuidado ocular",
    "Cuidado bucal",
    "Productos cosmeticos",
  ];

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            //  Image.network(
            //'https://i.imgur.com/yourLogo.png', // reemplaza con tu logo
            // height: 40,
            // ),
            SizedBox(width: 10),
            Text('Farmacia Joshua'),
          ],
        ),
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buscador
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Categorias',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Botón agregar categoría
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para agregar categoría
              },
              icon: Icon(Icons.add),
              label: Text('Agregar Categorias'),
            ),
            SizedBox(height: 10),
            // Lista de categorías
            Expanded(
              child: ListView.builder(
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(categorias[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Lógica para editar
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Lógica para eliminar
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Paginación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: index == 0
                          ? Colors.blue
                          : Colors.grey[300],
                      minimumSize: Size(40, 40),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index == 0 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
