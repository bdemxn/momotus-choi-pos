import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PrinterController { 
  Future<void> restoreConnectedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final String? printerData = prefs.getString('connectedPrinter');

    if (printerData != null) {
      connectedPrinter = Printer.fromJson(jsonDecode(printerData));
      print("Impresora restaurada: $connectedPrinter");
    }
  }

  final FlutterThermalPrinter _printerPlugin = FlutterThermalPrinter.instance;
  Printer? connectedPrinter;
  final StreamController<List<Printer>> _printersController = StreamController.broadcast();

  Stream<List<Printer>> get printersStream => _printersController.stream;

  // Inicia el escaneo de impresoras
  Future<void> startScan() async {
    await _printerPlugin.getPrinters(connectionTypes: [
      ConnectionType.USB,
      ConnectionType.BLE,
    ]);
    _printerPlugin.devicesStream.listen((List<Printer> printers) {
      _printersController.add(printers);
    });
  }

  // Detiene el escaneo de impresoras
  Future<void> stopScan() async {
    await _printerPlugin.stopScan();
  }

  // Conecta una impresora seleccionada
  Future<void> connectPrinter(Printer printer) async {
    await _printerPlugin.connect(printer);
    connectedPrinter = printer;
    // Guardar la impresora conectada
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connectedPrinter', jsonEncode(printer.toJson()));
  } 
  
  void debugPrinterState() {
    print("Impresora conectada: $connectedPrinter");
  }
  // Desconecta la impresora actual
  Future<void> disconnectPrinter() async {
    if (connectedPrinter != null) {
      await _printerPlugin.disconnect(connectedPrinter!);
      connectedPrinter = null;
    }
  }

  // Imprime dos recibos basado en un JSON
  Future<void> printReceiptTwice(Map<String, dynamic> receiptJson, BuildContext context) async {
  if (connectedPrinter == null) {
    throw Exception("No hay una impresora conectada.");
  }

  // Generar los bytes del código QR
  final qrCodeData = receiptJson["footer"]["qr_code_data"] ?? "";
  final qrCodeBytes = await generateQrCode(qrCodeData, size: 150.0);

  // Imprimir recibo para el cliente
  await _printerPlugin.printWidget(
    context,
    printer: connectedPrinter!,
    widget: _buildReceiptWidget(receiptJson, qrCodeBytes, copyType: "Cliente"),
  );

  // Imprimir recibo para el cajero
  await _printerPlugin.printWidget(
    context,
    printer: connectedPrinter!,
    widget: _buildReceiptWidget(receiptJson, qrCodeBytes, copyType: "Cajero"),
  );
  }

    // Cierra el StreamController al finalizar
  void dispose() {
    _printersController.close(); 
  }
}

Future<Uint8List> generateQrCode(String data, {double size = 150.0}) async {
  final qrValidationResult = QrValidator.validate(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );

  if (qrValidationResult.status != QrValidationStatus.valid) {
    throw Exception("No se pudo generar el código QR.");
  }

  final painter = QrPainter.withQr(
    qr: qrValidationResult.qrCode!,
    color: const Color(0xFF000000),
    emptyColor: const Color(0xFFFFFFFF),
    gapless: true,
  );

  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final sizeRect = Size(size, size);

  painter.paint(canvas, sizeRect);
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}

// Crea el widget del recibo para la impresión
Widget _buildReceiptWidget(Map<String, dynamic> receiptJson, Uint8List qrCodeBytes, {String copyType = "Cliente"}) {
  return SizedBox(
    width: 380,
    child: Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                receiptJson["header"]["title"],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Copia: $copyType",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Sucursal: ${receiptJson["header"]["branch"]}"),
            Text("Fecha: ${receiptJson["header"]["date"]}"),
            Text("Cajero: ${receiptJson["header"]["cashier"]}"),
            const Divider(thickness: 2),
            for (var item in receiptJson["items"])
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${item["quantity"]}x ${item["name"]}"),
                  Text("${item["total"]} ${receiptJson["totals"]["currency"]}"),
                ],
              ),
            const Divider(thickness: 2),
            Text(
              "Total: ${receiptJson["totals"]["total"]} ${receiptJson["totals"]["currency"]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.memory(
                qrCodeBytes,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}






