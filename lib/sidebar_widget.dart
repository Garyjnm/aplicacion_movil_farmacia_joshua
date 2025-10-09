import 'package:aplicacion_movil_farmacia_joshua/data/repositories/auth_repository.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/roles_screen.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/usuarios_screen.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/core/routes/routes.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'ui/authentication/screens/categorias_screen.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  void _logout(BuildContext context) async {
    if (context.mounted && Navigator.canPop(context)) {//Se cierra el sidebar junto a la session si no da error
      Navigator.pop(context);
    }

    try{
      final authRepository = AuthRepository();//Se crea una instancia del repositorio
      await authRepository.logout();//Se llama a la funcion logout del repositorio

      if (!context.mounted) return;//Verifica que el contexto siga siendo valido

      context.router.replace(const LoginRoute());//Navega a la pantalla de login y reemplaza la pila de navegacion
      
    }catch(e){
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: ${e.toString()}'),
        ),
      );
    }
  }

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
          //Elementos del sidebar
          //Home
          ListTile(leading: Icon(Icons.home), title: Text("Home")),
          //Ventas
          ListTile(leading: Icon(Icons.receipt_long), title: Text("Ventas")),
          //Compras
          ListTile(leading: Icon(Icons.shopping_cart), title: Text("Compras")),
          //Inventario
          ExpansionTile(
            collapsedBackgroundColor: colors.primary,
            iconColor: colors
                .onPrimary, //Color del icono de la derecha cuando esta expandido
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
                      builder: (context) => const RolesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          //Clientes
          ListTile(leading: Icon(Icons.list), title: Text("Clientes")),
          ListTile(leading: Icon(Icons.people), title: Text("Usuarios")),
          //Configuracion
          ListTile(leading: Icon(Icons.settings), title: Text("Configuracion")),
          ListTile(leading: Icon(Icons.help), title: Text("Soporte")),
          //Cerrar sesion
          ListTile(leading: Icon(Icons.logout),title: Text("Cerrar Sesion",),
            onTap: () => _logout(context), // CONECTADO A LA FUNCIÓN DE LOGOUT
          ),
          //ListTile(leading: Icon(Icons.logout), title: Text("Cerrar Sesion")),
        ],
      ),
    );
  }
}
