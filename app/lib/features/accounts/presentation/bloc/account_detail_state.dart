part of 'account_detail_cubit.dart';

abstract class AccountDetailState {}

class AccountDetailInitial extends AccountDetailState {}
class AccountDetailLoading extends AccountDetailState {}
class AccountDetailLoaded extends AccountDetailState {
  final AccountEntity account;
  AccountDetailLoaded(this.account);
}
class AccountDetailError extends AccountDetailState {
  final String message;
  AccountDetailError(this.message);
}
