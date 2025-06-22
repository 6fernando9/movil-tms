import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DetalleCompraScreen extends StatefulWidget {
  @override
  State<DetalleCompraScreen> createState() => _DetalleCompraScreenState();
}

class _DetalleCompraScreenState extends State<DetalleCompraScreen> {
  Map<String, dynamic>? datos;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();

    final embalaje = prefs.getBool('embalaje');
    final tipoViaje = prefs.getString('tipo_viaje');
    final residencia = prefs.getString('residencia');
    final origen = prefs.getString('origen');
    final destino = prefs.getString('destino');
    final fechaReserva = prefs.getString('fecha_reserva');
    final vehiculo = prefs.getString('vehiculo');
    final mueblesJson = prefs.getString('muebles');
    final distanciaKm = prefs.getDouble('distancia_km') ?? 0.0;

    final claves =
        prefs.getKeys().where((k) => k.startsWith('medidas_')).toList();

    List<Map<String, dynamic>> inmuebles = [];

    for (var clave in claves) {
      final id = clave.replaceFirst('medidas_', '');
      final cantidad = prefs.getInt('cantidad_$id') ?? 0;
      final data = prefs.getString(clave);
      if (data != null) {
        final formularios = jsonDecode(data);
        inmuebles.add({
          "id": id,
          "cantidad": cantidad,
          "formularios": formularios,
        });
      }
    }

    datos = {
      "embalaje": embalaje ?? false,
      "tipo_viaje": tipoViaje ?? "",
      "residencia": residencia ?? "",
      "origen": origen ?? "",
      "destino": destino ?? "",
      "fecha_reserva": fechaReserva ?? "",
      "vehiculo": vehiculo != null ? jsonDecode(vehiculo) : {},
      "muebles": mueblesJson != null ? jsonDecode(mueblesJson) : [],
      "inmuebles": inmuebles,
      "distancia_km": distanciaKm,
    };

    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de Compra")),
      body:
          cargando
              ? Center(child: CircularProgressIndicator())
              : datos == null
              ? Center(child: Text("No hay datos disponibles 😥"))
              : _buildContenido(),
    );
  }

  Widget _buildContenido() {
    final vehiculo = datos!["vehiculo"];
    final distanciaKmRaw = datos!["distancia_km"] ?? 0.0;
    final costoKmRaw = vehiculo["coste_kilometraje"] ?? 0.0;
    final double distanciaKm =
        distanciaKmRaw is String
            ? double.tryParse(distanciaKmRaw) ?? 0.0
            : distanciaKmRaw.toDouble();
    final double costoKm =
        costoKmRaw is String
            ? double.tryParse(costoKmRaw) ?? 0.0
            : costoKmRaw.toDouble();
    final costoTotal = (distanciaKm * costoKm).toStringAsFixed(2);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection("Resumen General"),
        _info("¿Embalaje?", datos!["embalaje"] ? "Sí" : "No"),
        _info("Tipo de Viaje", datos!["tipo_viaje"]),
        _info("Tipo de Residencia", datos!["residencia"]),
        _info("Fecha Reserva", datos!["fecha_reserva"]),

        const SizedBox(height: 16),
        _buildSection("Ubicaciones"),
        _info("Origen", datos!["origen"]),
        _info("Destino", datos!["destino"]),

        const SizedBox(height: 16),
        _buildSection("Vehículo Seleccionado"),
        _info("Nombre", vehiculo["nombre"]),
        _info("Tipo", vehiculo["tipo_vehiculo"]["nombre"]),
        _info("Placa", vehiculo["placa"]),
        _info("Costo x Km", "Bs. ${vehiculo["coste_kilometraje"]}"),

        const SizedBox(height: 16),
        _buildSection("Muebles y Formularios"),
        ...datos!["inmuebles"].map<Widget>((mueble) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🪑 ${mueble['id']} (x${mueble['cantidad']})",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...mueble["formularios"].asMap().entries.map<Widget>((entry) {
                final i = entry.key + 1;
                final f = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "🔸 Formulario $i: L: ${f['largo']}, A: ${f['ancho']}, Alt: ${f['alto']}, P: ${f['peso']}",
                  ),
                );
              }).toList(),
              Divider(),
            ],
          );
        }).toList(),

        const SizedBox(height: 16),
        _buildSection("Detalles del Viaje"),
        _info(
          "Distancia por carretera",
          "${distanciaKm.toStringAsFixed(1)} km",
        ),
        _info("Costo x Km", "Bs. $costoKm"),
        _info("Costo total", "Bs. $costoTotal"),

        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: Icon(Icons.check_circle_outline),
          label: Text("Pagar y Mostrar JSON"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            final jsonCompleto = jsonEncode(datos);
            print("🧾 JSON COMPLETO:\n$jsonCompleto");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("✅ JSON impreso en consola")),
            );
          },
        ),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orangeAccent,
        ),
      ),
    );
  }
}
