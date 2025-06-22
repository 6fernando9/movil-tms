import 'package:flutter/material.dart';

class ServicioLocalScreen extends StatelessWidget {
  final List<String> zonas = [
    'Zona Norte', 'Zona Sur', 'Zona Este', 'Zona Oeste',
    'Centro', 'La Ramada', 'Plan 3000', 'Doble vía La Guardia', 'Av. Banzer',
  ];

  final List<Map<String, String>> beneficios = [
    {
      'titulo': 'Servicio Personalizado',
      'descripcion': 'Nos adaptamos a tus necesidades para que tu mudanza local sea ágil y segura.',
    },
    {
      'titulo': 'Cobertura Total',
      'descripcion': 'Llegamos a todas las zonas urbanas y rurales de Santa Cruz.',
    },
    {
      'titulo': 'Equipo Profesional',
      'descripcion': 'Contamos con personal capacitado y confiable para el manejo de tus pertenencias.',
    },
    {
      'titulo': 'Empaque de Calidad',
      'descripcion': 'Materiales resistentes y seguros para proteger tus objetos durante el traslado.',
    },
    {
      'titulo': 'Vehículos Equipados',
      'descripcion': 'Modernas unidades de transporte adaptadas a todo tipo de mudanza.',
    },
    {
      'titulo': 'Atención Inmediata',
      'descripcion': 'Contáctanos y te responderemos en minutos para coordinar tu servicio.',
    },
    {
      'titulo': 'Seguimiento en Tiempo Real',
      'descripcion': 'Podrás conocer el estado de tu mudanza desde tu teléfono.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicio Local'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🖼 Banner
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/mudanzalocal.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    'Mudanzas locales seguras y rápidas en Santa Cruz',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📍 Cobertura en Zonas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 Cobertura en Zonas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: zonas.map((zona) {
                          return Chip(
                            label: Text(zona),
                            backgroundColor: Colors.cyan.shade100,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🏆 ¿Por qué elegirnos?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⭐ ¿Por qué elegirnos?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...beneficios.map((beneficio) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.check_circle_outline, color: Colors.orange),
                          title: Text(
                            beneficio['titulo']!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(beneficio['descripcion']!),
                        );
                      }).toList(),
                    ],
                  ),
                ),
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
                label: Text("Cotizar Mudanza"),
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
