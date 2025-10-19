import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/cubit/dashboard/dashboard_cubit.dart';
import '../../../presentation/cubit/navigation_cubit.dart';
import '../../../presentation/cubit/dashboard/dashboard_state.dart';
import '../../../domain/entities/account.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _hideBalance = false;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadAccounts();
  }

  String _formatMoney(double v, String currency) {
    if (currency.toUpperCase() == 'VND') {
      final f = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
      return f.format(v);
    }
    final f = NumberFormat.simpleCurrency(locale: 'en_US', name: currency);
    return f.format(v);
  }

  @override
  Widget build(BuildContext context) {
    // Try to read NavigationCubit if available. If not available (page used standalone),
    // fall back to local no-op behavior to avoid exceptions.
    NavigationCubit? navCubit;
    int navIndex = 0;
    try {
      navCubit = context.read<NavigationCubit>();
      navIndex = navCubit.state.index;
    } catch (_) {
      navCubit = null;
      navIndex = 0;
    }

    return Scaffold(
      // AppBar with custom background (no rounded corners)
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2A78),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo (if the asset supports tinting it can be colored white)
            Image.asset(
              'assets/images/lauchIcon.png',
              height: 28,
              // keep error fallback
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 28, height: 28, child: Icon(Icons.account_balance, size: 20, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            const Text('DigitalBank', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications, color: Colors.white)),
        ],
      ),
      // keep content flush with AppBar (top padding 0) so the dark wrapper sits against the AppBar
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
        child: Column(
          children: [
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state.status == DashboardStatus.loading) return const CircularProgressIndicator();
                final accounts = state.accounts;
                final current = accounts.firstWhere((a) => a.id == (_selectedAccountId ?? accounts.first.id), orElse: () => accounts.isNotEmpty ? accounts.first : Account(id: '', name: '-', number: '-', balance: 0, currency: 'VND'));
                _selectedAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;
                // Account block: compressed horizontally by 6px on each side.
                // Outer dark wrapper sits flush under the AppBar; inside it we show
                // a white inner box with account name/number (black text).
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Container(
                    // Outer dark wrapper + shadow
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2A78),
                      boxShadow: [BoxShadow(color: const Color(0xFFDDDDDD).withOpacity(1.0), blurRadius: 6, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top wrapper (full width dark background). Inner white box shows account name/number.
                        Container(
                          // no top margin/padding so it sits flush under AppBar
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(current.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                      const SizedBox(height: 6),
                                      Text('Số TK: ${current.number}', style: const TextStyle(color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.account_balance, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),

                        // Bottom half: white background containing balance and account selector
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(_hideBalance ? '******' : _formatMoney(current.balance, current.currency), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    IconButton(onPressed: () => setState(() => _hideBalance = !_hideBalance), icon: Icon(_hideBalance ? Icons.visibility_off : Icons.visibility)),
                                  ],
                                ),
                              ),
                              DropdownButton<String>(
                                value: _selectedAccountId,
                                items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedAccountId = v;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                children: List.generate(12, (i) {
                  final icons = [Icons.send, Icons.savings, Icons.payment, Icons.account_balance_wallet, Icons.payments, Icons.mobile_friendly, Icons.contactless, Icons.history, Icons.support, Icons.receipt, Icons.more_horiz, Icons.card_giftcard];
                  final titles = ['Chuyển tiền', 'Tiết kiệm', 'Thanh toán', 'Nạp tiền', 'Rút tiền', 'Nạp ĐT', 'QR Pay', 'Lịch sử', 'Hỗ trợ', 'Hóa đơn', 'Khác', 'Ưu đãi'];
                  return Card(
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(icons[i], size: 28), const SizedBox(height: 8), Text(titles[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner, size: 36), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Hộp thư'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        currentIndex: navIndex,
        onTap: (i) {
          if (navCubit != null) {
            navCubit.changeIndex(i);
          }
        },
      ),
    );
  }
}
