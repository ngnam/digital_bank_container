import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_state.dart';
import '../../../domain/repositories/auth_repository.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository repository;
  Timer? _otpTimer;
  int _secondsRemaining = 0;

  LoginCubit(this.repository) : super(const LoginState());

  Future<void> login(String username, String password) async {
    emit(state.copyWith(status: LoginStatus.loading));
    final result = await repository.login(username, password);
    if (result) {
      emit(state.copyWith(status: LoginStatus.success));
      _startOtpCountdown(60);
    } else {
      emit(state.copyWith(status: LoginStatus.failure, message: 'Đăng nhập thất bại'));
    }
  }

  void _startOtpCountdown(int seconds) {
    _secondsRemaining = seconds;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        timer.cancel();
      }
      // notify UI via state changes if needed
      emit(state.copyWith());
    });
  }

  int get secondsRemaining => _secondsRemaining;

  Future<bool> verifyOtp(String code) async {
    // mock verify
    if (code == '123456') {
      emit(state.copyWith(status: LoginStatus.otpVerified));
      return true;
    }
    return false;
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}
