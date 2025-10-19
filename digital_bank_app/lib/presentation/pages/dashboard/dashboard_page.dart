import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/cubit/dashboard/dashboard_cubit.dart';
import '../../../presentation/cubit/dashboard/dashboard_state.dart';
import '../../../domain/entities/account.dart';
import 'package:intl/intl.dart';
import 'menu_grid.dart';
import 'new_slider.dart';

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
    // Dashboard does not manage navigation locally; NavigationPage handles it.

    return Scaffold(
      backgroundColor: Colors.white, // nền trắng cho body
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
                // Account block: outer dark wrapper full-width (match AppBar width)
                // with rounded bottom corners; inner top white box has rounded top corners only
                return Stack(
                  children: [
                    // Outer wrapper: nền tím chỉ phủ phía sau card trên
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        // chiều cao nền tím bằng chiều cao card trên
                        height: 100, // tuỳ chỉnh theo UI
                        margin: const EdgeInsets.symmetric(horizontal: -12.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D2A78),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    // Nội dung: 2 card trắng
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Card trên
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(current.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    const SizedBox(height: 6),
                                    Text('Số TK: ${current.number}',
                                        style: const TextStyle(
                                            color: Colors.black54)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.account_balance,
                                  color: Colors.black54),
                            ],
                          ),
                        ),

                        // Card dưới (sát card trên, không margin dọc)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDDDDDD).withOpacity(1.0),
                                blurRadius: 6,
                                offset: const Offset(0, 3), // shadow đổ xuống
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      _hideBalance
                                          ? '******'
                                          : _formatMoney(current.balance,
                                              current.currency),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => setState(
                                          () => _hideBalance = !_hideBalance),
                                      icon: Icon(
                                        _hideBalance
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownButton<String>(
                                value: _selectedAccountId,
                                items: accounts
                                    .map((a) => DropdownMenuItem(
                                        value: a.id, child: Text(a.name)))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedAccountId = v;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
             // Slider tin tức / quảng cáo
            const NewsSlider(),
            // Grid
            const Expanded(child: MenuGrid()),
          ],
        ),
      ),
      // Navigation is handled centrally by NavigationPage (BottomAppBar + FAB)
    );
  }
}
