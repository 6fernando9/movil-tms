import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/auth_guard.dart';

class ChoferPanelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AuthGuard(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.cyan[800],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person_pin, size: 50, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Chofer: ${authProvider.nombre ?? ""}',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Pedidos Asignados'),
                onTap: () {
                  // lógica futura para ver pedidos
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Cerrar sesión'),
                onTap: () => authProvider.logout(context),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.cyan[800],
          title: Text('Panel de Chofer'),
        ),
        body: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset('assets/coco.png', fit: BoxFit.cover),
            ),
            Container(color: Colors.black.withOpacity(0.6)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping, size: 80, color: Colors.orangeAccent),
                  SizedBox(height: 20),
                  Text(
                    'Bienvenido ${authProvider.nombre ?? ""} 👷‍♂️',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // lógica para ir a pedidos
                    },
                    icon: Icon(Icons.assignment),
                    label: Text('Ver Pedidos Asignados'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
