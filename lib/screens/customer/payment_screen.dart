import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
          )
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
                  color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildResumen("Vehículo", vehicle["nombre"]),
            _buildResumen("Tipo", vehicle["tipo_vehiculo"]["nombre"]),
            _buildResumen("Placa", vehicle["placa"]),
            _buildResumen("Origen", datos["origen"]),
            _buildResumen("Destino", datos["destino"]),
            _buildResumen("Fecha", datos["fecha"]),
            _buildResumen(
                "Observaciones", datos["observaciones"] ?? "-"),
            _buildResumen("Costo por Km",
                "Bs. ${vehicle["coste_kilometraje"]}"),
            if (datos["muebles"] != null) ...[
              SizedBox(height: 20),
              Text("Muebles a trasladar:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate((datos["muebles"] as List).length,
                  (i) => Text("• ${datos["muebles"][i]}"))
            ],
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.check_circle_outline),
              label: Text("Confirmar y Pagar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("¡Pago Realizado!"),
                    content: Text(
                        "Tu solicitud ha sido registrada correctamente."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false),
                        child: Text("Volver al inicio"),
                      )
                    ],
                  ),
                );
              },
            )
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
            child: Text(valor,
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _generarPDF(BuildContext context, Map<String, dynamic> datos) async {
    final vehicle = datos["vehicle"];
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Resumen de Pago",
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text("Vehículo: ${vehicle["nombre"]}"),
              pw.Text("Tipo: ${vehicle["tipo_vehiculo"]["nombre"]}"),
              pw.Text("Placa: ${vehicle["placa"]}"),
              pw.Text("Origen: ${datos["origen"]}"),
              pw.Text("Destino: ${datos["destino"]}"),
              pw.Text("Fecha: ${datos["fecha"]}"),
              pw.Text("Observaciones: ${datos["observaciones"] ?? "-"}"),
              pw.Text("Costo por Km: Bs. ${vehicle["coste_kilometraje"]}"),
              if (datos["muebles"] != null) ...[
                pw.SizedBox(height: 10),
                pw.Text("Muebles a trasladar:",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ...List.generate(
                  (datos["muebles"] as List).length,
                  (i) => pw.Text("• ${datos["muebles"][i]}"),
                )
              ]
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _exportarExcel(BuildContext context, Map<String, dynamic> datos) async {
    final vehicle = datos["vehicle"];
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
      ["Costo por Km", "Bs. ${vehicle["coste_kilometraje"]}"],
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
