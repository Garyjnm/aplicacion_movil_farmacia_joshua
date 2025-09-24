import 'package:aplicacion_movil_farmacia_joshua/test.dart';
import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    return Drawer(
      child: ListView(
        children: [
          //Header del side bar
          DrawerHeader(
            decoration: BoxDecoration(color: colors.primary),
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
            leading: Icon(Icons.home, color: colors.onPrimary),
            title: Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlaceholderScreen(title: "Prueba"),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long, color: colors.onPrimary),
            title: Text("Ventas"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlaceholderScreen(title: "Ventas"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
