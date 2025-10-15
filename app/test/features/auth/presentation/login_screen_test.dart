import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/auth/presentation/bloc/auth_cubit.dart';

class FakeAuthCubit extends AuthCubit {
  FakeAuthCubit() : super(
    loginWithPassword: (_, __) async => throw UnimplementedError(),
    loginWithOtp: (_, __) async => throw UnimplementedError(),
    enableBiometric: () async => throw UnimplementedError(),
    disableBiometric: () async => throw UnimplementedError(),
    getTrustedDevices: () async => throw UnimplementedError(),
    registerDevice: (_) async => throw UnimplementedError(),
    removeDevice: (_) async => throw UnimplementedError(),
  );
}

void main() {
  testWidgets('renders login form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>(
          create: (_) => FakeAuthCubit(),
          child: const LoginScreen(),
        ),
      ),
    );
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}
