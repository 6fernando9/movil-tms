import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mapa_mudanza_widget.dart';

class CotizacionScreen extends StatefulWidget {
  @override
  _CotizacionScreenState createState() => _CotizacionScreenState();
}

class _CotizacionScreenState extends State<CotizacionScreen> {
  DateTime? _selectedDate;
  TextEditingController _origenController = TextEditingController();
  TextEditingController _destinoController = TextEditingController();

  String? _embalajeSeleccionado;
  String? _tipoViajeSeleccionado;
  String? _residenciaSeleccionada;

  String? _origenCiudad;
  String? _destinoCiudad;

  double? _distanciaKm;

  @override
  void initState() {
    super.initState();
    _origenController.text = '';
    _destinoController.text = '';
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('embalaje', _embalajeSeleccionado == 'Sí');
    await prefs.setString('tipo_viaje', _tipoViajeSeleccionado ?? '');
    await prefs.setString('residencia', _residenciaSeleccionada ?? '');
    await prefs.setString('origen', _origenController.text);
    await prefs.setString('destino', _destinoController.text);
    await prefs.setString('fecha_reserva', _selectedDate!.toIso8601String());
    if (_distanciaKm != null) {
      await prefs.setDouble('distancia_km', _distanciaKm!);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario Inicial'),
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
              "Seleccione el tipo de Viaje",
              ["Local", "Nacional"],
              _tipoViajeSeleccionado,
              (val) => setState(() => _tipoViajeSeleccionado = val),
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
            // --- Mapa y selección de ciudades ---
            MapaMudanzaWidget(
              origen: _origenCiudad,
              destino: _destinoCiudad,
              onChanged: (origen, destino, {double? distanciaKm}) {
                setState(() {
                  _origenCiudad = origen;
                  _destinoCiudad = destino;
                  _origenController.text = origen;
                  _destinoController.text = destino;
                  if (distanciaKm != null) _distanciaKm = distanciaKm;
                });
              },
            ),
            const SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedDate == null ||
                      _embalajeSeleccionado == null ||
                      _tipoViajeSeleccionado == null ||
                      _residenciaSeleccionada == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Completa todos los campos")),
                    );
                    return;
                  }

                  await _guardarDatos();
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

  Widget _buildSelector(
    String label,
    List<String> options,
    String? selectedValue,
    void Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              options.map((option) {
                final isSelected = option == selectedValue;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: Colors.greenAccent,
                  onSelected: (_) => onSelect(option),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
