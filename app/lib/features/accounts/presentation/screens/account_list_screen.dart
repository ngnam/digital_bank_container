import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/account_list_cubit.dart';
import '../../domain/entities/account_entity.dart';

class AccountListScreen extends StatelessWidget {
  final void Function(AccountEntity) onAccountTap;
  final VoidCallback? onRefresh;
  const AccountListScreen({super.key, required this.onAccountTap, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: BlocBuilder<AccountListCubit, AccountListState>(
        builder: (context, state) {
          if (state is AccountListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AccountListLoaded) {
            return RefreshIndicator(
              onRefresh: () async => onRefresh?.call(),
              child: ListView.builder(
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];
                  return ListTile(
                    title: Text(account.ownerName),
                    subtitle: Text('Balance: ${account.balance ?? 0}'),
                    onTap: () => onAccountTap(account),
                  );
                },
              ),
            );
          } else if (state is AccountListError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
