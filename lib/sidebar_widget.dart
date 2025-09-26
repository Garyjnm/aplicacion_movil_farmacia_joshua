import 'package:flutter/material.dart';

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
          //Header del side bar
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: colors.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  //avatar de prueba
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/gary.jpg'),
                ),
                const SizedBox(height: 10),
                Text('Rene Alexander', style: fonts.bodyLarge),
                Text('renealexander@gmail.com', style: fonts.bodyMedium),
              ],
            ),
          ),
          //Elementos del sidebar
          //Home
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
          ),
          //Ventas
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text("Ventas"),
          ),
          //Compras
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text("Compras"),
          ),
          //Inventario
          ExpansionTile(
            collapsedBackgroundColor: colors.primary,
            iconColor: colors.onPrimary, //Color del icono de la derecha cuando esta expandido
            leading: Icon(Icons.inventory),
            title: Text("Inventario"),
            childrenPadding: EdgeInsets.only(left: 10),
            children: [
              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text("Productos"),
              ),
              ListTile(
                leading: Icon(Icons.category),
                title: Text("Categorias"),
              ),
              ListTile(
                leading: Icon(Icons.local_shipping),
                title: Text("Proveedores"),
              ),
              ListTile(
                leading: Icon(Icons.assignment_ind),
                title: Text("Roles"),
              ),
            ],
          ),
          //Clientes
          ListTile(
            leading: Icon(Icons.list),
            title: Text("Clientes"),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Usuarios"),
          ),
          //Configuracion
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Configuracion"),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text("Soporte"),
          ),
          //Cerrar sesion
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Cerrar Sesion"),
          ),
        ],
      ),
    );
  }
}
