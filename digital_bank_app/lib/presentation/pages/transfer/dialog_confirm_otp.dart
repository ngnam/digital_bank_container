// lib/presentation/transfer/widgets/dialog_confirm_otp.dart
import 'package:flutter/material.dart';

class DialogConfirmOtp extends StatefulWidget {
  final String defaultCode;
  const DialogConfirmOtp({Key? key, this.defaultCode = '123456'})
      : super(key: key);

  @override
  State<DialogConfirmOtp> createState() => _DialogConfirmOtpState();
}

class _DialogConfirmOtpState extends State<DialogConfirmOtp> {
  final _controllers = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _submit() {
    final ok = _code.length == 6 && _code == widget.defaultCode;
    Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận OTP'),
      content: SizedBox(
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 36,
              child: TextField(
                controller: _controllers[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            );
          }),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy')),
        ElevatedButton(onPressed: _submit, child: const Text('Xác nhận')),
      ],
    );
  }
}
