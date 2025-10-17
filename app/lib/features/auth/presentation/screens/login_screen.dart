import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/screen_protector.dart';
import '../bloc/auth_cubit.dart';
import 'dart:async';

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
                            const Text('DigitalBank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                    // Start login flow and show OTP bottom sheet
                                    context.read<AuthCubit>().login(
                                          phoneController.text,
                                          passwordController.text,
                                        );
                                    // open OTP bottom sheet
                                    _showOtpBottomSheet(context, phoneController.text);
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

  void _showOtpBottomSheet(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.44,
        minChildSize: 0.28,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: OtpBottomSheet(phone: phone),
        ),
      ),
    );
  }
}

class OtpBottomSheet extends StatefulWidget {
  final String phone;
  const OtpBottomSheet({required this.phone, super.key});

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 30;
  String? _errorMessage;
  String? _infoMessage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // auto focus first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        if (_seconds > 0) _seconds--;
        else t.cancel();
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _collectOtp() => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String v) {
    if (v.isEmpty) return;
    // move focus
    if (index < 5) {
      _nodes[index + 1].requestFocus();
    } else {
      // last digit entered -> trigger OTP submission
      final otp = _collectOtp();
      // call cubit to confirm
      try {
        setState(() {
          _errorMessage = null;
          _infoMessage = null;
          _submitting = true;
        });
        context.read<AuthCubit>().loginOtp(widget.phone, otp);
        // keep sheet open; we'll update UI from bloc events
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Xác thực OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
          ],
        ),
        const SizedBox(height: 8),
        Text('OTP đã được gửi đến số điện thoại của Quý khách. Vui lòng nhập OTP vào ô dưới đây để xác thực.'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (i) => SizedBox(
            width: 42,
            child: TextField(
              controller: _controllers[i],
              focusNode: _nodes[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              decoration: const InputDecoration(counterText: ''),
              onChanged: (v) => _onChanged(i, v),
            ),
          )),
        ),
        const SizedBox(height: 12),
        BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              setState(() {
                _submitting = false;
                _errorMessage = null;
                _infoMessage = 'Xác thực thành công';
              });
            } else if (state is AuthError) {
              setState(() {
                _errorMessage = state.message;
                _submitting = false;
              });
            } else if (state is AuthLoading) {
              setState(() {
                _submitting = true;
                _errorMessage = null;
              });
            } else {
              setState(() {
                _submitting = false;
              });
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                if (_infoMessage != null) ...[
                  Text(_infoMessage!, style: TextStyle(color: Colors.green.shade700)),
                  const SizedBox(height: 8),
                ],
                Center(child: Text(_seconds > 0 ? 'Gửi lại mã sau $_seconds s' : 'Gửi lại mã')),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _seconds > 0 || _submitting
                          ? null
                          : () async {
                              // call mock resend API via cubit's remote
                              try {
                                await (context.read<AuthCubit>().remote).resendOtp(widget.phone);
                                _startTimer();
                                setState(() {
                                  _infoMessage = 'Mã đã được gửi lại';
                                  _errorMessage = null;
                                });
                              } catch (e) {
                                setState(() {
                                  _errorMessage = 'Gửi lại thất bại: $e';
                                });
                              }
                            },
                      child: _submitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Gửi lại mã'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
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
        CircleAvatar(radius: 18, backgroundColor: Colors.blue.shade700, child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
