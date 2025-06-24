import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class SolicitarServicioScreen extends StatefulWidget {
  @override
  _SolicitarServicioScreenState createState() =>
      _SolicitarServicioScreenState();
}

class _SolicitarServicioScreenState extends State<SolicitarServicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionOrigenController = TextEditingController();
  final _direccionDestinoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _observacionesController = TextEditingController();
  DateTime? _selectedDate;

  LatLng? _origen;
  LatLng? _destino;
  List<LatLng> _polylinePoints = [];
  String? _distanceText;
  final String _googleApiKey = 'AIzaSyBMHNLsoS3UuqvGiW3CeyvcCxhgjvtmLtc';

  static final LatLng _santaCruzCenter = LatLng(-17.7833, -63.1821);
  static final CameraPosition _initialPosition = CameraPosition(
    target: _santaCruzCenter,
    zoom: 12,
  );

  List<Map<String, dynamic>> items = List.generate(40, (i) {
    final nombre = [
      'Sofá',
      'Heladera',
      'Cocina',
      'Microondas',
      'Lavarropas',
      'Televisor',
      'Computadora',
      'Escritorio',
      'Silla de oficina',
      'Mesa de comedor',
      'Sillas de comedor',
      'Cama matrimonial',
      'Cama individual',
      'Colchón',
      'Ropero',
      'Cómoda',
      'Bicicleta',
      'Caja de libros',
      'Caja de ropa',
      'Caja de cocina',
      'Caja de baño',
      'Caja de juguetes',
      'Caja frágil',
      'Estante pequeño',
      'Estante grande',
      'Modular',
      'Ventilador',
      'Aire acondicionado',
      'Radiador',
      'Silla plegable',
      'Mesa ratona',
      'Silla gamer',
      'Archivador',
      'Banco',
      'Zapatero',
      'Perchero',
      'Heladera pequeña',
      'Freezer',
      'Puff',
      'Cuadro decorativo',
    ];
    return {"nombre": nombre[i], "seleccionado": false};
  });

  Future<void> _getRouteAndDistance() async {
    if (_origen == null || _destino == null) return;
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_origen!.latitude},${_origen!.longitude}&destination=${_destino!.latitude},${_destino!.longitude}&mode=driving&key=$_googleApiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final polyline = route['overview_polyline']['points'];
        final points = _decodePolyline(polyline);
        final distance = route['legs'][0]['distance']['text'];
        setState(() {
          _polylinePoints = points;
          _distanceText = distance;
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Future<void> _setAddressFromLatLng(
    LatLng latLng,
    TextEditingController controller,
  ) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$_googleApiKey&language=es';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          controller.text = address;
        } else {
          controller.text = 'Dirección no encontrada';
        }
      } else {
        controller.text = 'Dirección no encontrada';
      }
    } catch (e) {
      controller.text = 'Dirección no encontrada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitar Mudanza'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  vehicle["nombre"],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Selecciona objetos/muebles para transportar:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ...items.map(
                  (item) => CheckboxListTile(
                    title: Text(item["nombre"]),
                    value: item["seleccionado"],
                    activeColor: Colors.teal,
                    onChanged: (val) {
                      setState(() {
                        item["seleccionado"] = val!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                _buildInput(
                  _observacionesController,
                  "Observaciones",
                  maxLines: 3,
                  isOptional: true,
                ),
                SizedBox(height: 16),
                _buildDatePicker(context),
                SizedBox(height: 24),
                Text(
                  'Seleccione el punto de origen y destino dentro del mapa',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: _initialPosition,
                      markers: {
                        if (_origen != null)
                          Marker(
                            markerId: MarkerId('origen'),
                            position: _origen!,
                            infoWindow: InfoWindow(title: 'Origen'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                            draggable: true,
                            onDragEnd: (pos) async {
                              setState(() {
                                _origen = pos;
                              });
                              await _setAddressFromLatLng(
                                _origen!,
                                _direccionOrigenController,
                              );
                              if (_origen != null && _destino != null) {
                                await _getRouteAndDistance();
                              }
                            },
                          ),
                        if (_destino != null)
                          Marker(
                            markerId: MarkerId('destino'),
                            position: _destino!,
                            infoWindow: InfoWindow(title: 'Destino'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                            draggable: true,
                            onDragEnd: (pos) async {
                              setState(() {
                                _destino = pos;
                              });
                              await _setAddressFromLatLng(
                                _destino!,
                                _direccionDestinoController,
                              );
                              if (_origen != null && _destino != null) {
                                await _getRouteAndDistance();
                              }
                            },
                          ),
                      },
                      polylines:
                          (_polylinePoints.isNotEmpty)
                              ? {
                                Polyline(
                                  polylineId: PolylineId('ruta'),
                                  color: Colors.blue,
                                  width: 5,
                                  points: _polylinePoints,
                                ),
                              }
                              : {},
                      onTap: (LatLng pos) async {
                        setState(() {
                          if (_origen == null) {
                            _origen = pos;
                            _polylinePoints = [];
                            _distanceText = null;
                          } else if (_destino == null) {
                            _destino = pos;
                            _polylinePoints = [];
                            _distanceText = null;
                          } else {
                            _origen = pos;
                            _destino = null;
                            _polylinePoints = [];
                            _distanceText = null;
                          }
                        });
                        if (_origen != null)
                          await _setAddressFromLatLng(
                            _origen!,
                            _direccionOrigenController,
                          );
                        if (_destino != null)
                          await _setAddressFromLatLng(
                            _destino!,
                            _direccionDestinoController,
                          );
                        if (_origen != null && _destino != null) {
                          await _getRouteAndDistance();
                        }
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (_distanceText != null) ...[
                  Text(
                    'Distancia por ruta: $_distanceText',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dirección de Origen:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _direccionOrigenController.text.isNotEmpty
                                ? _direccionOrigenController.text
                                : 'No seleccionado',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dirección de Destino:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _direccionDestinoController.text.isNotEmpty
                                ? _direccionDestinoController.text
                                : 'No seleccionado',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final isValid = _formKey.currentState!.validate();
                      if (!isValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Por favor llena todos los campos obligatorios.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Por favor selecciona la fecha de mudanza.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final fechaFormateada = DateFormat(
                        'dd/MM/yyyy',
                      ).format(_selectedDate!);
                      final mueblesSeleccionados =
                          items
                              .where((e) => e["seleccionado"])
                              .map((e) => e["nombre"])
                              .toList();
                      if (mueblesSeleccionados.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Debes seleccionar al menos un objeto o mueble para transportar.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      Navigator.pushNamed(
                        context,
                        '/payment',
                        arguments: {
                          "vehicle": vehicle,
                          "origen": _direccionOrigenController.text,
                          "destino": _direccionDestinoController.text,
                          "fecha": fechaFormateada,
                          "observaciones": _observacionesController.text,
                          "muebles": mueblesSeleccionados,
                          "distancia": _distanceText,
                          // Para Static Maps en PDF:
                          "origenLat": _origen?.latitude,
                          "origenLng": _origen?.longitude,
                          "destinoLat": _destino?.latitude,
                          "destinoLng": _destino?.longitude,
                          "polylinePoints":
                              _polylinePoints
                                  .map(
                                    (p) => {
                                      "latitude": p.latitude,
                                      "longitude": p.longitude,
                                    },
                                  )
                                  .toList(),
                          "googleApiKey": _googleApiKey,
                        },
                      );
                    },
                    child: Text("Ir a Pago", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction:
          maxLines > 1 ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (isOptional) return null;
        return (value == null || value.isEmpty) ? "Campo requerido" : null;
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).unfocus();
      },
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
