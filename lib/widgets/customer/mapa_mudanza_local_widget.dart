import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class MapaMudanzaLocalWidget extends StatefulWidget {
  // Cambia la firma del callback para incluir las direcciones
  final void Function(
    LatLng origen,
    LatLng destino, {
    double? distanciaKm,
    String? origenDireccion,
    String? destinoDireccion,
  })?
  onChanged;

  const MapaMudanzaLocalWidget({Key? key, this.onChanged}) : super(key: key);

  @override
  State<MapaMudanzaLocalWidget> createState() => _MapaMudanzaLocalWidgetState();
}

/*cobija*/
class _MapaMudanzaLocalWidgetState extends State<MapaMudanzaLocalWidget> {
  GoogleMapController? _mapController;
  LatLng? _origenLatLng;
  LatLng? _destinoLatLng;
  double? _distanciaKm;
  List<LatLng> _polylinePoints = [];
  String? _origenDireccion;
  String? _destinoDireccion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 1),
        Text(
          'Selecciona en el mapa el punto de origen y destino',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // Más pequeño
            color: Colors.black, // Ahora en negro
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 250,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(-17.7833, -63.1833), // Centro de Santa Cruz
              zoom: 12,
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
            onTap: (LatLng pos) async {
              setState(() {
                if (_origenLatLng == null) {
                  _origenLatLng = pos;
                } else if (_destinoLatLng == null) {
                  _destinoLatLng = pos;
                } else {
                  _origenLatLng = pos;
                  _destinoLatLng = null;
                }
              });
              if (_origenLatLng != null) {
                _origenDireccion = await _getDireccion(_origenLatLng!);
                setState(() {});
              }
              if (_destinoLatLng != null) {
                _destinoDireccion = await _getDireccion(_destinoLatLng!);
                setState(() {});
              }
              if (_origenLatLng != null && _destinoLatLng != null) {
                _fetchDistancia();
              }
            },
          ),
        ),
        if (_origenLatLng != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Origen: ${_origenDireccion ?? 'Cargando dirección...'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (_destinoLatLng != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Destino: ${_destinoDireccion ?? 'Cargando dirección...'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (_distanciaKm != null && _distanciaKm! > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Distancia por carretera: '
              '${_distanciaKm!.toStringAsFixed(2)} km',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Más pequeño
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
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
          draggable: true,
          onDragEnd: (pos) {
            setState(() {
              _origenLatLng = pos;
              if (_destinoLatLng != null) _fetchDistancia();
            });
          },
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
          draggable: true,
          onDragEnd: (pos) {
            setState(() {
              _destinoLatLng = pos;
              if (_origenLatLng != null) _fetchDistancia();
            });
          },
        ),
      );
    }
    return markers;
  }

  Future<void> _fetchDistancia() async {
    if (_origenLatLng == null || _destinoLatLng == null) return;
    final origenLatLng = _origenLatLng!;
    final destinoLatLng = _destinoLatLng!;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origenLatLng.latitude},${origenLatLng.longitude}&destination=${destinoLatLng.latitude},${destinoLatLng.longitude}&region=BO&key=AIzaSyBMHNLsoS3UuqvGiW3CeyvcCxhgjvtmLtc',
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
        if (widget.onChanged != null) {
          widget.onChanged!(
            _origenLatLng!,
            _destinoLatLng!,
            distanciaKm: _distanciaKm,
            origenDireccion: _origenDireccion,
            destinoDireccion: _destinoDireccion,
          );
        }
      }
    }
  }

  Future<String?> _getDireccion(LatLng latLng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=AIzaSyBMHNLsoS3UuqvGiW3CeyvcCxhgjvtmLtc',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      }
    }
    return null;
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
}
