import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _rol;
  String? _nombre;
  String? _email;
  String? _telefono;
  String? _direccion;
  String? _profileIcon;

  String? get token => _token;
  String? get rol => _rol;
  String? get nombre => _nombre;
  String? get email => _email;
  String? get telefono => _telefono;
  String? get direccion => _direccion;
  String? get profileIcon => _profileIcon;

  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _rol = prefs.getString('rol');
    _nombre = prefs.getString('nombre');
    _email = prefs.getString('email');
    _telefono = prefs.getString('telefono');
    _direccion = prefs.getString('direccion');
    _profileIcon = prefs.getString('profile_icon');
    notifyListeners();
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    debugPrint('[LOGIN] Email ingresado: $email');
    debugPrint('[LOGIN] Password ingresado: $password');

    final url = Uri.parse('${ApiService.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    debugPrint('[LOGIN] Código de respuesta: ${response.statusCode}');
    debugPrint('[LOGIN] Respuesta JSON: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final user = data['user'];
      _token = data['token'];
      _rol = user['rol']['nombre'];
      _nombre = user['nombre'];
      _email = user['email'];
      _telefono = user['telefono'];
      _direccion = user['direccion'];
      _profileIcon = user['profile_icon'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('rol', _rol!);
      await prefs.setString('nombre', _nombre ?? '');
      await prefs.setString('email', _email ?? '');
      await prefs.setString('telefono', _telefono ?? '');
      await prefs.setString('direccion', _direccion ?? '');
      await prefs.setString('profile_icon', _profileIcon ?? '');

      debugPrint('[LOGIN] Usuario autenticado correctamente');
      debugPrint('Nombre: $_nombre');
      debugPrint('Email: $_email');
      debugPrint('Teléfono: $_telefono');
      debugPrint('Dirección: $_direccion');
      debugPrint('Imagen: $_profileIcon');

      notifyListeners();
      _redirectUserByRole(context);
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  Future<void> registerCliente({
    required BuildContext context,
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String direccion,
    String? profileIcon,
  }) async {
    debugPrint(
      '[REGISTRO] Datos enviados:\n'
      'Nombre: $nombre\n'
      'Email: $email\n'
      'Password: $password\n'
      'Teléfono: $telefono\n'
      'Dirección: $direccion\n'
      'Imagen: $profileIcon',
    );

    final url = Uri.parse('${ApiService.baseUrl}/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nombre": nombre,
        "email": email,
        "password": password,
        "telefono": telefono,
        "direccion": direccion,
        "profile_icon": profileIcon,
      }),
    );

    debugPrint('[REGISTRO] Código de respuesta: ${response.statusCode}');
    debugPrint('[REGISTRO] Respuesta JSON: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro exitoso. Inicia sesión.")),
      );
      Navigator.pop(context);
    } else {
      throw Exception('Error al registrar: ${response.body}');
    }
  }

  Future<void> logout(BuildContext context) async {
    _token = null;
    _rol = null;
    _nombre = null;
    _email = null;
    _telefono = null;
    _direccion = null;
    _profileIcon = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();

    Navigator.pushReplacementNamed(context, '/login');
  }

  void _redirectUserByRole(BuildContext context) {
    switch (_rol) {
      case 'ADMINISTRADOR':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'AYUDANTE':
        Navigator.pushReplacementNamed(context, '/employee');
        break;
      case 'CHOFER':
        Navigator.pushReplacementNamed(context, '/chofer');
        break;
      case 'CLIENTE':
      default:
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }
}
