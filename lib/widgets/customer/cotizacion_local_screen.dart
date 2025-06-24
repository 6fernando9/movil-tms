import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mapa_mudanza_local_widget.dart';

class CotizacionLocalScreen extends StatefulWidget {
  @override
  _CotizacionLocalScreenState createState() => _CotizacionLocalScreenState();
}

class _CotizacionLocalScreenState extends State<CotizacionLocalScreen> {
  DateTime? _selectedDate;
  double? _distanciaKm;

  String? _embalajeSeleccionado;
  String? _residenciaSeleccionada;

  String? _origenDireccion;
  String? _destinoDireccion;

  Widget _buildSelector(
    String title,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items:
              options
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotización Mudanza Local'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelector(
              "¿Quiere el servicio con Embalaje?",
              ["Sí", "No"],
              _embalajeSeleccionado,
              (val) => setState(() => _embalajeSeleccionado = val),
            ),
            const SizedBox(height: 16),
            _buildSelector(
              "Seleccione el Tipo de Residencia",
              ["Vivienda", "Comercio", "Edificio/Empresa"],
              _residenciaSeleccionada,
              (val) => setState(() => _residenciaSeleccionada = val),
            ),
            const SizedBox(height: 24),
            Text(
              "Fecha de Reserva",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText:
                        _selectedDate == null
                            ? 'Selecciona una fecha'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            MapaMudanzaLocalWidget(
              onChanged: (
                origen,
                destino, {
                double? distanciaKm,
                String? origenDireccion,
                String? destinoDireccion,
              }) {
                setState(() {
                  _distanciaKm = distanciaKm;
                  _origenDireccion = origenDireccion;
                  _destinoDireccion = destinoDireccion;
                });
                // Guardar la distancia y direcciones en SharedPreferences
                SharedPreferences.getInstance().then((prefs) {
                  if (distanciaKm != null) {
                    prefs.setDouble('distancia_km', distanciaKm);
                  }
                  if (origenDireccion != null) {
                    prefs.setString('origen', origenDireccion);
                  }
                  if (destinoDireccion != null) {
                    prefs.setString('destino', destinoDireccion);
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedDate == null ||
                      _distanciaKm == null ||
                      _embalajeSeleccionado == null ||
                      _residenciaSeleccionada == null ||
                      _origenDireccion == null ||
                      _destinoDireccion == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Completa todos los campos y selecciona origen/destino en el mapa",
                        ),
                      ),
                    );
                    return;
                  }
                  // Guardar datos en SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(
                    'embalaje',
                    _embalajeSeleccionado == 'Sí',
                  );
                  await prefs.setString(
                    'residencia',
                    _residenciaSeleccionada ?? '',
                  );
                  await prefs.setString(
                    'fecha_reserva',
                    _selectedDate!.toIso8601String(),
                  );
                  await prefs.setString('tipo_viaje', 'Local');
                  await prefs.setString('origen', _origenDireccion!);
                  await prefs.setString('destino', _destinoDireccion!);
                  // La distancia ya se guarda en el callback del mapa
                  Navigator.pushNamed(context, '/rellenar-cotizacion');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Rellenar Formulario",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
