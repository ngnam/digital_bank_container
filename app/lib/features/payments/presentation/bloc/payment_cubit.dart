import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/payment_repository.dart';
import '../../domain/models/payment_request.dart';
import '../../domain/models/payment_response.dart';

abstract class PaymentState {}
class PaymentIdle extends PaymentState {}
class PaymentSubmitting extends PaymentState {}
class PaymentPending2FA extends PaymentState {
  final PaymentResponse response;
  PaymentPending2FA(this.response);
}
class PaymentSuccess extends PaymentState {
  final PaymentResponse response;
  PaymentSuccess(this.response);
}
class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repo;
  PaymentCubit(this.repo) : super(PaymentIdle());

  Future<void> submitInternal(PaymentRequest req) async {
    emit(PaymentSubmitting());
    try {
      final res = await repo.createInternal(req);
      if (res.status == 'PENDING_2FA') emit(PaymentPending2FA(res));
      else emit(PaymentSuccess(res));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> submitExternal(PaymentRequest req) async {
    emit(PaymentSubmitting());
    try {
      final res = await repo.createExternal(req);
      if (res.status == 'PENDING_2FA') emit(PaymentPending2FA(res));
      else emit(PaymentSuccess(res));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> confirm(String paymentId, String otp) async {
    emit(PaymentSubmitting());
    try {
      final res = await repo.confirm(paymentId, otp);
      emit(PaymentSuccess(res));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
