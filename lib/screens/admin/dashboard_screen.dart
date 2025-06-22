// dashboard_screen.dart
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Text('Admin Panel')),
            ListTile(title: Text('Dashboard')),
            ListTile(title: Text('Manage Products')),
            ListTile(title: Text('Logout')),
          ],
        ),
      ),
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(child: Text('Welcome Admin')),
    );
  }
}
