part of 'account_list_cubit.dart';

abstract class AccountListState {}

class AccountListInitial extends AccountListState {}
class AccountListLoading extends AccountListState {}
class AccountListLoaded extends AccountListState {
  final List<AccountEntity> accounts;
  AccountListLoaded(this.accounts);
}
class AccountListError extends AccountListState {
  final String message;
  AccountListError(this.message);
}
