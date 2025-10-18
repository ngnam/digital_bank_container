enum OtpStatus { initial, sending, sent, verifying, verified, failure }

class OtpState {
  final OtpStatus status;
  final int secondsRemaining;
  final String? message;

  const OtpState({this.status = OtpStatus.initial, this.secondsRemaining = 0, this.message});

  OtpState copyWith({OtpStatus? status, int? secondsRemaining, String? message}) {
    return OtpState(
      status: status ?? this.status,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      message: message ?? this.message,
    );
  }
}
