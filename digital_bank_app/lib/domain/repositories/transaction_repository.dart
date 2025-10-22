import '../entities/transaction_entity.dart';

class TransactionFilters {
  final String? accountId;
  final TransactionType type;
  final DateTime? from;
  final DateTime? to;

  const TransactionFilters({
    this.accountId,
    this.type = TransactionType.all,
    this.from,
    this.to,
  });

  TransactionFilters copyWith({
    String? accountId,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) {
    return TransactionFilters(
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      from: from,
      to: to,
    );
  }
}

abstract class TransactionRepository {
  Future<List<TransactionEntity>> fetchTransactions({
    required int page,
    required int pageSize,
    required TransactionFilters filters,
  });
  Future<List<String>> fetchAccounts(); // mock danh sách accountId để chọn
}
