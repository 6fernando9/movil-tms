import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  String? _origen;
  String? _destino;
  GoogleMapController? _mapController;
  double? _distanciaKm;

  List<LatLng> _polylinePoints = [];

  final Map<String, LatLng> coordenadas = {
    'La Paz': LatLng(-16.5000, -68.1500),
    'Santa Cruz': LatLng(-17.7833, -63.1833),
    'Cochabamba': LatLng(-17.3895, -66.1568),
    'Oruro': LatLng(-17.9833, -67.1500),
    'Potosí': LatLng(-19.5836, -65.7531),
    'Tarija': LatLng(-21.5355, -64.7296),
    'Sucre': LatLng(-19.0333, -65.2627),
    'Trinidad': LatLng(-14.8333, -64.9000),
    'Cobija': LatLng(-11.0333, -68.7667),
  };

  @override
  void initState() {
    super.initState();
    _origen = widget.origen;
    _destino = widget.destino;
    if (_origen != null && _destino != null) {
      _fetchDistancia();
    }
  }

  Future<void> _fetchDistancia() async {
    if (_origen == null || _destino == null) return;
    final origenLatLng = coordenadas[_origen!];
    final destinoLatLng = coordenadas[_destino!];
    if (origenLatLng == null || destinoLatLng == null) return;

    // Si es Cobija-Tarija o Tarija-Cobija, dividir en tramos nacionales
    if ((_origen == 'Cobija' && _destino == 'Tarija') ||
        (_origen == 'Tarija' && _destino == 'Cobija')) {
      final tramos = [
        ['Cobija', 'La Paz'],
        ['La Paz', 'Oruro'],
        ['Oruro', 'Potosí'],
        ['Potosí', 'Tarija'],
      ];
      double distanciaTotal = 0.0;
      List<LatLng> polylineTotal = [];
      for (final tramo in tramos) {
        final origenT = coordenadas[tramo[0]]!;
        final destinoT = coordenadas[tramo[1]]!;
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origenT.latitude},${origenT.longitude}&destination=${destinoT.latitude},${destinoT.longitude}&region=BO&key=AIzaSyBMHNLsoS3UuqvGiW3CeyvcCxhgjvtmLtc',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final legs = data['routes'][0]['legs'];
            final distancia = legs.fold(
              0,
              (sum, leg) => sum + leg['distance']['value'],
            );
            distanciaTotal += distancia / 1000.0;
            final polyline = data['routes'][0]['overview_polyline']['points'];
            final decoded = _decodePolyline(polyline);
            if (polylineTotal.isNotEmpty) {
              // Evitar duplicar el punto de unión
              decoded.removeAt(0);
            }
            polylineTotal.addAll(decoded);
          }
        }
      }
      setState(() {
        _distanciaKm = distanciaTotal;
        _polylinePoints = polylineTotal;
      });
      if (_mapController != null && polylineTotal.isNotEmpty) {
        final bounds = _getBounds(polylineTotal);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
      widget.onChanged(
        _origen ?? '',
        _destino ?? '',
        distanciaKm: _distanciaKm,
      );
      return;
    }
    // ...código original para rutas normales...
    List<String> waypointsList = [];
    String waypoints =
        waypointsList.isNotEmpty ? '&waypoints=${waypointsList.join('|')}' : '';
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
          _origen ?? '',
          _destino ?? '',
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
        Text('¿Dónde comienza tu mudanza?'),
        DropdownButton<String>(
          value: _origen,
          hint: const Text('Selecciona ciudad de origen'),
          isExpanded: true,
          items:
              ciudadesBolivia
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
          onChanged: (val) {
            setState(() => _origen = val);
            widget.onChanged(_origen ?? '', _destino ?? '');
            _moveCamera();
          },
        ),
        const SizedBox(height: 8),
        Text('¿Hacia dónde te mudamos?'),
        DropdownButton<String>(
          value: _destino,
          hint: const Text('Selecciona ciudad de destino'),
          isExpanded: true,
          items:
              ciudadesBolivia
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
          onChanged: (val) {
            setState(() => _destino = val);
            widget.onChanged(_origen ?? '', _destino ?? '');
            _moveCamera();
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(-16.2902, -63.5887),
              zoom: 5,
            ),
            markers: _buildMarkers(),
            polylines: _buildPolyline(),
            onMapCreated: (controller) => _mapController = controller,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
        ),
        if (_distanciaKm != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Distancia por carretera: ${_distanciaKm!.toStringAsFixed(1)} km',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    if (_origen != null && coordenadas[_origen!] != null) {
      markers.add(
        Marker(
          markerId: MarkerId('origen'),
          position: coordenadas[_origen!]!,
          infoWindow: InfoWindow(title: 'Origen: $_origen'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    if (_destino != null && coordenadas[_destino!] != null) {
      markers.add(
        Marker(
          markerId: MarkerId('destino'),
          position: coordenadas[_destino!]!,
          infoWindow: InfoWindow(title: 'Destino: $_destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolyline() {
    if (_polylinePoints.isNotEmpty) {
      return {
        Polyline(
          polylineId: PolylineId('ruta'),
          color: Colors.blue,
          width: 4,
          points: _polylinePoints,
        ),
      };
    }
    return {};
  }

  void _moveCamera() {
    if (_origen != null && _destino != null) {
      _fetchDistancia();
      if (_distanciaKm != null) {
        widget.onChanged(
          _origen ?? '',
          _destino ?? '',
          distanciaKm: _distanciaKm,
        );
      } else {
        widget.onChanged(_origen ?? '', _destino ?? '');
      }
    } else if (_mapController != null &&
        _origen != null &&
        coordenadas[_origen!] != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(coordenadas[_origen!]!),
      );
      widget.onChanged(_origen ?? '', _destino ?? '');
    }
  }
}
