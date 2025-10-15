import 'package:flutter/material.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';

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