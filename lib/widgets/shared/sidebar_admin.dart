import 'package:flutter/material.dart';

class SidebarAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('Admin Menu')),
          ListTile(
            title: Text('Dashboard'),
            onTap: () => Navigator.pushNamed(context, '/admin'),
          ),
          ListTile(
            title: Text('Manage Products'),
            onTap: () => Navigator.pushNamed(context, '/manage-products'),
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
