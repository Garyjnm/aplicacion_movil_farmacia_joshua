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
            decoration: BoxDecoration(
              color: colors.primary
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar( //avatar de prueba
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/gary.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Rene Alexander',
                  //TODO
                )
              ],)
          )
        ],
      )
    );
  }
}
