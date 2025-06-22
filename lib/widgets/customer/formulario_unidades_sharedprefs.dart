import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FormularioUnidadesScreen extends StatefulWidget {
  final String titulo;
  final int cantidad;

  const FormularioUnidadesScreen({
    required this.titulo,
    required this.cantidad,
  });

  @override
  _FormularioUnidadesScreenState createState() =>
      _FormularioUnidadesScreenState();
}

class _FormularioUnidadesScreenState extends State<FormularioUnidadesScreen> {
  late PageController _pageController;
  late List<GlobalKey<FormState>> _formKeys;
  late List<Map<String, String>> _datosUnidades;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _formKeys = List.generate(widget.cantidad, (_) => GlobalKey<FormState>());
    _datosUnidades = List.generate(widget.cantidad, (_) => {
          "largo": "",
          "ancho": "",
          "alto": "",
          "peso": "",
        });

    _cargarDatosGuardados();
  }

  Future<void> _cargarDatosGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'medidas_${widget.titulo}';
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      try {
        final List<dynamic> data = jsonDecode(jsonString);
        setState(() {
          for (int i = 0; i < widget.cantidad && i < data.length; i++) {
            _datosUnidades[i] = Map<String, String>.from(data[i]);
          }
        });
      } catch (_) {}
    }
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'medidas_${widget.titulo}';
    final jsonString = jsonEncode(_datosUnidades);
    await prefs.setString(key, jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("Formulario: ${widget.titulo}"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.cantidad,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKeys[index],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Formulario ${index + 1} de ${widget.cantidad}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        _buildInput(index, "Largo"),
                        _buildInput(index, "Ancho"),
                        _buildInput(index, "Alto"),
                        _buildInput(index, "Peso"),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (index > 0)
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () => _irPagina(index - 1),
                              ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKeys[index].currentState!.validate()) {
                                  if (index < widget.cantidad - 1) {
                                    _irPagina(index + 1);
                                  } else {
                                    await _guardarDatos();
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/catalogo-vehiculos',
                                      (route) => false,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("✅ Medidas guardadas correctamente"),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                index == widget.cantidad - 1
                                    ? "Finalizar"
                                    : "Siguiente",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
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
    );
  }

  void _irPagina(int index) {
    if (index >= 0 && index < widget.cantidad) {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildInput(int index, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        initialValue: _datosUnidades[index][label.toLowerCase()],
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.straighten),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo requerido';
          }
          return null;
        },
        onChanged: (value) {
          _datosUnidades[index][label.toLowerCase()] = value;
        },
      ),
    );
  }
}
