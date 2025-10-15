import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Widget dùng để chặn chụp màn hình trên Android/iOS.
class ScreenProtector extends StatefulWidget {
  final Widget child;
  const ScreenProtector({super.key, required this.child});

  @override
  State<ScreenProtector> createState() => _ScreenProtectorState();
}

class _ScreenProtectorState extends State<ScreenProtector> {
  static const _channel = MethodChannel('screen_protector');

  @override
  void initState() {
    super.initState();
    _enableSecure();
  }

  @override
  void dispose() {
    _disableSecure();
    super.dispose();
  }

  Future<void> _enableSecure() async {
    try {
      await _channel.invokeMethod('enableSecure');
    } catch (_) {}
  }

  Future<void> _disableSecure() async {
    try {
      await _channel.invokeMethod('disableSecure');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
