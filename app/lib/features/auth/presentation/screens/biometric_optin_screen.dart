import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricOptInScreen extends StatefulWidget {
  final VoidCallback onEnabled;
  const BiometricOptInScreen({super.key, required this.onEnabled});

  @override
  State<BiometricOptInScreen> createState() => _BiometricOptInScreenState();
}

class _BiometricOptInScreenState extends State<BiometricOptInScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheck = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      setState(() => _canCheck = canCheck);
    } catch (e) {
      setState(() => _error = 'Biometric not available');
    }
  }

  Future<void> _enable() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Enable biometric login',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated) widget.onEnabled();
    } catch (e) {
      setState(() => _error = 'Authentication failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Enable FaceID/TouchID for quick login'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _canCheck ? _enable : null,
            child: const Text('Enable Biometric'),
          ),
        ],
      ),
    );
  }
}
