import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  Timer? _timer;

  OtpCubit() : super(const OtpState());

  void sendOtp({int seconds = 60}) {
    emit(state.copyWith(status: OtpStatus.sent, secondsRemaining: seconds));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = state.secondsRemaining - 1;
      if (next <= 0) {
        t.cancel();
        emit(state.copyWith(secondsRemaining: 0));
      } else {
        emit(state.copyWith(secondsRemaining: next));
      }
    });
  }

  Future<bool> verifyOtp(String code) async {
    emit(state.copyWith(status: OtpStatus.verifying));
    await Future.delayed(const Duration(milliseconds: 300));
    if (code == '123456') {
      emit(state.copyWith(status: OtpStatus.verified));
      return true;
    }
    emit(state.copyWith(status: OtpStatus.failure, message: 'OTP không đúng'));
    return false;
  }

  void resend() {
    sendOtp();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
