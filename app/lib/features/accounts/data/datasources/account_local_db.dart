import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class AccountLocalDb {
  Future<List<AccountEntity>> getAccounts();
  Future<void> cacheAccounts(List<AccountEntity> accounts);
  Future<AccountEntity?> getAccountDetail(int id);
  Future<void> cacheAccountDetail(AccountEntity account);
  Future<List<TransactionEntity>> getTransactions(int accountId, {int page = 1, int pageSize = 20});
  Future<void> cacheTransactions(int accountId, List<TransactionEntity> transactions);
  Future<void> clearAll();
}
