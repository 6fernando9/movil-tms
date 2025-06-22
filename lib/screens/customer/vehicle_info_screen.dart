
import 'package:flutter/material.dart';

class VehicleInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vehicle = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Vehículo'),
        backgroundColor: Colors.cyan[800],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.cyan.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        vehicle['imagen'][0],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      vehicle["nombre"],
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle["tipo_vehiculo"]["nombre"],
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    Divider(height: 30, thickness: 1),
                    _buildTechnicalInfo("Modelo", vehicle["modelo"].toString()),
                    _buildTechnicalInfo("Motor", vehicle["motor"]),
                    _buildTechnicalInfo("Placa", vehicle["placa"]),
                    _buildTechnicalInfo("Capacidad", "${vehicle["capacidad"]} kg"),
                    _buildTechnicalInfo("Costo por Km", "Bs. ${vehicle["coste_kilometraje"]}"),
                    _buildTechnicalInfo("Seguro", vehicle["seguro"] == 1 ? "Incluido" : "No"),
                    _buildTechnicalInfo("Estado", vehicle["estado"] == 1 ? "Disponible" : "No Disponible"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/solicitar-servicio', arguments: vehicle);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Solicitar Mudanza", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 10),
                   /*  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cotizacion-servicio', arguments: vehicle);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Solicitar Servicio", style: TextStyle(fontSize: 18)),
                    ), */
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.black54)),
          Text(value, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
