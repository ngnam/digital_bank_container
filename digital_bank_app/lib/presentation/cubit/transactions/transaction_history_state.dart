import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';

abstract class TransactionHistoryState {
  const TransactionHistoryState();
}

class TransactionHistoryInitial extends TransactionHistoryState {
  const TransactionHistoryInitial();
}

class TransactionHistoryLoading extends TransactionHistoryState {
  final TransactionFilters filters;
  final List<String> accounts;
  const TransactionHistoryLoading(this.filters, this.accounts);
}

class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<TransactionEntity> transactions;
  final bool hasMore;
  final TransactionFilters filters;
  final int currentPage;
  final List<String> accounts;

  const TransactionHistoryLoaded({
    required this.transactions,
    required this.hasMore,
    required this.filters,
    required this.currentPage,
    required this.accounts,
  });
}

class TransactionHistoryError extends TransactionHistoryState {
  final String message;
  final TransactionFilters filters;
  final List<String> accounts;
  const TransactionHistoryError(this.message, this.filters, this.accounts);
}
