import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/payment_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../domain/models/payment_request.dart';
import '../bloc/payment_cubit.dart';
import 'otp_screen.dart';

class PaymentFormScreen extends StatefulWidget {
  final PaymentRepository repository;
  final int? fromAccountId;
  final AccountRepository? accountRepository;
  const PaymentFormScreen({super.key, required this.repository, this.fromAccountId, this.accountRepository});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _bankController = TextEditingController();
  final _nameController = TextEditingController();
  String _transferType = 'internal'; // 'internal' or 'external'
  String? _fromOwnerName;

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _descController.dispose();
    _bankController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadOwnerNameIfNeeded();
  }

  Future<void> _loadOwnerNameIfNeeded() async {
    final repo = widget.accountRepository;
    final id = widget.fromAccountId;
    if (repo == null || id == null) return;
    try {
      final acc = await repo.getAccountDetail(id);
      if (!mounted) return;
      setState(() {
        _fromOwnerName = acc.ownerName;
      });
    } catch (_) {
      // ignore, fallback to id
    }
  }

  // Formatter that inserts thousand separators and keeps two decimals
  final _amountFormatter = ThousandsSeparatorInputFormatter();

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
                // Transfer type selector (Nội bộ / Liên ngân hàng)
                DropdownButtonFormField<String>(
                  value: _transferType,
                  decoration: const InputDecoration(labelText: 'Tranfer Type (Nội bộ / Liên ngân hàng)'),
                  items: const [
                    DropdownMenuItem(value: 'internal', child: Text('Nội bộ')),
                    DropdownMenuItem(value: 'external', child: Text('Liên ngân hàng')),
                  ],
                  onChanged: (v) => setState(() { if (v != null) _transferType = v; }),
                ),
                const SizedBox(height: 8),
                if (_transferType == 'internal')
                  TextFormField(controller: _toController, decoration: const InputDecoration(labelText: 'To account id'), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Required' : null,)
                else ...[
                  TextFormField(controller: _bankController, decoration: const InputDecoration(labelText: 'Bank code'), validator: (v) => v?.isEmpty == true ? 'Required' : null,),
                  TextFormField(controller: _toController, decoration: const InputDecoration(labelText: 'To account number'), validator: (v) => v?.isEmpty == true ? 'Required' : null,),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Recipient name'), validator: (v) => v?.isEmpty == true ? 'Required' : null,),
                ],
                TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [_amountFormatter], validator: (v) => v?.isEmpty == true ? 'Required' : null,),
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
                        final rawAmount = _amountController.text.replaceAll(',', '');
                        final amount = double.tryParse(rawAmount) ?? 0.0;
                        final formatted = NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount);
                        String toLabel = _transferType == 'internal' ? 'account ${_toController.text}' : '${_nameController.text} @ ${_bankController.text}';
                        final fromLabel = _fromOwnerName ?? fromId.toString();
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm payment'),
                            content: Text('Send $formatted from account $fromLabel to $toLabel?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        final req = _transferType == 'internal'
                          ? PaymentRequest(
                              fromAccountId: fromId,
                              toAccountId: int.tryParse(_toController.text),
                              amount: amount,
                              description: _descController.text,
                            )
                          : PaymentRequest(
                              fromAccountId: fromId,
                              toBankCode: _bankController.text,
                              toAccountNumber: _toController.text,
                              toName: _nameController.text,
                              amount: amount,
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

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final String separator;
  ThousandsSeparatorInputFormatter({this.separator = ','});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (text.isEmpty) return newValue;
    // remove non-number except dot
    text = text.replaceAll(RegExp('[^0-9.]'), '');
    // split decimals
    final parts = text.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '';
    if (decPart.length > 2) decPart = decPart.substring(0, 2);
    // add separators to int part
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final pos = intPart.length - i;
      buffer.write(intPart[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write(separator);
    }
    String formatted = buffer.toString();
    if (decPart.isNotEmpty) formatted = '$formatted.$decPart';

    // maintain cursor at end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
