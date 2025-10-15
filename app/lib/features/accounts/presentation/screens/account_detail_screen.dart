import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/account_detail_cubit.dart';
import '../bloc/account_detail_state.dart';
import '../../domain/entities/account_entity.dart';

class AccountDetailScreen extends StatelessWidget {
  final int accountId;
  final void Function(int) onViewTransactions;
  const AccountDetailScreen({Key? key, required this.accountId, required this.onViewTransactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountDetailCubit(context.read())..fetchDetail(accountId),
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
                    title: Text(account.name),
                    subtitle: Text('Balance: ${account.balance}'),
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
