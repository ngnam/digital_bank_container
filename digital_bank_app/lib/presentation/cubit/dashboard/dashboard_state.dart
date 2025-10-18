import '../../../domain/entities/account.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState {
  final DashboardStatus status;
  final List<Account> accounts;
  final String? message;

  const DashboardState({this.status = DashboardStatus.initial, this.accounts = const [], this.message});

  DashboardState copyWith({DashboardStatus? status, List<Account>? accounts, String? message}) {
    return DashboardState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      message: message ?? this.message,
    );
  }
}
