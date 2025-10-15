import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'features/accounts/presentation/screens/account_list_screen.dart';
import 'features/accounts/presentation/screens/transaction_history_screen.dart';
import 'features/accounts/presentation/screens/account_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kieng Long Bank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
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
                  MaterialPageRoute(builder: (_) => const AccountListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Transaction History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Account Detail'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountDetailScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Xin chào, ${user.displayName ?? user.phoneNumber}'),
            const SizedBox(height: 8),
            Text('Số điện thoại: ${user.phoneNumber}'),
            const SizedBox(height: 8),
            Text('ID: ${user.id}'),
          ],
        ),
      ),
    );
  }
}