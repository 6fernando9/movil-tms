import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> datos =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final vehicle = datos["vehicle"];

    return Scaffold(
      appBar: AppBar(
        title: Text("Resumen y Pago"),
        backgroundColor: Colors.cyan[800],
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await _generarPDF(context, datos);
            },
          ),
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () async {
              await _exportarExcel(context, datos);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.cyan.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Resumen del Servicio",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildResumen("Vehículo", vehicle["nombre"]),
            _buildResumen("Tipo", vehicle["tipo_vehiculo"]["nombre"]),
            _buildResumen("Placa", vehicle["placa"]),
            _buildResumen("Origen", datos["origen"]),
            _buildResumen("Destino", datos["destino"]),
            _buildResumen("Fecha", datos["fecha"]),
            _buildResumen("Observaciones", datos["observaciones"] ?? "-"),
            _buildResumen(
              "Costo por Km",
              "Bs. " + vehicle["coste_kilometraje"].toString(),
            ),
            _buildResumen("Distancia", datos["distancia"] ?? "-"),
            _buildResumen(
              "Costo Total",
              "Bs. " +
                  _calcularCostoTotal(
                    datos["distancia"],
                    vehicle["coste_kilometraje"],
                  ).toStringAsFixed(2),
            ),
            if (datos["muebles"] != null) ...[
              SizedBox(height: 20),
              Text(
                "Muebles a trasladar:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...List.generate(
                (datos["muebles"] as List).length,
                (i) => Text("• " + datos["muebles"][i]),
              ),
            ],
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.check_circle_outline),
              label: Text("Confirmar y Pagar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text("¡Pago Realizado!"),
                        content: Text(
                          "Tu solicitud ha sido registrada correctamente.",
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                () => Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                ),
                            child: Text("Volver al inicio"),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: TextStyle(color: Colors.black54)),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  double _calcularCostoTotal(String? distancia, dynamic costeKm) {
    if (distancia == null || costeKm == null) return 0.0;
    final kmMatch = RegExp(r"([\d.]+)").firstMatch(distancia);
    if (kmMatch == null) return 0.0;
    final km = double.tryParse(kmMatch.group(1) ?? "0") ?? 0.0;
    final coste = double.tryParse(costeKm.toString()) ?? 0.0;
    return km * coste;
  }

  Future<Uint8List?> _getStaticMapImage({
    required String apiKey,
    required double origenLat,
    required double origenLng,
    required double destinoLat,
    required double destinoLng,
    List<List<double>>? polylinePoints,
    int width = 600,
    int height = 300,
  }) async {
    // Centrar el mapa en el centro de la ciudad (Santa Cruz)
    double cityLat = -17.7833;
    double cityLng = -63.1821;
    int zoom = 10; // Más alejado para ver toda la ciudad y alrededores
    String url =
        'https://maps.googleapis.com/maps/api/staticmap?size=${width}x$height&maptype=roadmap'
        '&center=$cityLat,$cityLng'
        '&zoom=$zoom'
        '&markers=color:green%7Clabel:O%7C$origenLat,$origenLng'
        '&markers=color:red%7Clabel:D%7C$destinoLat,$destinoLng';
    if (polylinePoints != null && polylinePoints.isNotEmpty) {
      String polyline = _encodePolylineFromList(polylinePoints);
      url += '&path=weight:5|color:blue|enc:$polyline';
    }
    url += '&key=$apiKey';
    final response = await HttpClient().getUrl(Uri.parse(url));
    final imageBytes = await (await response.close()).fold<BytesBuilder>(
      BytesBuilder(),
      (b, d) => b..add(d),
    );
    final bytes = imageBytes.takeBytes();
    if (bytes.length < 16 ||
        !(bytes[0] == 0x89 &&
                bytes[1] == 0x50 &&
                bytes[2] == 0x4E &&
                bytes[3] == 0x47) &&
            !(bytes[0] == 0xFF &&
                bytes[1] == 0xD8 &&
                bytes[bytes.length - 2] == 0xFF &&
                bytes[bytes.length - 1] == 0xD9)) {
      return null;
    }
    return bytes;
  }

  String _encodePolylineFromList(List<List<double>> points) {
    int lastLat = 0;
    int lastLng = 0;
    StringBuffer result = StringBuffer();
    for (final point in points) {
      int lat = (point[0] * 1e5).round();
      int lng = (point[1] * 1e5).round();
      int dLat = lat - lastLat;
      int dLng = lng - lastLng;
      _encodeValue(dLat, result);
      _encodeValue(dLng, result);
      lastLat = lat;
      lastLng = lng;
    }
    return result.toString();
  }

  void _encodeValue(int value, StringBuffer result) {
    int shifted = value << 1;
    if (value < 0) shifted = ~shifted;
    while (shifted >= 0x20) {
      result.writeCharCode((0x20 | (shifted & 0x1f)) + 63);
      shifted >>= 5;
    }
    result.writeCharCode(shifted + 63);
  }

  Future<void> _generarPDF(
    BuildContext context,
    Map<String, dynamic> datos,
  ) async {
    final vehicle = datos["vehicle"];
    final pdf = pw.Document();
    final distancia = datos["distancia"] ?? "-";
    final costeKm = vehicle["coste_kilometraje"];
    final costoTotal = _calcularCostoTotal(
      distancia,
      costeKm,
    ).toStringAsFixed(2);

    // Obtener coordenadas, polyline y API key
    final origenLat = datos["origenLat"];
    final origenLng = datos["origenLng"];
    final destinoLat = datos["destinoLat"];
    final destinoLng = datos["destinoLng"];
    final apiKey = datos["googleApiKey"];
    final polylinePoints = datos["polylinePoints"] as List?;
    Uint8List? mapImage;
    if (origenLat != null &&
        origenLng != null &&
        destinoLat != null &&
        destinoLng != null &&
        apiKey != null) {
      List<List<double>>? polyPoints;
      if (polylinePoints != null && polylinePoints.isNotEmpty) {
        polyPoints =
            polylinePoints
                .map<List<double>>(
                  (p) => [p["latitude"] * 1.0, p["longitude"] * 1.0],
                )
                .toList();
      }
      mapImage = await _getStaticMapImage(
        apiKey: apiKey,
        origenLat: origenLat,
        origenLng: origenLng,
        destinoLat: destinoLat,
        destinoLng: destinoLng,
        polylinePoints: polyPoints,
        width: 400,
        height: 200,
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: pw.EdgeInsets.all(32),
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Resumen de Pago",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Vehículo: ${vehicle["nombre"]}"),
                          pw.Text(
                            "Tipo: ${vehicle["tipo_vehiculo"]["nombre"]}",
                          ),
                          pw.Text("Placa: ${vehicle["placa"]}"),
                          pw.Text("Origen: ${datos["origen"]}"),
                          pw.Text("Destino: ${datos["destino"]}"),
                          pw.Text("Fecha: ${datos["fecha"]}"),
                          pw.Text(
                            "Observaciones: ${datos["observaciones"] ?? "-"}",
                          ),
                          pw.Text("Costo por Km: Bs. $costeKm"),
                          pw.Text("Distancia: $distancia"),
                          pw.Text("Costo Total: Bs. $costoTotal"),
                          if (datos["muebles"] != null) ...[
                            pw.SizedBox(height: 10),
                            pw.Text(
                              "Muebles a trasladar:",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            ...List.generate(
                              (datos["muebles"] as List).length,
                              (i) => pw.Text("• ${datos["muebles"][i]}"),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (mapImage != null) ...[
                      pw.SizedBox(width: 32),
                      pw.Container(
                        width: 200,
                        height: 200,
                        child: pw.Image(
                          pw.MemoryImage(mapImage),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _exportarExcel(
    BuildContext context,
    Map<String, dynamic> datos,
  ) async {
    final vehicle = datos["vehicle"];
    final distancia = datos["distancia"] ?? "-";
    final costeKm = vehicle["coste_kilometraje"];
    final costoTotal = _calcularCostoTotal(
      distancia,
      costeKm,
    ).toStringAsFixed(2);
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Resumen'];

    final rows = [
      ["Vehículo", vehicle["nombre"]],
      ["Tipo", vehicle["tipo_vehiculo"]["nombre"]],
      ["Placa", vehicle["placa"]],
      ["Origen", datos["origen"]],
      ["Destino", datos["destino"]],
      ["Fecha", datos["fecha"]],
      ["Observaciones", datos["observaciones"] ?? "-"],
      ["Costo por Km", "Bs. $costeKm"],
      ["Distancia", distancia],
      ["Costo Total", "Bs. $costoTotal"],
    ];

    for (var row in rows) {
      sheet.appendRow(row.map((e) => TextCellValue(e.toString())).toList());
    }

    if (datos["muebles"] != null) {
      sheet.appendRow([TextCellValue("Muebles a trasladar")]);
      for (var item in datos["muebles"]) {
        sheet.appendRow([TextCellValue("• $item")]);
      }
    }

    final bytes = excel.encode()!;
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/reporte_pago.xlsx";
    final file = File(path);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("📥 Archivo Excel guardado en: $path")),
    );
  }
}
