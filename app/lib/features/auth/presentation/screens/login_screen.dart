import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/screen_protector.dart';
import '../bloc/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool isOtp = false;
  String otp = '';

  @override
  Widget build(BuildContext context) {
    return ScreenProtector(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  Column(
                    children: [
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Image.asset('assets/images/logo.png', width: 50, height: 50, errorBuilder: (c,e,s) => const Icon(Icons.account_balance, size: 96)),
                            const SizedBox(height: 12),
                            const Text('KienLongBank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                  // Main form
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(labelText: 'Tên tài khoản'),
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 12),
                            if (!isOtp)
                              TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                                obscureText: true,
                              ),
                            if (isOtp)
                              TextField(
                                onChanged: (v) => otp = v,
                                decoration: const InputDecoration(labelText: 'OTP'),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(onPressed: () {}, child: const Text('Quên mật khẩu')),
                                TextButton(onPressed: () {}, child: const Text('Đăng ký')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isOtp) {
                                    context.read<AuthCubit>().loginOtp(
                                          phoneController.text,
                                          otp,
                                        );
                                  } else {
                                    context.read<AuthCubit>().login(
                                          phoneController.text,
                                          passwordController.text,
                                        );
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14.0),
                                  child: Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom menu
                  Padding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _BottomMenuItem(icon: Icons.phonelink_lock, label: 'eToken'),
                            const SizedBox(width: 24),
                            _BottomMenuItem(icon: Icons.qr_code, label: 'QR Scan'),
                            const SizedBox(width: 24),
                            _BottomMenuItem(icon: Icons.support_agent, label: 'Hỗ trợ'),
                            const SizedBox(width: 24),
                            _BottomMenuItem(icon: Icons.public, label: 'Mạng lưới'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BottomMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BottomMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 26, backgroundColor: Colors.blue.shade700, child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
