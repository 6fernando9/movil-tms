import 'package:flutter/material.dart';

class ContactoScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _mensajeController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  void _enviarFormulario() {
    if (_formKey.currentState!.validate()) {
      // Aquí después podrías enviar los datos al backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mensaje enviado correctamente ✅')),
      );
      // Limpia los campos después
      _nombreController.clear();
      _emailController.clear();
      _telefonoController.clear();
      _mensajeController.clear();
      _ciudadController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contáctanos'),
        backgroundColor: Colors.cyan[800],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Banner superior (puedes poner una imagen bonita también)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/contactobanner.jpg'), // Tu imagen de contacto
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    'Envíanos tu consulta\nMudanzas Go!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Formulario
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nombreController,
                    label: "Nombre",
                    icon: Icons.person,
                    validator: (value) => value!.isEmpty ? 'Ingrese su nombre' : null,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: "Correo electrónico",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingrese su correo';
                      if (!value.contains('@')) return 'Correo no válido';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _telefonoController,
                    label: "Teléfono",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Ingrese su teléfono' : null,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _ciudadController,
                    label: "Ciudad o Zona",
                    icon: Icons.location_city,
                    validator: (value) => null,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _mensajeController,
                    label: "Mensaje",
                    icon: Icons.message,
                    maxLines: 4,
                    validator: (value) => value!.isEmpty ? 'Ingrese su mensaje' : null,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _enviarFormulario,
                    icon: Icon(Icons.send),
                    label: Text('Enviar Mensaje'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.cyan.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
