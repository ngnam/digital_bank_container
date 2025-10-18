enum LoginStatus { initial, loading, success, otpVerified, failure }

class LoginState {
  final LoginStatus status;
  final String? message;

  const LoginState({this.status = LoginStatus.initial, this.message});

  LoginState copyWith({LoginStatus? status, String? message}) {
    return LoginState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  String toString() => 'LoginState(status: $status, message: $message)';
}
