import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/cubit/dashboard/dashboard_cubit.dart';
import '../../../presentation/cubit/dashboard/dashboard_state.dart';
import '../../../domain/entities/account.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadAccounts();
  }

  String _formatMoney(double v, String currency) {
    // simple formatting
    final formatted = v.toStringAsFixed(2).replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    if (currency == 'VND') return '$formatted Đồng';
    return '\$$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/lauchIcon.png', height: 28),
            const SizedBox(width: 8),
            const Text('Digital Bank'),
          ],
        ),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state.status == DashboardStatus.loading) return const CircularProgressIndicator();
                final accounts = state.accounts;
                final current = accounts.isNotEmpty ? accounts.first : Account(id: '', name: '-', number: '-', balance: 0, currency: 'VND');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(current.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Số TK: ${current.number}'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(_hideBalance ? '******' : _formatMoney(current.balance, current.currency), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  IconButton(onPressed: () => setState(() => _hideBalance = !_hideBalance), icon: Icon(_hideBalance ? Icons.visibility_off : Icons.visibility)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
                          value: accounts.isNotEmpty ? accounts.first.id : null,
                          items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                          onChanged: (v) {},
                        )
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
        currentIndex: 0,
        onTap: (i) {},
      ),
    );
  }
}
