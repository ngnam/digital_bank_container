import 'package:digital_bank_app/domain/repositories/auth_repository.dart';
import 'package:digital_bank_app/presentation/cubit/auth/login_cubit.dart';
import 'package:digital_bank_app/presentation/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di.dart' as di;
import 'core/constants.dart';
import 'core/theme.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // set a default flavor for non-flavored entrypoints
  currentFlavor = Flavor.dev;
  await di.init();
  final repo = di.sl<AuthRepository>();

  // Surface uncaught Flutter errors on-screen (useful during debug / QA builds)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // show exception text so the user/dev sees it instead of a black screen
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Startup error')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(child: Text(details.exceptionAsString())),
        ),
      ),
    );
  };

  // Also catch any uncaught zone errors and print them (can be expanded to show UI)
  runZonedGuarded(() {
    runApp(
      BlocProvider(
        create: (_) => LoginCubit(repo),
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    // Print to console / logs so we can inspect on CI or via adb logcat
    // ignore: avoid_print
    print('Uncaught zone error: $error');
    // You could also push a UI notification here via a navigator key if desired
  });
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
