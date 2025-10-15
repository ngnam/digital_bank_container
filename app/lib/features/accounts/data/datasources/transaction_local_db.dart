import '../../domain/entities/transaction_entity.dart';

abstract class TransactionLocalDb {
  Future<List<TransactionEntity>> getTransactions(int accountId, {int page = 1, int pageSize = 20});
  Future<void> cacheTransactions(int accountId, List<TransactionEntity> transactions);
  Future<void> clearAll();
}
