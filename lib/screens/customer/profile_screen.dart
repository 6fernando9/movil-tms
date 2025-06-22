import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_ecommerce/data/stripe/btn_test_service.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: Colors.cyan[800],
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.cyan,
                backgroundImage:
                    auth.profileIcon != null
                        ? NetworkImage(auth.profileIcon!)
                        : null,
                child:
                    auth.profileIcon == null
                        ? Icon(Icons.person, size: 70, color: Colors.white)
                        : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Información del Cliente',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan[800],
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoCard('Nombre', auth.nombre ?? "No disponible"),
              const SizedBox(height: 16),
              _buildInfoCard('Correo', auth.email ?? "No disponible"),
              const SizedBox(height: 16),
              _buildInfoCard('Teléfono', auth.telefono ?? "No disponible"),
              const SizedBox(height: 16),
              _buildInfoCard('Dirección', auth.direccion ?? "No disponible"),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // Aquí podrás abrir una pantalla para editar el perfil
                  //añadirrrrrrr
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad en construcción'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Editar Perfil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              
              //boton para simular la pasarela de pago
              const SizedBox(height: 16),
              // Botón Stripe
              BotonStripePago(
                texto: "PAGAR AHORA",
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Pago completado correctamente'),
                    ),
                  );
                },
                onCancel: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Pago cancelado o fallido')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.info_outline, color: Colors.cyan[800]),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
