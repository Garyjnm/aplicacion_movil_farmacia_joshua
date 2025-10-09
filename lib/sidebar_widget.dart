import 'package:aplicacion_movil_farmacia_joshua/ui/authentication/screens/usuarios_screen.dart';
import 'package:aplicacion_movil_farmacia_joshua/ui/core/routes/routes.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'ui/authentication/screens/categorias_screen.dart';
import 'data/repositories/auth_repository.dart';


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
            childrenPadding: EdgeInsets.only(left: 10),
            children: [
              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text("Productos"),
              ),
              ListTile(
                leading: Icon(Icons.category),
                title: Text("Categorias"),
                onTap: () {
                  Navigator.pop(context); // Cierra el drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriasScreen(),
                    ),
                  );
                },
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
          ListTile(leading: Icon(Icons.list), title: Text("Clientes")),
          ListTile(
           leading: const Icon(Icons.people),
            title: const Text("Usuarios"),
            onTap: () {
           Navigator.pop(context); // 👈 Cierra el Drawer
             Navigator.push(
                context,
                   MaterialPageRoute(
                      builder: (context) => const UsuariosScreen(),
                   ),
             );
             },
        ),

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
