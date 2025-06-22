import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../data/vehiculo_info.dart'; // Asegúrate que este archivo existe

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<PageController> _controllers = List.generate(
    vehiclesveinfo.length,
    (index) => PageController(),
  );

  String _categoriaSeleccionada = 'Todos';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      drawer: _buildDrawer(context, auth),
      appBar: _buildAppBar(context, auth),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.cyan.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBanner(),
              SizedBox(height: 20),
              _buildFiltroCategoria(),
              SizedBox(height: 20),
              _buildCatalogoFiltrado(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/vehiculosdisponibles.jpg',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Te presentamos todos los vehículos disponibles\n⭐⭐⭐⭐⭐',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
        ),
      ],
    );
  }

  Widget _buildFiltroCategoria() {
    List<String> categorias = ['Todos'];
    categorias.addAll(
        vehiclesveinfo.map((v) => v["tipo_vehiculo"]["nombre"].toString()).toSet());

    return DropdownButton<String>(
      value: _categoriaSeleccionada,
      items: categorias.map((cat) {
        return DropdownMenuItem<String>(
          value: cat,
          child: Text(cat),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _categoriaSeleccionada = value!;
        });
      },
      style: TextStyle(color: Colors.cyan[900], fontSize: 18),
      dropdownColor: Colors.white,
      underline: Container(height: 2, color: Colors.cyan),
    );
  }

  Widget _buildCatalogoFiltrado(BuildContext context) {
    final vehiculosFiltrados = _categoriaSeleccionada == 'Todos'
        ? vehiclesveinfo
        : vehiclesveinfo.where((v) =>
            v["tipo_vehiculo"]["nombre"] == _categoriaSeleccionada).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: vehiculosFiltrados.length,
      itemBuilder: (context, index) {
        final vehicle = vehiculosFiltrados[index];
        final controllerIndex = vehiclesveinfo.indexOf(vehicle);

        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 600 + index * 150),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 50),
                child: child,
              ),
            );
          },
          child: Card(
            color: Colors.white.withOpacity(0.85),
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _controllers[controllerIndex],
                    itemCount: vehicle["imagen"].length,
                    itemBuilder: (context, imgIndex) {
                      return ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.asset(
                          vehicle["imagen"][imgIndex],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                SmoothPageIndicator(
                  controller: _controllers[controllerIndex],
                  count: vehicle["imagen"].length,
                  effect: WormEffect(
                    dotColor: Colors.grey,
                    activeDotColor: Colors.orangeAccent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        vehicle["nombre"],
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        vehicle["tipo_vehiculo"]["nombre"],
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: vehicle["estado"] == 1
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          vehicle["estado"] == 1
                              ? "Disponible"
                              : "No Disponible",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: vehicle["estado"] == 1
                            ? () => Navigator.pushNamed(
                                  context,
                                  '/detalle-vehiculo',
                                  arguments: vehicle,
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          disabledBackgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Solicitar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, AuthProvider auth) {
    return AppBar(
      backgroundColor: Colors.cyan[800],
      title: Text('Mudanzas Go!', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/perfil'),
        ),
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('¿Cerrar sesión?'),
                content: Text('¿Estás seguro de que quieres cerrar sesión?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      auth.logout(context);
                    },
                    child: Text('Cerrar sesión'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.cyan[800]),
            child:
                Text('Mudanzas Go!', style: TextStyle(fontSize: 24, color: Colors.white)),
          ),
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text('Servicios Locales'),
            onTap: () => Navigator.pushNamed(context, '/servicio-local'),
          ),
          ListTile(
            leading: Icon(Icons.public),
            title: Text('Servicios Nacionales'),
            onTap: () => Navigator.pushNamed(context, '/servicio-nacional'),
          ),
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text('Catálogo de Vehículos'),
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
        ],
      ),
    );
  }
}
