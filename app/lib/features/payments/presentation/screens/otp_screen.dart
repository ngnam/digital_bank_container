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
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: PaymentCubit(widget.repository),
      child: Scaffold(
        appBar: AppBar(title: const Text('Confirm OTP')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Payment id: ${widget.paymentId}'),
              TextField(controller: _otpController, decoration: const InputDecoration(labelText: 'OTP')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () {
                final otp = _otpController.text.trim();
                context.read<PaymentCubit>().confirm(widget.paymentId, otp);
              }, child: const Text('Confirm')),
              BlocConsumer<PaymentCubit, PaymentState>(
                listener: (context, state) {
                  if (state is PaymentSuccess) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (state is PaymentError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) => state is PaymentSubmitting ? const CircularProgressIndicator() : const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
