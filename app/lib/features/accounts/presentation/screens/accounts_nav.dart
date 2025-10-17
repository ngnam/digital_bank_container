import 'package:flutter/material.dart';
import 'dart:convert';
import 'account_detail_screen.dart';
import 'qr_scanner_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../payments/presentation/screens/pending_payments_screen.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/usecases/get_account_detail.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/datasources/dummy_account_local_datasource.dart';
import '../bloc/account_list_cubit.dart';
import '../bloc/selected_account_cubit.dart';
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
  dynamic _selectedAccount;
  bool _showBalance = false;

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
    if (index == 2) {
      // open QR scanner
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen())).then((result) {
        if (result != null) {
          final repo = widget.paymentRepository ?? MockPaymentRepository(Dio());
              // try to parse structured QR payloads (JSON or URI) and pass parsed fields to payment form
              final parsed = _parseQrPayload(result.toString());
              Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentFormScreen(
                repository: repo,
                fromAccountId: _selectedAccountId,
                accountRepository: _repo,
                scannedTo: parsed['to'] as String?,
                scannedName: parsed['name'] as String?,
                scannedBank: parsed['bank'] as String?,
                scannedAmount: parsed['amount']?.toString(),
                scannedTransferType: parsed['type'] as String?,
              )));
        }
      });
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showAccountPicker() async {
    // Use the AccountListCubit to fetch and display accounts
    final cubit = AccountListCubit(GetAccounts(_repo));
    await cubit.fetchAccounts();
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<AccountListCubit, AccountListState>(
          builder: (context, state) {
            if (state is AccountListLoading) return const Center(child: CircularProgressIndicator());
            if (state is AccountListError) return Center(child: Text(state.message));
            if (state is AccountListLoaded) {
              return ListView(
                shrinkWrap: true,
                children: state.accounts.map<Widget>((a) => ListTile(
                  title: Text('${a.ownerName} • ${a.accountNumber}'),
                  subtitle: Text('${a.balance ?? 0} ${a.currency}'),
                  onTap: () => Navigator.of(context).pop(a),
                )).toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    if (result != null) {
      // persist selection in SelectedAccountCubit so other screens can read it
      // If a SelectedAccountCubit exists in the tree, use it; otherwise set local state
      try {
        final sel = BlocProvider.of<SelectedAccountCubit>(context);
        sel.select(result);
      } catch (_) {}
      setState(() {
        _selectedAccount = result;
        _selectedAccountId = result.id;
      });
    }
  }

  void _onAccountTap(account) {
    setState(() {
      _selectedAccountId = account.id;
      _selectedAccount = account;
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
    // New body layout: index 0 = home functions, 1 = account detail, 2 = QR, 3 = inbox, 4 = profile
    if (_selectedIndex == 0) {
      body = Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildTile(icon: Icons.send, label: 'Chuyển tiền', onTap: (){
              final repo = widget.paymentRepository ?? MockPaymentRepository(Dio());
              Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentFormScreen(repository: repo, fromAccountId: _selectedAccountId, accountRepository: _repo)));
            }),
            _buildTile(icon: Icons.list, label: 'Templates', onTap: (){
              final repo = widget.paymentRepository ?? MockPaymentRepository(Dio(), localDb: PaymentLocalDbImpl());
              Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateListScreen(repository: repo)));
            }),
            _buildTile(icon: Icons.schedule, label: 'Schedules', onTap: (){
              final repo = widget.paymentRepository ?? MockPaymentRepository(Dio(), localDb: PaymentLocalDbImpl());
              Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleListScreen(repository: repo, accountRepository: _repo)));
            }),
            _buildTile(icon: Icons.savings, label: 'Tiết kiệm', onTap: (){
              // savings placeholder
            }),
            _buildTile(icon: Icons.logout, label: 'Logout', onTap: (){
              try { BlocProvider.of<AuthCubit>(context).logout(); } catch (_) {}
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ],
        ),
      );
    } else if (_selectedIndex == 1 && _selectedAccountId != null) {
      body = AccountDetailScreen(
        accountId: _selectedAccountId!,
        onViewTransactions: _onViewTransactions,
        getAccountDetail: _getAccountDetail,
      );
    } else if (_selectedIndex == 2) {
      body = const Center(child: Icon(Icons.qr_code, size: 120));
    } else if (_selectedIndex == 3) {
      body = const Center(child: Text('Hòm thư (Inbox)'));
    } else if (_selectedIndex == 4) {
      body = const Center(child: Text('Cá nhân (Profile)'));
    } else {
      body = const Center(child: Text('Select an account'));
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountListCubit>(
          create: (_) => AccountListCubit(GetAccounts(_repo)),
        ),
        BlocProvider<SelectedAccountCubit>(
          create: (_) => SelectedAccountCubit(),
        ),
        if (_selectedIndex == 2 && _selectedAccountId != null)
          BlocProvider<TransactionHistoryCubit>(
            create: (_) => TransactionHistoryCubit(_getTransactions),
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: GestureDetector(
            onTap: () {
              // open accounts list by navigating to Accounts tab
              setState(() => _selectedIndex = 0);
            },
            child: Column(
              children: [
                if (_selectedAccount != null) ...[
                  Text('${_selectedAccount.ownerName} • ${_selectedAccount.accountNumber}', style: const TextStyle(fontSize: 16)),
                ] else ...[
                  const Text('Digital Bank', style: TextStyle(fontSize: 16)),
                ],
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedAccount != null ? (_showBalance ? '${_selectedAccount.balance} ${_selectedAccount.currency}' : '••••••') : ''),
                    const SizedBox(width: 6),
                    if (_selectedAccount != null)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(_showBalance ? Icons.visibility : Icons.visibility_off, size: 18),
                        onPressed: () => setState(() => _showBalance = !_showBalance),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Debug pending payments',
              icon: const Icon(Icons.bug_report),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PendingPaymentsScreen(repository: widget.paymentRepository)));
              },
            ),
            IconButton(
              tooltip: 'Thông báo',
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // notifications placeholder
              },
            ),
          ],
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.account_box), label: 'Tài khoản'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Quét QR'),
            BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Hòm thư'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: Colors.blue.shade50, child: Icon(icon, color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }

  /// Parses QR payloads into a map of common payment fields.
  /// Supports JSON payloads like:
  /// {"to":"123","name":"Nguyen","amount":1000,"bank":"KLB","type":"internal"}
  /// and URI-style payloads like: "bankpay://pay?to=123&name=Nguyen&amount=1000&bank=KLB&type=internal"
  Map<String, dynamic> _parseQrPayload(String raw) {
    raw = raw.trim();
    // try JSON first
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // not JSON
    }

    // try URI with query params
    try {
      final uri = Uri.parse(raw);
      if (uri.queryParameters.isNotEmpty) {
        final params = Map<String, dynamic>.from(uri.queryParameters);
        // try to convert amount to number if present
        if (params['amount'] != null) {
          final a = num.tryParse(params['amount']!.toString());
          if (a != null) params['amount'] = a;
        }
        return params;
      }
    } catch (_) {
      // not a URI
    }

    // fallback: treat the entire string as the 'to' value
    return {'to': raw};
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
