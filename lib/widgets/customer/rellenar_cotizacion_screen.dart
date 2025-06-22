import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'formulario_unidades_sharedprefs.dart';

class RellenarCotizacionScreen extends StatefulWidget {
  @override
  _RellenarCotizacionScreenState createState() =>
      _RellenarCotizacionScreenState();
}

class _RellenarCotizacionScreenState extends State<RellenarCotizacionScreen> {
  final List<Map<String, dynamic>> muebles = [
    {"nombre": "Heladera", "cantidad": 0},
    {"nombre": "Cocina", "cantidad": 0},
    {"nombre": "Colchón", "cantidad": 0},
    {"nombre": "Sofá", "cantidad": 0},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  Future<void> _cargarDatosGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("muebles");
    if (data != null) {
      final lista = List<Map<String, dynamic>>.from(jsonDecode(data));
      setState(() {
        for (var item in muebles) {
          final encontrado = lista.firstWhere(
              (e) => e['nombre'] == item['nombre'],
              orElse: () => {});
          if (encontrado.isNotEmpty) {
            item['cantidad'] = encontrado['cantidad'];
          }
        }
      });
    }
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final seleccionados = muebles
        .where((element) => element['cantidad'] > 0)
        .map((e) => {"nombre": e['nombre'], "cantidad": e['cantidad']})
        .toList();
    await prefs.setString("muebles", jsonEncode(seleccionados));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona Muebles'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '¿Qué muebles deseas cotizar?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...muebles.map((item) => _buildMuebleItem(item)).toList(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _irASiguiente,
              icon: Icon(Icons.arrow_forward),
              label: Text("Siguiente"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuebleItem(Map<String, dynamic> item) {
    return Card(
      child: ListTile(
        title: Text(item['nombre']),
        subtitle: Text("Cantidad: ${item['cantidad']}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.deepPurple),
              onPressed: () => _abrirConfiguracion(context, item),
            ),
            if (item['cantidad'] > 0)
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormularioUnidadesScreen(
                        titulo: item['nombre'],
                        cantidad: item['cantidad'],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _abrirConfiguracion(BuildContext context, Map<String, dynamic> item) {
    int cantidadTemp = item['cantidad'] ?? 0;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: Text("Configurar ${item['nombre']}"),
            content: Row(
              children: [
                Text("Cantidad: "),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: cantidadTemp,
                  items: List.generate(6, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(index.toString()),
                    );
                  }),
                  onChanged: (value) {
                    setStateDialog(() {
                      cantidadTemp = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (cantidadTemp == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Debe elegir una cantidad > 0")),
                    );
                    return;
                  }

                  setState(() {
                    item['cantidad'] = cantidadTemp;
                  });

                  Navigator.pop(context);
                  await _guardarDatos();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormularioUnidadesScreen(
                        titulo: item['nombre'],
                        cantidad: cantidadTemp,
                      ),
                    ),
                  );
                },
                child: Text("Aceptar"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _irASiguiente() async {
    final seleccionados = muebles.where((m) => m['cantidad'] > 0).toList();

    if (seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debes seleccionar al menos un mueble con cantidad mayor a 0")),
      );
      return;
    }

    await _guardarDatos();
    Navigator.pushNamed(context, '/catalogo-vehiculos');
  }
}
