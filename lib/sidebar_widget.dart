import 'package:flutter/material.dart';
import 'ui/authentication/screens/roles_screens.dart'; // Asegúrate de importar tu pantalla de Roles

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: colors.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del sidebar
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: colors.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/gary.jpg'),
                ),
                const SizedBox(height: 10),
                Text('Rene Alexander', style: fonts.bodyLarge),
                Text('renealexander@gmail.com', style: fonts.bodyMedium),
              ],
            ),
          ),
          // Home
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
            },
          ),
          // Ventas
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text("Ventas"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Compras
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text("Compras"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Inventario
          ExpansionTile(
            collapsedBackgroundColor: colors.primary,
            iconColor: colors.onPrimary,
            leading: Icon(Icons.inventory),
            title: Text("Inventario"),
            childrenPadding: const EdgeInsets.only(left: 10),
            children: [
              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text("Productos"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.category),
                title: Text("Categorias"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.local_shipping),
                title: Text("Proveedores"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment_ind),
                title: Text("Roles"),
                onTap: () {
                  Navigator.pop(context); // Cierra el drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RolesScreens(),
                    ),
                  );
                },
              ),
            ],
          ),
          // Clientes
          ListTile(
            leading: Icon(Icons.list),
            title: Text("Clientes"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Usuarios
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Usuarios"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Configuración
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Configuracion"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Soporte
          ListTile(
            leading: Icon(Icons.help),
            title: Text("Soporte"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Cerrar sesión
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Cerrar Sesion"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
