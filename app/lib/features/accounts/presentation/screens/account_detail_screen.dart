import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/account_detail_cubit.dart';
import '../../domain/usecases/get_account_detail.dart';
import 'package:intl/intl.dart';

class AccountDetailScreen extends StatelessWidget {
  final int accountId;
  final void Function(int) onViewTransactions;
  final GetAccountDetail getAccountDetail;
  const AccountDetailScreen({super.key, required this.accountId, required this.onViewTransactions, required this.getAccountDetail});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountDetailCubit(getAccountDetail)..fetchDetail(accountId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Account Detail')),
        body: BlocBuilder<AccountDetailCubit, AccountDetailState>(
          builder: (context, state) {
            if (state is AccountDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountDetailLoaded) {
              final account = state.account;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(account.ownerName),
                    subtitle: Text(
                      'Balance: ${NumberFormat('#,##0.00').format(account.balance ?? 0)}${account.currency == 'VND' ? ' đ' : ' ${account.currency}'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  ListTile(
                    title: const Text('Account Number'),
                    subtitle: Text(account.accountNumber),
                  ),
                  ElevatedButton(
                    onPressed: () => onViewTransactions(account.id),
                    child: const Text('View Transactions'),
                  ),
                ],
              );
            } else if (state is AccountDetailError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
