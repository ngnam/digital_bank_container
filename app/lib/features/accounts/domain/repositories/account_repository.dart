import '../entities/account_entity.dart';
import '../entities/transaction_entity.dart';

abstract class AccountRepository {
  Future<List<AccountEntity>> getAccounts({int page = 0, int size = 20, String? sort, String? ifNoneMatch});
  Future<AccountEntity> getAccountDetail(int id, {String? ifNoneMatch, String? ifModifiedSince});
  Future<List<TransactionEntity>> getTransactions(int accountId, {int page = 0, int size = 20, String? from, String? to, String? type, String? ifModifiedSince});
}
