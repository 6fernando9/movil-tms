import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mapa_mudanza_widget.dart';
import 'mapa_mudanza_local_widget.dart';

class CotizacionScreen extends StatefulWidget {
  @override
  _CotizacionScreenState createState() => _CotizacionScreenState();
}

class _CotizacionScreenState extends State<CotizacionScreen> {
  DateTime? _selectedDate;
  TextEditingController _origenController = TextEditingController();
  TextEditingController _destinoController = TextEditingController();

  String? _embalajeSeleccionado;
  String? _residenciaSeleccionada;

  String? _origenCiudad;
  String? _destinoCiudad;

  double? _distanciaKm;

  static const List<String> ciudadesBolivia = [
    'La Paz',
    'Santa Cruz',
    'Cochabamba',
    'Oruro',
    'Potosí',
    'Tarija',
    'Sucre',
    'Trinidad',
    'Cobija',
  ];

  @override
  void initState() {
    super.initState();
    _origenController.text = '';
    _destinoController.text = '';
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('embalaje', _embalajeSeleccionado == 'Sí');
    // Forzar tipo_viaje a 'Nacional' para este flujo
    await prefs.setString('tipo_viaje', 'Nacional');
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
    // Obtener la zona seleccionada desde los argumentos
    final args = ModalRoute.of(context)?.settings.arguments;
    String? zonaSeleccionada;
    if (args is Map && args['zona'] is String) {
      zonaSeleccionada = args['zona'] as String;
      if (_origenController.text.isEmpty) {
        _origenController.text = zonaSeleccionada;
      }
    }

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
            if (zonaSeleccionada != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orangeAccent),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.deepOrange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zona seleccionada: $zonaSeleccionada',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
            // --- Mapa y selección de ciudades nacional ---
            Text('¿Dónde comienza tu mudanza?'),
            DropdownButton<String>(
              value: _origenCiudad,
              hint: const Text('Selecciona ciudad de origen'),
              isExpanded: true,
              items:
                  ciudadesBolivia
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (val) {
                setState(() {
                  _origenCiudad = val;
                });
              },
            ),
            const SizedBox(height: 8),
            Text('¿Hacia dónde te mudamos?'),
            DropdownButton<String>(
              value: _destinoCiudad,
              hint: const Text('Selecciona ciudad de destino'),
              isExpanded: true,
              items:
                  ciudadesBolivia
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (val) {
                setState(() {
                  _destinoCiudad = val;
                });
              },
            ),
            const SizedBox(height: 16),
            MapaMudanzaWidget(
              origen: _origenCiudad,
              destino: _destinoCiudad,
              onChanged: (origen, destino, {double? distanciaKm}) {
                setState(() {
                  _origenController.text = _origenCiudad ?? '';
                  _destinoController.text = _destinoCiudad ?? '';
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
}
