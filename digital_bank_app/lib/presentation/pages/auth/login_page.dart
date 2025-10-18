import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/auth/login_cubit.dart';
import '../../cubit/auth/login_state.dart';
import '../../cubit/auth/otp_cubit.dart';
import '../../cubit/auth/otp_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showOtpSheet(BuildContext context, LoginCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: BlocProvider(
            create: (_) => OtpCubit()..sendOtp(),
            child: _OtpSheet(cubit: cubit),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            Column(
              children: [
                Image.asset('assets/images/lauchIcon.png', width: 96, height: 96),
                const SizedBox(height: 8),
                const Text('Digital Bank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(labelText: 'Tên tài khoản'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Quên mật khẩu')),
                      TextButton(onPressed: () {}, child: const Text('Đăng ký')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BlocConsumer<LoginCubit, LoginState>(
                    listenWhen: (previous, current) => previous.status != current.status,
                    listener: (context, state) {
                      if (state.status == LoginStatus.success) {
                        // only open OTP sheet when we transition to success
                        _showOtpSheet(context, cubit);
                      } else if (state.status == LoginStatus.otpVerified) {
                        // navigate to DashboardNavigator (placeholder)
                        Navigator.of(context).pushReplacementNamed('/dashboard');
                      } else if (state.status == LoginStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message ?? 'Lỗi đăng nhập')));
                      }
                    },
                    builder: (context, state) {
                      final loading = state.status == LoginStatus.loading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () => cubit.login(_userController.text.trim(), _passController.text.trim()),
                          child: loading ? const CircularProgressIndicator(strokeWidth: 2.0) : const Text('Đăng nhập'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Bottom nav
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _BottomNavItem(icon: Icons.fingerprint, label: 'eToken'),
                  _BottomNavItem(icon: Icons.qr_code_scanner, label: 'QR Scan'),
                  _BottomNavItem(icon: Icons.support_agent, label: 'Hỗ trợ'),
                  _BottomNavItem(icon: Icons.map, label: 'Mạng lưới'),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BottomNavItem({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _OtpSheet extends StatefulWidget {
  final LoginCubit cubit;
  const _OtpSheet({Key? key, required this.cubit}) : super(key: key);

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  final _controllers = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get code => _controllers.map((c) => c.text).join();

  void _onResend(OtpCubit cubit) {
    cubit.resend();
    for (var c in _controllers) {
      c.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpCubit = context.read<OtpCubit>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<OtpCubit, OtpState>(
        builder: (context, state) {
          final seconds = state.secondsRemaining;
          final canResend = seconds == 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Xác thực OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('OTP đã được gửi đến số điện thoại của Quý khách. Vui lòng nhập OTP vào ô dưới đây để xác thực.'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 44,
                    child: TextField(
                      controller: _controllers[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: const InputDecoration(counterText: ''),
                      onChanged: (v) {
                        if (v.isNotEmpty) {
                          if (i + 1 < _controllers.length) {
                            FocusScope.of(context).nextFocus();
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                        }
                        // auto submit when filled
                        if (_controllers.every((c) => c.text.isNotEmpty)) {
                          _submit(otpCubit);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: canResend ? () => _onResend(otpCubit) : null,
                    child: Text(canResend ? 'Gửi lại mã' : 'Gửi lại (${seconds}s)'),
                  ),
                  ElevatedButton(
                    onPressed: () => _submit(otpCubit),
                    child: const Text('Xác nhận'),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(OtpCubit otpCubit) async {
    final nav = Navigator.of(context);
    final ok = await otpCubit.verifyOtp(code);
    if (!mounted) return;
    if (ok) {
      nav.pop();
      nav.pushReplacementNamed('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã OTP không hợp lệ')));
    }
  }
}
