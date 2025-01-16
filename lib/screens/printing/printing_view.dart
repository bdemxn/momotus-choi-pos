import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:qr_flutter/qr_flutter.dart';

class PrintingView extends StatefulWidget {
  const PrintingView({super.key});

  @override
  State<PrintingView> createState() => _PrintingViewState();
}

class _PrintingViewState extends State<PrintingView> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  List<Printer> printers = [];
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startScan();
      startServer();
    });
  }

  void startScan() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters(connectionTypes: [
      ConnectionType.USB,
      ConnectionType.BLE,
    ]);
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
      log(event.map((e) => e.name).toList().toString());
      setState(() {
        printers = event;
        printers.removeWhere(
            (element) => element.name == null || element.name == '');
      });
    });
  }

  void stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  Future<void> startServer() async {
    final app = shelf_router.Router();

    app.post('/printing_services', (Request request) async {
      final payload = await request.readAsString();
      final receiptJson = jsonDecode(payload) as Map<String, dynamic>;

      try {
        await _printReceipt(receiptJson);
        return Response.ok(
          jsonEncode({'status': 'success'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'status': 'error', 'message': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(app);

    final server = await io.serve(handler, '0.0.0.0', 8000);
    print('Servidor escuchando en http://${server.address.host}:${server.port}');
  }

  Future<void> _printReceipt(Map<String, dynamic> receiptJson) async {
    final printer = printers.firstWhere(
      (p) => p.isConnected ?? false,
      orElse: () {
        if (printers.isNotEmpty) {
          return printers.first; // Devuelve la primera impresora disponible
        }
        throw Exception("No hay impresoras conectadas o disponibles.");
      },
    );

    await _flutterThermalPrinterPlugin.connect(printer);

    await _flutterThermalPrinterPlugin.printWidget(
      context,
      printer: printer,
      widget: _buildReceiptWidget(receiptJson),
    );

    await _flutterThermalPrinterPlugin.disconnect(printer);
  }

  Future<ui.Image> generateQrCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final painter = QrPainter.withQr(qr: qrValidationResult.qrCode!);
      final image = await painter.toImage(200); // 200 px de tamaño
      return image;
    } else {
      throw Exception('Error al generar el código QR');
    }
  }

  Widget _buildReceiptWidget(Map<String, dynamic> receiptJson) {
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
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              Text("Sucursal: ${receiptJson["header"]["branch"]}"),
              Text("Fecha: ${receiptJson["header"]["date"]}"),
              Text("Cajero: ${receiptJson["header"]["cashier"]}"),
              Divider(thickness: 2),
              for (var item in receiptJson["items"])
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item["quantity"]}x ${item["name"]}"),
                    Text("${item["total"]} ${receiptJson["totals"]["currency"]}"),
                  ],
                ),
              Divider(thickness: 2),
              Text(
                "Total: ${receiptJson["totals"]["total"]} ${receiptJson["totals"]["currency"]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FutureBuilder<ui.Image>(
                future: generateQrCode(receiptJson["footer"]["qr_code_data"]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return RawImage(image: snapshot.data);
                  } else if (snapshot.hasError) {
                    return const Text("Error generando el código QR");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Printing Service'),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Servicio de impresión activo en /printing_services',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: startScan,
                      child: const Text('Get Printers'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: stopScan,
                      child: const Text('Stop Scan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: printers.length,
                  itemBuilder: (context, index) {
                    final printer = printers[index];
                    return ListTile(
                      title: Text(printer.name ?? 'Unknown Printer'),
                      subtitle: Text('Connected: ${printer.isConnected}'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          if (printer.isConnected ?? false) {
                            await _flutterThermalPrinterPlugin.disconnect(printer);
                          } else {
                            await _flutterThermalPrinterPlugin.connect(printer);
                          }
                          setState(() {});
                        },
                        child: Text(printer.isConnected ?? false ? 'Disconnect' : 'Connect'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}