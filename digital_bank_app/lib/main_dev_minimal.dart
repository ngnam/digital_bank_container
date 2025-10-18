import 'package:flutter/material.dart';
import 'core/constants.dart';

void main() {
  // quick minimal entrypoint for testing on device
  currentFlavor = Flavor.dev;
  runApp(const MaterialApp(home: _SmokeTestPage()));
}

class _SmokeTestPage extends StatelessWidget {
  const _SmokeTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smoke test')),
      body: const Center(child: Text('App launch OK — minimal entrypoint')),
    );
  }
}
