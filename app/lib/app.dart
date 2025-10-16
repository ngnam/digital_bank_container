import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/accounts/presentation/screens/account_list_screen.dart';
import 'features/accounts/presentation/screens/transaction_history_screen.dart';
import 'features/accounts/presentation/screens/account_detail_screen.dart';
import 'features/accounts/domain/usecases/get_account_detail.dart';
import 'features/accounts/domain/usecases/get_transactions.dart';
import 'features/accounts/domain/repositories/account_repository.dart';
import 'features/accounts/domain/entities/account_entity.dart';
import 'features/accounts/domain/entities/transaction_entity.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kieng Long Bank',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

// Minimal fake repository used only to provide typed usecases for navigation in HomePage.
class _FakeAccountRepository implements AccountRepository {
  @override
  Future<List<AccountEntity>> getAccounts({int page = 0, int size = 20, String? sort, String? ifNoneMatch}) async => [];

  @override
  Future<AccountEntity> getAccountDetail(int id, {String? ifNoneMatch, String? ifModifiedSince}) async =>
    throw UnimplementedError('Fake repository does not provide account details');

  @override
  Future<List<TransactionEntity>> getTransactions(int accountId, {int page = 0, int size = 20, String? from, String? to, String? type, String? ifModifiedSince}) async => [];
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Minimal fake repository to provide typed GetAccountDetail and GetTransactions
    final _fakeRepo = _FakeAccountRepository();
    final _getAccountDetail = GetAccountDetail(_fakeRepo);
    final _getTransactions = GetTransactions(_fakeRepo);

    return Scaffold(
      appBar: AppBar(title: const Text('Kieng Long Bank')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Accounts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountListScreen(
                    onAccountTap: (account) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AccountDetailScreen(
                        accountId: account.id,
                        getAccountDetail: _getAccountDetail,
                        onViewTransactions: (int id) => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionHistoryScreen(accountId: id, getTransactions: _getTransactions))),
                      )));
                    },
                  )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Transaction History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TransactionHistoryScreen(accountId: 0, getTransactions: _getTransactions)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Account Detail'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountDetailScreen(
                    accountId: 0,
                    getAccountDetail: _getAccountDetail,
                    onViewTransactions: (int id) => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionHistoryScreen(accountId: id, getTransactions: _getTransactions))),
                  )),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Welcome to Kieng Long Bank!')),
    );
  }
}
