import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'printer_controller.dart';

class PrintingView extends StatefulWidget {
  final PrinterController controller;

  const PrintingView({super.key, required this.controller});

  @override
  State<PrintingView> createState() => _PrintingViewState();
}

class _PrintingViewState extends State<PrintingView> {
  late Stream<List<Printer>> printersStream;

  @override
  void initState() {
    super.initState();
    printersStream = widget.controller.printersStream;
    widget.controller.startScan();
  }

  @override
  void dispose() {
    widget.controller.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectar Impresora'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selecciona una impresora para conectar:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Printer>>(
              stream: printersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al buscar impresoras: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron impresoras.'),
                  );
                }

                final printers = snapshot.data!;
                return ListView.builder(
                  itemCount: printers.length,
                  itemBuilder: (context, index) {
                    final printer = printers[index];
                    return ListTile(
                      title: Text(printer.name ?? 'Impresora desconocida'),
                      subtitle: Text('Conectado: ${printer.isConnected}'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          if (printer.isConnected ?? false) {
                            await widget.controller.disconnectPrinter();
                          } else {
                            await widget.controller.connectPrinter(printer);
                          }
                          setState(() {});
                        },
                        child: Text(
                          printer.isConnected ?? false ? 'Desconectar' : 'Conectar',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}