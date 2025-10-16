import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'features/auth/presentation/services/session_lock_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/lock_screen.dart';
import 'features/auth/domain/usecases/login_with_password.dart';
import 'features/auth/domain/usecases/login_with_otp.dart';
import 'features/auth/domain/usecases/enable_biometric.dart';
import 'features/auth/domain/usecases/disable_biometric.dart';
import 'features/auth/domain/usecases/get_trusted_devices.dart';
import 'features/auth/domain/usecases/register_device.dart';
import 'features/auth/domain/usecases/remove_device.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/accounts/presentation/screens/accounts_nav.dart';
import 'features/payments/data/payment_local_db_impl.dart';
import 'features/payments/data/payment_repository.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo các dependency đơn giản (có thể chuyển sang get_it nếu muốn DI chuẩn)
    final local = AuthLocalDataSourceImpl(const FlutterSecureStorage());
    final remote = MockAuthRemoteDataSource();
    final repo = AuthRepositoryImpl(local: local, remote: remote);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            loginWithPassword: LoginWithPassword(repo),
            loginWithOtp: LoginWithOtp(repo),
            enableBiometric: EnableBiometric(repo),
            disableBiometric: DisableBiometric(repo),
            getTrustedDevices: GetTrustedDevices(repo),
            registerDevice: RegisterDevice(repo),
            removeDevice: RemoveDevice(repo),
              remote: remote,
          ),
        ),
      ],
        child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthNav(),
      ),
    );
  }
}

class AuthNav extends StatefulWidget {
  const AuthNav({super.key});

  @override
  State<AuthNav> createState() => _AuthNavState();
}

class _AuthNavState extends State<AuthNav> {
  UserEntity? _user;
  bool _locked = false;
  late final SessionLockService _lockService;
  late final PaymentLocalDbImpl _sharedPaymentDb;
  late final MockPaymentRepository _sharedPaymentRepo;

  @override
  void initState() {
    super.initState();
    _lockService = SessionLockService(timeout: const Duration(seconds: 30))
      ..onLock = () {
        context.read<AuthCubit>().lockSession();
      };
    _lockService.start();
    // shared payments instances
    _sharedPaymentDb = PaymentLocalDbImpl();
    _sharedPaymentRepo = MockPaymentRepository(Dio(), localDb: _sharedPaymentDb);
  }

  void _resetLockTimer() {
    _lockService.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthUnlocked) {
          setState(() {
            _user = state is AuthAuthenticated ? state.user : (state as AuthUnlocked).user;
            _locked = false;
          });
          _resetLockTimer();
        } else if (state is AuthLocked) {
          setState(() => _locked = true);
        } else if (state is AuthInitial) {
          setState(() {
            _user = null;
            _locked = false;
          });
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _resetLockTimer,
        onPanDown: (_) => _resetLockTimer(),
        child: _locked
            ? LockScreen(
                onUnlock: () => context.read<AuthCubit>().unlockWithBiometric(),
              )
            : (_user != null
                ? AccountsNav(paymentRepository: _sharedPaymentRepo)
                : const LoginScreen()),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kien Long Bank')),
      body: const Center(child: Text('Welcome to Kien Long Bank!')),
    );
  }
}


