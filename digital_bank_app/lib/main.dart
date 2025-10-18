import 'package:digital_bank_app/domain/repositories/auth_repository.dart';
import 'package:digital_bank_app/presentation/cubit/auth/login_cubit.dart';
import 'package:digital_bank_app/presentation/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di.dart' as di;
import 'core/theme.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  final repo = MockAuthRepository();
  runApp(
  BlocProvider(
    create: (_) => LoginCubit(repo),
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Digital Bank',
        theme: lightTheme,
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginPage(),
          '/dashboard': (_) => const DashboardPage(),
        });
  }
}
