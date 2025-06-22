import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServicioNacionalScreen extends StatelessWidget {
  final List<Map<String, String>> servicios = [
    {
      "titulo": "Mudanzas Empresariales",
      "descripcion": "Oficinas pequeñas hasta grandes corporaciones.",
      "icono": "work",
    },
    {
      "titulo": "Mudanzas Personales",
      "descripcion": "Cuidamos cada detalle de tu mudanza.",
      "icono": "home",
    },
    {
      "titulo": "Empaque Profesional",
      "descripcion": "Materiales resistentes para tus pertenencias.",
      "icono": "inventory",
    },
    {
      "titulo": "Seguro de Mudanza",
      "descripcion": "Mayor tranquilidad con cobertura adicional.",
      "icono": "shield",
    },
    {
      "titulo": "Almacenamiento Temporal",
      "descripcion": "Espacios seguros y vigilados.",
      "icono": "warehouse",
    },
    {
      "titulo": "Mudanza con Mascotas",
      "descripcion": "Traslado cómodo y seguro para tus mascotas.",
      "icono": "pets",
    },
    {
      "titulo": "Cobertura Nacional",
      "descripcion": "Llegamos a cualquier rincón de Bolivia.",
      "icono": "map",
    },
  ];

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-16.2902, -63.5887),
    zoom: 5,
  );

  IconData _getIcon(String key) {
    switch (key) {
      case "work": return Icons.work;
      case "home": return Icons.home;
      case "inventory": return Icons.inventory;
      case "shield": return Icons.shield;
      case "warehouse": return Icons.warehouse;
      case "pets": return Icons.pets;
      case "map": return Icons.map;
      default: return Icons.local_shipping;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicio Nacional'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🖼 Banner principal
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/mudanzanacional.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: Text(
                  'Mudanzas nacionales seguras y eficientes en Bolivia',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🌎 Servicios ofrecidos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    '🚛 Nuestros Servicios',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: servicios.map((servicio) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Icon(_getIcon(servicio['icono']!), size: 40, color: Colors.orangeAccent),
                                const SizedBox(height: 8),
                                Text(
                                  servicio['titulo']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  servicio['descripcion']!,
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📞 Botón Cotizar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/cotizacion-servicio');
                },
                icon: Icon(Icons.phone),
                label: Text("Cotizar Mudanza Nacional"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
