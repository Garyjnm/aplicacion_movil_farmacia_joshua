import 'package:flutter/material.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _roles = [
    {
      "nombre": "Administrador",
      "descripcion":
          "Tiene acceso total al sistema: gestiona usuarios, inventario, reportes y configuraciones.",
      "permiso": "Control Total",
    },
    {
      "nombre": "Vendedor",
      "descripcion":
          "Encargado de las ventas y atención al cliente. Puede consultar productos y registrar ventas.",
      "permiso": "Ventas",
    },
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    // Filtrar roles según la búsqueda
    final filteredRoles = _roles
        .where(
          (rol) =>
              rol["nombre"]!.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Buscar rol...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black87),
          ),
          style: const TextStyle(color: Colors.black87),
          cursorColor: Colors.black87,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredRoles.isEmpty
            ? Center(
                child: Text(
                  "No se encontraron roles",
                  style: fonts.bodyLarge?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              )
            : ListView.separated(
                itemCount: filteredRoles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final rol = filteredRoles[index];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: colors.primary.withOpacity(0.3),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black87, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 23,
                            backgroundColor: colors.primary.withOpacity(0.1),
                            child: Icon(
                              rol["nombre"] == "Administrador"
                                  ? Icons.admin_panel_settings
                                  : Icons.storefront_rounded,
                              color: colors.onSurface,
                              size: 25,
                            ),
                          ),
                        ),
                        title: Text(
                          rol["nombre"]!,
                          style: fonts.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rol["descripcion"]!,
                                style: fonts.bodyMedium?.copyWith(
                                  color: colors.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: [
                                  Chip(
                                    label: Text(rol["permiso"]!),
                                    backgroundColor: colors.onSurface
                                        .withOpacity(0.15),
                                    labelStyle: TextStyle(
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "Editar") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Editar rol: ${rol["nombre"]}"),
                                ),
                              );
                            } else if (value == "Eliminar") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Eliminar rol: ${rol["nombre"]}",
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "Editar",
                              child: Text("Editar"),
                            ),
                            const PopupMenuItem(
                              value: "Eliminar",
                              child: Text("Eliminar"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.onSurface,
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Agregar un nuevo rol")));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
