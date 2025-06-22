// ... (importaciones existentes)
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/vehiculo_info.dart';

class VehiculoCatalogoScreen extends StatefulWidget {
  @override
  State<VehiculoCatalogoScreen> createState() => _VehiculoCatalogoScreenState();
}

class _VehiculoCatalogoScreenState extends State<VehiculoCatalogoScreen> {
  String _categoriaSeleccionada = 'Todos';
  final List<PageController> _controllers = List.generate(
    vehiclesveinfo.length,
    (index) => PageController(),
  );

  @override
  Widget build(BuildContext context) {
    List<String> categorias = ['Todos'];
    categorias.addAll(vehiclesveinfo
        .map((v) => v["tipo_vehiculo"]["nombre"].toString())
        .toSet());

    final vehiculosFiltrados = _categoriaSeleccionada == 'Todos'
        ? vehiclesveinfo
        : vehiclesveinfo
            .where((v) =>
                v["tipo_vehiculo"]["nombre"] == _categoriaSeleccionada)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Vehículos'),
        backgroundColor: Colors.cyan[800],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.cyan.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: DropdownButtonFormField<String>(
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
                decoration: InputDecoration(
                  labelText: 'Filtrar por tipo',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: vehiculosFiltrados.length,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemBuilder: (context, index) {
                  final vehicle = vehiculosFiltrados[index];
                  final controllerIndex = vehiclesveinfo.indexOf(vehicle);

                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 600 + index * 100),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 40),
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
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
                          const SizedBox(height: 8),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vehicle["nombre"],
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                Text(vehicle["tipo_vehiculo"]["nombre"],
                                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: vehicle["estado"] == 1
                                      ? () => Navigator.pushNamed(
                                            context,
                                            /* ------------------------------------------------------------------------------------------------------------------ */
                                            '/resumen-vehiculo',
                                            arguments: vehicle,
                                          )
                                      : null,
                                  icon: Icon(Icons.local_shipping),
                                  label: Text("Solicitar Mudanza"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    disabledBackgroundColor: Colors.grey,
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
