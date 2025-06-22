import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SolicitarServicioScreen extends StatefulWidget {
  @override
  _SolicitarServicioScreenState createState() => _SolicitarServicioScreenState();
}

class _SolicitarServicioScreenState extends State<SolicitarServicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionOrigenController = TextEditingController();
  final _direccionDestinoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _observacionesController = TextEditingController();
  DateTime? _selectedDate;

  List<Map<String, dynamic>> items = List.generate(40, (i) {
    final nombre = [
      'Sofá', 'Heladera', 'Cocina', 'Microondas', 'Lavarropas', 'Televisor', 'Computadora',
      'Escritorio', 'Silla de oficina', 'Mesa de comedor', 'Sillas de comedor', 'Cama matrimonial',
      'Cama individual', 'Colchón', 'Ropero', 'Cómoda', 'Bicicleta', 'Caja de libros',
      'Caja de ropa', 'Caja de cocina', 'Caja de baño', 'Caja de juguetes', 'Caja frágil',
      'Estante pequeño', 'Estante grande', 'Modular', 'Ventilador', 'Aire acondicionado',
      'Radiador', 'Silla plegable', 'Mesa ratona', 'Silla gamer', 'Archivador', 'Banco',
      'Zapatero', 'Perchero', 'Heladera pequeña', 'Freezer', 'Puff', 'Cuadro decorativo'
    ];
    return {"nombre": nombre[i], "seleccionado": false};
  });

  @override
  Widget build(BuildContext context) {
    final vehicle = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text('Solicitar Mudanza'), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vehicle["nombre"], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
              SizedBox(height: 24),
              _buildInput(_direccionOrigenController, "Dirección de Origen"),
              SizedBox(height: 16),
              _buildInput(_direccionDestinoController, "Dirección de Destino"),
              SizedBox(height: 16),
              _buildDatePicker(context),
              SizedBox(height: 16),
              _buildInput(_observacionesController, "Observaciones", maxLines: 3),
              SizedBox(height: 24),
              Text("Selecciona objetos/muebles para transportar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ...items.map((item) => CheckboxListTile(
                    title: Text(item["nombre"]),
                    value: item["seleccionado"],
                    activeColor: Colors.teal,
                    onChanged: (val) {
                      setState(() {
                        item["seleccionado"] = val!;
                      });
                    },
                  )),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _selectedDate != null) {
                      final fechaFormateada = DateFormat('dd/MM/yyyy').format(_selectedDate!);
                      final mueblesSeleccionados = items.where((e) => e["seleccionado"]).map((e) => e["nombre"]).toList();
                      Navigator.pushNamed(context, '/payment', arguments: {
                        "vehicle": vehicle,
                        "origen": _direccionOrigenController.text,
                        "destino": _direccionDestinoController.text,
                        "fecha": fechaFormateada,
                        "observaciones": _observacionesController.text,
                        "muebles": mueblesSeleccionados,
                      });
                    }
                  },
                  child: Text("Ir a Pago", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Campo requerido" : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: now,
          lastDate: DateTime(now.year + 1),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
          });
        }
      },
      child: AbsorbPointer(
        child: _buildInput(_fechaController, "Fecha de Mudanza"),
      ),
    );
  }
}