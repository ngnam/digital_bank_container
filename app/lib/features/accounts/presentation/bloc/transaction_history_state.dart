part of 'transaction_history_cubit.dart';

abstract class TransactionHistoryState {}

class TransactionHistoryInitial extends TransactionHistoryState {}
class TransactionHistoryLoading extends TransactionHistoryState {}
class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<TransactionEntity> transactions;
  TransactionHistoryLoaded(this.transactions);
}
class TransactionHistoryError extends TransactionHistoryState {
  final String message;
  TransactionHistoryError(this.message);
}
