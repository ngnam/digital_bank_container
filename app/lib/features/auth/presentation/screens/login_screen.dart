import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        appBar: AppBar(title: const Text('Login')),
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  if (!isOtp)
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                  if (isOtp)
                    TextField(
                      onChanged: (v) => otp = v,
                      decoration: const InputDecoration(labelText: 'OTP'),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
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
                        child: Text(isOtp ? 'Login with OTP' : 'Login'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isOtp = !isOtp;
                          });
                        },
                        child: Text(isOtp ? 'Use Password' : 'Use OTP'),
                      ),
                    ],
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
