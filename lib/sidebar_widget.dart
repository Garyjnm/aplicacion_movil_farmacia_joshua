import 'package:aplicacion_movil_farmacia_joshua/ui/core/routes/routes.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'data/repositories/auth_repository.dart';
import 'data/models/role.dart';


class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  void _logout(BuildContext context) async {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    try{
      final authRepository = AuthRepository();
      await authRepository.logout();

      if (!context.mounted) return;

      context.router.replace(const LoginRoute());
      
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
      child: FutureBuilder<Role>(
        future: AuthRepository().getCurrentRole(),
        builder: (context, snapshot) {
          final role = snapshot.data ?? Role.unknown;
          return ListView(
        padding: EdgeInsets.zero,
        children: [
          //Header del side bar
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: colors.primaryContainer),
            child: FutureBuilder<String>(
              future: AuthRepository().getUserShortName(),
              builder: (context, userSnap) {
                final fullName = userSnap.data ?? 'Usuario';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundImage: AssetImage('assets/images/gary.jpg'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName,
                      style: fonts.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: (fonts.bodyLarge?.fontSize ?? 16) + 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
          //Elementos del sidebar
          //Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context); 
              context.router.replace(const HomeRoute());
            },
          ),
          //Ventas
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text("Ventas"),
            onTap: () {
              Navigator.pop(context); 
              context.router.navigate(const VentasRoute());
            },
          ),
          //Compras (solo admin)
          if (role.isAdmin)
            ListTile(leading: Icon(Icons.shopping_cart), title: Text("Compras")),
          //Inventario (solo admin)
          if (role.isAdmin)
            ExpansionTile(
              collapsedBackgroundColor: colors.primary,
              iconColor: colors.onPrimary,
              leading: Icon(Icons.inventory),
              title: Text("Inventario"),
              childrenPadding: EdgeInsets.only(left: 10),
              children: [
                ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text("Productos"),
                  onTap: () {
                    Navigator.pop(context);
                    context.router.replace(const ProductosRoute());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.category),
                  title: Text("Categorias"),
                  onTap: () {
                    Navigator.pop(context);
                    context.router.navigate(const CategoriasRoute());
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
          //Clientes (visible para admin y vendedor)
          ListTile(
            leading: Icon(Icons.list), 
            title: Text("Clientes"),
            onTap: () {
              Navigator.pop(context);
              context.router.replace(const ClientesRoute());
            },
          ),
          
          //Usuarios solo visible para admin
          if (role.isAdmin)
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Usuarios"),
              onTap: () {
                Navigator.pop(context);
                context.router.replace(const UsuariosRoute());
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
      );
        },
      ),
    );
  }
}
