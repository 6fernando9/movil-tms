import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class MisServiciosPage extends StatefulWidget {
  const MisServiciosPage({super.key});

  @override
  State<MisServiciosPage> createState() => _MisServiciosPageState();
}

class _MisServiciosPageState extends State<MisServiciosPage> {
  List<dynamic> servicios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServicios();
  }

  Future<void> fetchServicios() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/servicios/mis-servicios'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        servicios = json.decode(response.body);
        isLoading = false;
      });
    } else {
      debugPrint('❌ Error al obtener servicios: ${response.statusCode}');
    }
  }

  void verFactura(int idServicio) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/servicios/$idServicio/invoice'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "📄 Detalle de Factura",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _facturaItem("📍 Origen", data['origen']['str']),
                _facturaItem("📦 Destino", data['destino']['str']),
                _facturaItem("📏 Distancia", "${data['distancia']} km"),
                _facturaItem("💵 Monto Total", "Bs. ${data['monto_total']}"),
                _facturaItem("🗓️ Fecha", data['fecha_reserva']),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                  label: Text("Cerrar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                )
              ],
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al obtener factura")),
      );
    }
  }

  Widget _facturaItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$titulo: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🧾 Mis Servicios')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: servicios.length,
              itemBuilder: (context, index) {
                final servicio = servicios[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: Color(0xFFF5F5F5),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📅 ${servicio['fecha']}",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo)),
                        Divider(height: 20, thickness: 1.5),
                        _infoItem("⏰ Hora", servicio['hora']),
                        _infoItem("📌 Estado", servicio['estado']),
                        _infoItem("🚛 Vehículo", servicio['vehiculo']),
                        _infoItem("🔢 Placa", servicio['placa']),
                        _infoItem("👨 Chofer", servicio['chofer']),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                verFactura(servicio['id'] ?? servicio['id_servicio']),
                            icon: Icon(Icons.receipt),
                            label: Text("Factura"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _infoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }
}
