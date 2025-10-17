import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/payment_repository.dart';
import '../bloc/payment_cubit.dart';

class OtpScreen extends StatefulWidget {
  final PaymentRepository repository;
  final String paymentId;
  const OtpScreen({super.key, required this.repository, required this.paymentId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otpController.text = '0000'; // prefill for testing
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Payment id: ${widget.paymentId}'),
            TextField(controller: _otpController, decoration: const InputDecoration(labelText: 'OTP')),
            const SizedBox(height: 12),
            BlocBuilder<PaymentCubit, PaymentState>(
              builder: (context, state) {
                final submitting = state is PaymentSubmitting;
                return ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () {
                          // Use fake OTP for testing flows
                          final otp = '0000';
                          _otpController.text = otp;
                          context.read<PaymentCubit>().confirm(widget.paymentId, otp);
                        },
                  child: submitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm'),
                );
              },
            ),
            BlocConsumer<PaymentCubit, PaymentState>(
              listener: (context, state) {
                if (state is PaymentSuccess) {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    messenger.showSnackBar(const SnackBar(content: Text('Payment success')));
                    Future.delayed(const Duration(milliseconds: 700), () {
                      if (!mounted) return;
                      navigator.popUntil((route) => route.isFirst);
                    });
                } else if (state is PaymentError) {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) => const SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }
}
