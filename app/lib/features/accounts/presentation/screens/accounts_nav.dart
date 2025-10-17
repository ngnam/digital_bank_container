import 'package:flutter/material.dart';
import 'account_list_screen.dart';
import 'account_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import 'transaction_history_screen.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/usecases/get_account_detail.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/datasources/dummy_account_local_datasource.dart';
import '../bloc/account_list_cubit.dart';
import '../../domain/usecases/get_accounts.dart';
import '../bloc/transaction_history_cubit.dart';
import 'package:dio/dio.dart';
import '../../../payments/data/payment_repository.dart';
import '../../../payments/presentation/screens/payment_form_screen.dart';
import '../../../payments/data/payment_local_db_impl.dart';
import '../../../payments/presentation/screens/template_list_screen.dart';
import '../../../payments/presentation/screens/schedule_list_screen.dart';

class AccountsNav extends StatefulWidget {
  final dynamic paymentRepository;
  const AccountsNav({super.key, this.paymentRepository});

  @override
  State<AccountsNav> createState() => _AccountsNavState();
}

class _AccountsNavState extends State<AccountsNav> {
  late final AccountRepositoryImpl _repo;
  late final GetAccountDetail _getAccountDetail;
  late final GetTransactions _getTransactions;

  @override
  void initState() {
    super.initState();
    // Replace with actual local/remote implementations as needed
    final remote = MockAccountRemoteDataSource();
    final local = DummyAccountLocalDataSource();
    _repo = AccountRepositoryImpl(remote: remote, local: local);
    _getAccountDetail = GetAccountDetail(_repo);
    _getTransactions = GetTransactions(_repo);
  }
  int _selectedIndex = 0;
  int? _selectedAccountId;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAccountTap(account) {
    setState(() {
      _selectedAccountId = account.id;
      _selectedIndex = 1;
    });
  }

  void _onViewTransactions(int accountId) {
    setState(() {
      _selectedAccountId = accountId;
      _selectedIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedIndex == 0) {
      body = AccountListScreen(onAccountTap: _onAccountTap);
    } else if (_selectedIndex == 1 && _selectedAccountId != null) {
      body = AccountDetailScreen(
        accountId: _selectedAccountId!,
        onViewTransactions: _onViewTransactions,
        getAccountDetail: _getAccountDetail,
      );
    } else if (_selectedIndex == 2 && _selectedAccountId != null) {
      body = BlocProvider<TransactionHistoryCubit>(
        create: (_) => TransactionHistoryCubit(_getTransactions),
        child: TransactionHistoryScreen(
          accountId: _selectedAccountId!,
          getTransactions: _getTransactions,
        ),
      );
    } else {
      body = const Center(child: Text('Select an account'));
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountListCubit>(
          create: (_) => AccountListCubit(GetAccounts(_repo)),
        ),
        if (_selectedIndex == 2 && _selectedAccountId != null)
          BlocProvider<TransactionHistoryCubit>(
            create: (_) => TransactionHistoryCubit(_getTransactions),
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chức năng chính'),
          actions: [
            IconButton(
              icon: const Icon(Icons.payment),
              tooltip: 'Payments',
              onPressed: () {
                // Require an account to be selected before opening payments
                if (_selectedAccountId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an account first')));
                  return;
                }
                // Open a small payments menu
                Navigator.push(context, MaterialPageRoute(builder: (_) => _PaymentsMenu(repository: widget.paymentRepository, accountId: _selectedAccountId, accountRepository: _repo)));
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                try {
                  BlocProvider.of<AuthCubit>(context).logout();
                } catch (_) {}
              },
            ),
          ],
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Accounts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Detail',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Transactions',
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsMenu extends StatelessWidget {
  final dynamic repository;
  final int? accountId;
  final dynamic accountRepository;
  const _PaymentsMenu({super.key, this.repository, this.accountId, this.accountRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('New Payment'),
            onTap: () {
              final repo = repository ?? MockPaymentRepository(Dio());
              Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentFormScreen(repository: repo, fromAccountId: accountId, accountRepository: accountRepository)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Templates'),
            onTap: () {
              final repo = repository ?? MockPaymentRepository(Dio(), localDb: PaymentLocalDbImpl());
              Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateListScreen(repository: repo)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedules'),
            onTap: () {
              final repo = repository ?? MockPaymentRepository(Dio(), localDb: PaymentLocalDbImpl());
              Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleListScreen(repository: repo, accountRepository: accountRepository)));
            },
          ),
        ],
      ),
    );
  }
}
