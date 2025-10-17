import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_scanned) return;
          final codes = capture.barcodes;
          if (codes.isNotEmpty) {
            final b = codes.first;
            final String? code = b.rawValue ?? b.displayValue;
            if (code != null) {
              _scanned = true;
              Navigator.of(context).pop(code);
            }
          }
        },
      ),
    );
  }
}
