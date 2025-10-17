import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/payment_repository.dart';
import '../../domain/models/payment_request.dart';
import '../bloc/payment_cubit.dart';
import 'otp_screen.dart';

class PaymentFormScreen extends StatefulWidget {
  final PaymentRepository repository;
  final int? fromAccountId;
  const PaymentFormScreen({super.key, required this.repository, this.fromAccountId});

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
                BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    final submitting = state is PaymentSubmitting;
                    return ElevatedButton(
                      onPressed: submitting ? null : () async {
                        // dismiss keyboard
                        FocusScope.of(context).unfocus();
                        if (!_formKey.currentState!.validate()) return;
                        final fromId = widget.fromAccountId;
                        if (fromId == null) {
                          // Shouldn't happen because menu requires selection, but guard anyway
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No from account selected')));
                          return;
                        }
                        final amount = double.tryParse(_amountController.text) ?? 0.0;
                        final formatted = NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount);
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm payment'),
                            content: Text('Send $formatted from account $fromId to ${_toController.text}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        final req = PaymentRequest(
                          fromAccountId: fromId,
                          toAccountId: int.tryParse(_toController.text),
                          amount: double.tryParse(_amountController.text) ?? 0.0,
                          description: _descController.text,
                        );
                        context.read<PaymentCubit>().submitInternal(req);
                      },
                      child: submitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit'),
                    );
                  },
                ),
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
                    // UI for states handled inline (button shows submitting); nothing extra to render here
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
