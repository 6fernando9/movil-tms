import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class MapaMudanzaWidget extends StatefulWidget {
  final String? origen;
  final String? destino;
  final void Function(String, String, {double? distanciaKm}) onChanged;

  const MapaMudanzaWidget({
    Key? key,
    this.origen,
    this.destino,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<MapaMudanzaWidget> createState() => _MapaMudanzaWidgetState();
}

class _MapaMudanzaWidgetState extends State<MapaMudanzaWidget> {
  GoogleMapController? _mapController;
  double? _distanciaKm;
  List<LatLng> _polylinePoints = [];
  LatLng? _origenLatLng;
  LatLng? _destinoLatLng;

  // Coordenadas de ciudades principales de Bolivia
  static const Map<String, LatLng> ciudadesCoords = {
    'La Paz': LatLng(-16.5000, -68.1500),
    'Santa Cruz': LatLng(-17.7833, -63.1833),
    'Cochabamba': LatLng(-17.3895, -66.1568),
    'Oruro': LatLng(-17.9833, -67.1500),
    'Potosí': LatLng(-19.5836, -65.7531),
    'Tarija': LatLng(-21.5355, -64.7296),
    'Sucre': LatLng(-19.0333, -65.2627),
    'Trinidad': LatLng(-14.8333, -64.9000),
    'Cobija': LatLng(-11.0333, -68.7667),
    'El Triangulo': LatLng(-17.8000, -63.2000),
    'Yucumo': LatLng(-15.1622, -67.0500),
    'Caranavi': LatLng(-15.8381, -67.5531),
    'Coroico': LatLng(-16.1900, -67.7264),
  };

  @override
  void initState() {
    super.initState();
    _setLatLngFromProps();
  }

  @override
  void didUpdateWidget(MapaMudanzaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.origen != oldWidget.origen ||
        widget.destino != oldWidget.destino) {
      _setLatLngFromProps();
    }
  }

  void _setLatLngFromProps() {
    final origen = widget.origen;
    final destino = widget.destino;
    setState(() {
      _origenLatLng = ciudadesCoords[origen];
      _destinoLatLng = ciudadesCoords[destino];
      _polylinePoints = [];
      _distanciaKm = null;
    });
    if (_origenLatLng != null && _destinoLatLng != null) {
      _fetchDistancia();
    }
  }

  Future<void> _fetchDistancia() async {
    if (_origenLatLng == null || _destinoLatLng == null) return;
    final origenLatLng = _origenLatLng!;
    final destinoLatLng = _destinoLatLng!;
    String waypoints = '';
    final origenCiudad = widget.origen;
    final destinoCiudad = widget.destino;

    // Cobija <-> Cochabamba: waypoint Trinidad
    if ((origenCiudad == 'Cobija' && destinoCiudad == 'Cochabamba') ||
        (origenCiudad == 'Cochabamba' && destinoCiudad == 'Cobija')) {
      final trinidad = ciudadesCoords['Trinidad'];
      if (trinidad != null) {
        waypoints = '&waypoints=${trinidad.latitude},${trinidad.longitude}';
      }
    }
    // Cobija <-> La Paz: waypoints El Triangulo, Yucumo, Caranavi, Coroico
    else if ((origenCiudad == 'Cobija' && destinoCiudad == 'La Paz') ||
        (origenCiudad == 'La Paz' && destinoCiudad == 'Cobija')) {
      final eltriangulo = ciudadesCoords['El Triangulo'];
      if (eltriangulo != null) {
        waypoints =
            '&waypoints=' + '${eltriangulo.latitude},${eltriangulo.longitude}';
      }
    }
    // Cobija <-> Tarija: waypoints Trinidad y Santa Cruz
    else if ((origenCiudad == 'Cobija' && destinoCiudad == 'Tarija') ||
        (origenCiudad == 'Tarija' && destinoCiudad == 'Cobija')) {
      final trinidad = ciudadesCoords['Trinidad'];
      final santacruz = ciudadesCoords['Santa Cruz'];
      if (trinidad != null && santacruz != null) {
        waypoints =
            '&waypoints=${trinidad.latitude},${trinidad.longitude}|${santacruz.latitude},${santacruz.longitude}';
      }
    }
    // Cobija <-> Oruro: waypoints Trinidad y Cochabamba
    else if ((origenCiudad == 'Cobija' && destinoCiudad == 'Oruro') ||
        (origenCiudad == 'Oruro' && destinoCiudad == 'Cobija')) {
      final trinidad = ciudadesCoords['Trinidad'];
      final cochabamba = ciudadesCoords['Cochabamba'];
      if (trinidad != null && cochabamba != null) {
        waypoints =
            '&waypoints=${trinidad.latitude},${trinidad.longitude}|${cochabamba.latitude},${cochabamba.longitude}';
      }
    }
    // Cobija - Tarija: waypoints Trinidad y Santa Cruz
    else if ((origenCiudad == 'Cobija' && destinoCiudad == 'Tarija') ||
        (origenCiudad == 'Tarija' && destinoCiudad == 'Cobija')) {
      final trinidad = ciudadesCoords['Trinidad'];
      final santacruz = ciudadesCoords['Santa Cruz'];
      if (trinidad != null && santacruz != null) {
        waypoints =
            '&waypoints=${trinidad.latitude},${trinidad.longitude}|${santacruz.latitude},${santacruz.longitude}';
      }
    }
    // Cobija - Potosí: waypoints Trinidad y Sucre
    else if ((origenCiudad == 'Cobija' && destinoCiudad == 'Potosí') ||
        (origenCiudad == 'Potosí' && destinoCiudad == 'Cobija')) {
      final trinidad = ciudadesCoords['Trinidad'];
      final sucre = ciudadesCoords['Sucre'];
      if (trinidad != null && sucre != null) {
        waypoints =
            '&waypoints=${trinidad.latitude},${trinidad.longitude}|${sucre.latitude},${sucre.longitude}';
      }
    }
    // Cobija - Sucre: waypoints Trinidad y Santa Cruz
    else if ((origenCiudad == 'Cobija' && destinoCiudad == 'Sucre') ||
        (origenCiudad == 'Sucre' && destinoCiudad == 'Cobija')) {
      final trinidad = ciudadesCoords['Trinidad'];
      final santacruz = ciudadesCoords['Santa Cruz'];
      if (trinidad != null && santacruz != null) {
        waypoints =
            '&waypoints=${trinidad.latitude},${trinidad.longitude}|${santacruz.latitude},${santacruz.longitude}';
      }
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origenLatLng.latitude},${origenLatLng.longitude}&destination=${destinoLatLng.latitude},${destinoLatLng.longitude}$waypoints&region=BO&key=AIzaSyBMHNLsoS3UuqvGiW3CeyvcCxhgjvtmLtc',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final distancia = data['routes'][0]['legs'].fold(
          0,
          (sum, leg) => sum + leg['distance']['value'],
        );
        final polyline = data['routes'][0]['overview_polyline']['points'];
        final bounds = data['routes'][0]['bounds'];
        setState(() {
          _distanciaKm = distancia / 1000.0;
          _polylinePoints = _decodePolyline(polyline);
        });
        if (_mapController != null && bounds != null) {
          final ne = bounds['northeast'];
          final sw = bounds['southwest'];
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                northeast: LatLng(ne['lat'], ne['lng']),
                southwest: LatLng(sw['lat'], sw['lng']),
              ),
              50,
            ),
          );
        }
        widget.onChanged(
          '${_origenLatLng!.latitude},${_origenLatLng!.longitude}',
          '${_destinoLatLng!.latitude},${_destinoLatLng!.longitude}',
          distanciaKm: _distanciaKm,
        );
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
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
      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Ruta nacional entre ciudades seleccionadas'),
        SizedBox(
          height: 250,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _origenLatLng ?? LatLng(-17.7833, -63.1833),
              zoom: 6.5,
            ),
            markers: _buildMarkers(),
            polylines:
                _polylinePoints.isNotEmpty
                    ? {
                      Polyline(
                        polylineId: PolylineId('ruta_real'),
                        color: Colors.blue,
                        width: 4,
                        points: _polylinePoints,
                      ),
                    }
                    : {},
            onMapCreated: (controller) => _mapController = controller,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            // No permitir interacción de selección
            onTap: null,
          ),
        ),
        if (_origenLatLng != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Origen: ${widget.origen}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (_destinoLatLng != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Destino: ${widget.destino}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (_distanciaKm != null && _distanciaKm! > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Distancia por carretera: '
              '${_distanciaKm!.toStringAsFixed(2)} km',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    if (_origenLatLng != null) {
      markers.add(
        Marker(
          markerId: MarkerId('origen'),
          position: _origenLatLng!,
          infoWindow: InfoWindow(title: 'Origen'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          draggable: false,
        ),
      );
    }
    if (_destinoLatLng != null) {
      markers.add(
        Marker(
          markerId: MarkerId('destino'),
          position: _destinoLatLng!,
          infoWindow: InfoWindow(title: 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          draggable: false,
        ),
      );
    }
    return markers;
  }

  double _calcularDistancia(LatLng origen, LatLng destino) {
    const double radioTierra = 6371; // km
    final double dLat = _gradosARadianes(destino.latitude - origen.latitude);
    final double dLng = _gradosARadianes(destino.longitude - origen.longitude);
    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_gradosARadianes(origen.latitude)) *
            cos(_gradosARadianes(destino.latitude)) *
            (sin(dLng / 2) * sin(dLng / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radioTierra * c;
  }

  double _gradosARadianes(double grados) {
    return grados * pi / 180;
  }
}
