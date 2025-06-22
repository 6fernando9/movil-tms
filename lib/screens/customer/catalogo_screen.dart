import 'package:flutter/material.dart';
import '../../data/vehicle_data.dart'; // Importar la lista correcta

class CatalogoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Vehículos'),
      ),
      body: Stack(
        children: [
          SizedBox.expand(child: Image.asset('assets/coco.png', fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return _buildVehicleCard(context, vehicle);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Map<String, dynamic> vehicle) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: vehicle["images"].length,
              itemBuilder: (context, imgIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(vehicle["images"][imgIndex], fit: BoxFit.cover),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(vehicle["name"], style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(vehicle["type"], style: TextStyle(color: Colors.white70, fontSize: 16)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: vehicle["available"] ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(vehicle["available"] ? "Disponible" : "No Disponible", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: vehicle["available"]
                      ? () => Navigator.pushNamed(context, '/detalle-vehiculo', arguments: vehicle)
                      : null,
                  child: Text('Solicitar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
