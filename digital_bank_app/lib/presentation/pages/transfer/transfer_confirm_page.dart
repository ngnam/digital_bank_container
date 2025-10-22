// lib/presentation/transfer/transfer_confirm_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/transfer_entity.dart';
import '../../cubit/transfer/transfer_cubit.dart';
import '../../cubit/transfer/transfer_state.dart';
import 'dialog_confirm_otp.dart';

class TransferConfirmPage extends StatelessWidget {
  final TransferType type;
  final Account sourceAccount;
  final String targetAccount;
  final String receiverName;
  final double amount;
  final String currency;
  final String description;

  const TransferConfirmPage({
    Key? key,
    required this.type,
    required this.sourceAccount,
    required this.targetAccount,
    required this.receiverName,
    required this.amount,
    required this.currency,
    required this.description,
  }) : super(key: key);

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<TransferCubit>(); // lấy trước khi await

    final otpOk = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogConfirmOtp(defaultCode: '123456'),
    );
    if (otpOk != true) return;

    await cubit.transferMoney(
      type: type,
      sourceAccountId: sourceAccount.id,
      targetAccount: targetAccount,
      amount: amount,
      currency: currency,
      description: description,
    );

    // Sau khi gọi API, kiểm tra state hiện tại
    final state = cubit.state;
    if (state is TransferSuccess) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Chuyển tiền thành công'),
          content: Text('Mã giao dịch: ${state.transaction.id}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      Navigator.of(context).pop(); // đóng màn xác nhận
    } else if (state is TransferFailure) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Lỗi'),
          content: Text(state.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),d
      );
    }
  }

  String _typeLabel(TransferType t) =>
      t == TransferType.internal ? 'Nội bộ' : 'Liên ngân hàng';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransferCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận chuyển tiền'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<TransferCubit, TransferState>(
          builder: (context, state) {
            final isLoading = state is TransferLoading;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Loại chuyển', _typeLabel(type)),
                      const Divider(),
                      _row('Tài khoản nguồn',
                          '${sourceAccount.name} • ${sourceAccount.number}'),
                      _row('Người nhận', receiverName),
                      _row('Số tài khoản', targetAccount),
                      _row('Số tiền', cubit.formatCurrency(amount, currency)),
                      _row('Nội dung', description.isEmpty ? '-' : description),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : () => _confirm(context),
                          icon: const Icon(Icons.check),
                          label: const Text('Xác nhận'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.15),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
