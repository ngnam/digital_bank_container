import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/payment_repository.dart';
import '../../domain/models/payment_request.dart';
import '../bloc/payment_cubit.dart';
import 'otp_screen.dart';

class PaymentFormScreen extends StatefulWidget {
  final PaymentRepository repository;
  const PaymentFormScreen({super.key, required this.repository});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentCubit(widget.repository),
      child: Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(controller: _toController, decoration: const InputDecoration(labelText: 'To account / number'), validator: (v) => v?.isEmpty == true ? 'Required' : null,),
                TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Required' : null,),
                TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final req = PaymentRequest(fromAccountId: 1, toAccountId: int.tryParse(_toController.text), amount: double.tryParse(_amountController.text) ?? 0.0, description: _descController.text);
                    context.read<PaymentCubit>().submitInternal(req);
                  }
                }, child: const Text('Submit')),
                const SizedBox(height: 12),
                BlocConsumer<PaymentCubit, PaymentState>(
                  listener: (context, state) {
                    if (state is PaymentPending2FA) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(repository: widget.repository, paymentId: state.response.id)));
                    } else if (state is PaymentSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment success')));
                    } else if (state is PaymentError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    if (state is PaymentSubmitting) return const CircularProgressIndicator();
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
