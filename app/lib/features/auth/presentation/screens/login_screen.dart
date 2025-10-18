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
  final _formKey = GlobalKey<FormState>();

  // Inline OTP state
  final TextEditingController _inlineOtpController = TextEditingController();
  Timer? _inlineOtpTimer;
  int _inlineOtpSeconds = 30;
  bool _inlineSubmitting = false;
  String? _inlineOtpError;
  // Inline individual digit controllers for the top OTP card
  final List<TextEditingController> _inlineDigitControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _inlineDigitNodes = List.generate(6, (_) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return ScreenProtector(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              // show inline error near OTP if OTP flow
              if (isOtp) {
                setState(() => _inlineOtpError = state.message);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
            } else if (state is AuthAuthenticated) {
              // Inline OTP success: close and navigate to root
              if (isOtp) {
                setState(() {
                  _inlineSubmitting = false;
                  _inlineOtpError = null;
                });
                final navigator = Navigator.of(context);
                Future.delayed(const Duration(milliseconds: 700), () {
                  if (!mounted) return;
                  setState(() => isOtp = false);
                  navigator.popUntil((route) => route.isFirst);
                });
              }
            } else if (state is AuthLoading) {
              if (isOtp) setState(() => _inlineSubmitting = true);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Inline OTP card shown at top when needed
                  if (isOtp) _buildInlineOtpCard(),
                  // Header
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Image.asset('assets/images/logo.png', width: 50, height: 50, errorBuilder: (c, e, s) => const Icon(Icons.account_balance, size: 96)),
                            const SizedBox(height: 12),
                            const Text('DigitalBank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                  // Main form centered vertically
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: phoneController,
                                  decoration: const InputDecoration(labelText: 'Tên tài khoản', hintText: 'Nhập tên tài khoản'),
                                  keyboardType: TextInputType.text,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên tài khoản' : null,
                                ),
                                const SizedBox(height: 12),
                                if (!isOtp)
                                  TextFormField(
                                    controller: passwordController,
                                    decoration: const InputDecoration(labelText: 'Mật khẩu', hintText: 'Nhập mật khẩu'),
                                    obscureText: true,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
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
                                        // when inline OTP is active, submission is via the top card
                                      } else {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          // show inline OTP form (simulate sending OTP)
                                          setState(() {
                                            isOtp = true;
                                            _inlineOtpError = null;
                                          });
                                          _startInlineOtpTimer();
                                          // In a real flow, call cubit's login to trigger OTP send
                                          try {
                                            // context.read<AuthCubit>().login(phoneController.text, passwordController.text);
                                          } catch (_) {}
                                        }
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
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
        // Move bottom menu to bottomNavigationBar so it's fixed at bottom
        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
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
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // auto-submit inline OTP when 6 digits entered
    _inlineOtpController.addListener(() {
      final txt = _inlineOtpController.text.trim();
      if (txt.length == 6 && !_inlineSubmitting) {
        // trigger submit
        setState(() {
          _inlineSubmitting = true;
          _inlineOtpError = null;
        });
        try {
          context.read<AuthCubit>().loginOtp(phoneController.text, txt);
        } catch (_) {
          setState(() => _inlineSubmitting = false);
        }
      }
    });
    // wire digit controllers to update the combined controller and handle focus
    for (var i = 0; i < 6; i++) {
      _inlineDigitControllers[i].addListener(() {
        final combined = _inlineDigitControllers.map((c) => c.text).join();
        _inlineOtpController.text = combined;
      });
    }
  }

  @override
  void dispose() {
    _inlineOtpTimer?.cancel();
    _inlineOtpController.dispose();
    for (final c in _inlineDigitControllers) c.dispose();
    for (final n in _inlineDigitNodes) n.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
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

  // Inline OTP helpers
  Widget _buildInlineOtpCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Xác thực OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(onPressed: () {
                    setState(() {
                      isOtp = false;
                      _inlineOtpController.clear();
                      _inlineOtpTimer?.cancel();
                    });
                  }, icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 6),
              Text('OTP đã được gửi tới: ${phoneController.text}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              // 6 individual digit inputs for better UX
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final hasError = _inlineOtpError != null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: SizedBox(
                      width: 42,
                      child: TextField(
                        controller: _inlineDigitControllers[i],
                        focusNode: _inlineDigitNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey.shade400)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: hasError ? Colors.red : Colors.blue)),
                        ),
                        onChanged: (v) {
                          // handle paste/multi-digit input
                          if (v.length > 1) {
                            final chars = v.split('');
                            for (var j = 0; j < chars.length && i + j < 6; j++) {
                              _inlineDigitControllers[i + j].text = chars[j];
                            }
                            // move focus
                            for (var j = i; j < 6; j++) {
                              if (_inlineDigitControllers[j].text.isEmpty) {
                                _inlineDigitNodes[j].requestFocus();
                                return;
                              }
                            }
                            // all filled -> combined controller listener will trigger submit
                            return;
                          }

                          if (v.isEmpty) {
                            if (i > 0) _inlineDigitNodes[i - 1].requestFocus();
                            return;
                          }
                          // move focus forward
                          if (i < 5) {
                            _inlineDigitNodes[i + 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_inlineOtpSeconds > 0 ? 'Gửi lại sau $_inlineOtpSeconds s' : 'Bạn có thể gửi lại mã'),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _inlineOtpSeconds > 0 || _inlineSubmitting ? null : () {
                          // resend logic (simulate)
                          _startInlineOtpTimer();
                        },
                        child: const Text('Gửi lại'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _inlineSubmitting ? null : () {
                          final code = _inlineOtpController.text.trim();
                          if (code.length != 6) {
                            setState(() => _inlineOtpError = 'Mã OTP phải có 6 chữ số');
                            return;
                          }
                          setState(() {
                            _inlineSubmitting = true;
                            _inlineOtpError = null;
                          });
                          try {
                            context.read<AuthCubit>().loginOtp(phoneController.text, code);
                          } catch (_) {
                            setState(() => _inlineSubmitting = false);
                          }
                        },
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startInlineOtpTimer() {
    _inlineOtpTimer?.cancel();
    setState(() => _inlineOtpSeconds = 30);
    _inlineOtpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        if (_inlineOtpSeconds > 0) _inlineOtpSeconds--;
        else t.cancel();
      });
    });
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
  bool _showSuccess = false;

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
    // handle paste of multiple digits
    if (v.length > 1) {
      final chars = v.split('');
      for (var i = 0; i < chars.length && index + i < 6; i++) {
        _controllers[index + i].text = chars[i];
      }
      // move focus to the next empty or last
      for (var i = index; i < 6; i++) {
        if (_controllers[i].text.isEmpty) {
          _nodes[i].requestFocus();
          return;
        }
      }
      // all filled -> submit
      final otp = _collectOtp();
      _submitOtp(otp);
      return;
    }

    // single char change
    if (v.isEmpty) {
      // user deleted -> move focus back
      if (index > 0) {
        _nodes[index - 1].requestFocus();
      }
      return;
    }

    // move focus forward
    if (index < 5) {
      _nodes[index + 1].requestFocus();
    } else {
      // last digit entered -> trigger OTP submission
      final otp = _collectOtp();
      _submitOtp(otp);
    }
  }

  void _submitOtp(String otp) {
    try {
      setState(() {
        _errorMessage = null;
        _infoMessage = null;
        _submitting = true;
      });
      context.read<AuthCubit>().loginOtp(widget.phone, otp);
    } catch (_) {}
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
            // OTP inputs or success animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showSuccess
                  ? Center(
                      key: const ValueKey('success'),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          AnimatedOpacity(
                            opacity: _showSuccess ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: AnimatedScale(
                              scale: _showSuccess ? 1 : 0.6,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(color: Colors.green.shade700, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: Colors.white, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    )
                  : Row(
                      key: const ValueKey('inputs'),
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (i) {
                        final hasError = _errorMessage != null;
                        return SizedBox(
                          width: 42,
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _nodes[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey.shade400)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: hasError ? Colors.red : Colors.blue)),
                            ),
                            onChanged: (v) => _onChanged(i, v),
                          ),
                        );
                      }),
                    ),
            ),
        const SizedBox(height: 12),
        BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              setState(() {
                _submitting = false;
                _errorMessage = null;
                _infoMessage = 'Xác thực thành công';
                _showSuccess = true;
              });
              // close sheet after a short delay; capture navigator to avoid using context across async gap
              final navigator = Navigator.of(context);
              Future.delayed(const Duration(milliseconds: 900), () {
                if (mounted) {
                  navigator.pop();
                  // after closing the sheet navigate to the authenticated home (pop to root and let AuthNav show accounts)
                  Future.microtask(() {
                    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
                  });
                }
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
