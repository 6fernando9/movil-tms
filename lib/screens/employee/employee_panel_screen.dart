import 'package:flutter/material.dart';

class EmployeePanelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Employee Panel')),
            ListTile(
              title: Text('Orders to Deliver'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Update Stock'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Employee Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome Employee 👷', style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // lógica de pedidos asignados
              },
              child: Text('View Assigned Orders'),
            ),
            ElevatedButton(
              onPressed: () {
                // lógica de inventario
              },
              child: Text('Update Product Inventory'),
            ),
          ],
        ),
      ),
    );
  }
}
