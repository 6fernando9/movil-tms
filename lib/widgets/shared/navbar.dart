import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.cyan[800], // Color celeste eléctrico
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          // Lógica para mostrar el menú
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Text('Mudanzas', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Lógica para búsqueda
          },
        ),
      ],
    );
  }
}
