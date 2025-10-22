// lib/presentation/transfer/transfer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/transfer_entity.dart';
import '../../cubit/transfer/transfer_cubit.dart';
import '../../cubit/transfer/transfer_state.dart';
import 'transfer_confirm_page.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  TransferType _type = TransferType.internal;
  Account? _sourceAccount;
  String _targetAccount = '';
  String _receiverName = '';
  String _description = '';
  String _currency = 'VND';
  double? _amount;

  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _targetController.addListener(_onTargetChanged);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _targetController.dispose();
    _receiverController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final accounts = await context.read<TransferCubit>().loadAccounts();
    setState(() {
      _accounts = accounts;
      _sourceAccount = accounts.isNotEmpty ? accounts.first : null;
      _currency = _sourceAccount?.currency ?? 'VND';
    });
  }

  void _onTargetChanged() {
    final input = _targetController.text.trim();
    // Mock auto-fill: nếu số TK có 10 chữ số
    if (RegExp(r'^\d{10}$').hasMatch(input)) {
      // giả lập tên người nhận
      setState(() {
        _receiverName = 'Người nhận #${input.substring(6)}';
        _receiverController.text = _receiverName;
      });
    }
  }

  void _onAmountChanged() {
    // auto mask VND: hiển thị ngăn cách đơn giản
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) {
      setState(() => _amount = null);
      return;
    }
    final parsed = double.tryParse(raw);
    if (parsed != null) {
      setState(() => _amount = parsed.toDouble());
    }
  }

  void _submit() {
    final error = context.read<TransferCubit>().validateForm(
          type: _type,
          sourceAccountId: _sourceAccount?.id,
          targetAccount: _targetAccount,
          amount: _amount,
        );
    if (error != null) {
      _showDialog(title: 'Lỗi', message: error);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TransferConfirmPage(
        type: _type,
        sourceAccount: _sourceAccount!,
        targetAccount: _targetAccount,
        receiverName: _receiverName,
        amount: _amount!,
        currency: _currency,
        description: _description,
      ),
    ));
  }

  Future<void> _showDialog({required String title, required String message}) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransferCubit, TransferState>(
      listener: (context, state) async {
        final navigator = Navigator.of(context); // lấy trước khi await

        if (state is TransferFailure) {
          await _showDialog(title: 'Lỗi', message: state.message);
        } else if (state is TransferSuccess) {
          await _showDialog(
            title: 'Chuyển tiền thành công',
            message: 'Mã giao dịch: ${state.transaction.id}',
          );
          navigator.pop(); // dùng navigator đã lưu
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chuyển tiền'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Loại chuyển
                  DropdownButtonFormField<TransferType>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Loại chuyển',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TransferType.internal,
                        child: Text('Nội bộ'),
                      ),
                      DropdownMenuItem(
                        value: TransferType.external,
                        child: Text('Liên ngân hàng'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _type = v ?? TransferType.internal),
                  ),
                  const SizedBox(height: 12),
                  // Tài khoản người chuyển
                  DropdownButtonFormField<Account>(
                    value: _sourceAccount,
                    decoration: const InputDecoration(
                      labelText: 'Tài khoản nguồn',
                      border: OutlineInputBorder(),
                    ),
                    items: _accounts
                        .map((a) => DropdownMenuItem(
                              value: a,
                              child: Text(
                                  '${a.name} • ${a.number} • ${a.currency}'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _sourceAccount = v;
                        _currency = v?.currency ?? 'VND';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Số tài khoản người nhận
                  TextFormField(
                    controller: _targetController,
                    decoration: const InputDecoration(
                      labelText: 'Số tài khoản người nhận',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _targetAccount = v.trim(),
                  ),
                  const SizedBox(height: 12),
                  // Tên người nhận
                  TextFormField(
                    controller: _receiverController,
                    decoration: const InputDecoration(
                      labelText: 'Tên người nhận',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _receiverName = v.trim(),
                  ),
                  const SizedBox(height: 12),
                  // Số tiền
                  TextFormField(
                    controller: _amountController,
                   decoration: InputDecoration(
                      labelText: 'Số tiền ($_currency)',
                      border: const OutlineInputBorder(),
                      hintText: 'VD: 1,000,000',
                    ),

                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  // Nội dung
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung chuyển khoản',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _description = v.trim(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Tiếp tục'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
