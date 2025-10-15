import '../models/account_model.dart';
import '../models/transaction_model.dart';

abstract class AccountLocalDataSource {
  Future<void> cacheAccounts(List<AccountModel> accounts);
  Future<List<AccountModel>> getCachedAccounts();

  Future<void> cacheAccountDetail(AccountModel account);
  Future<AccountModel?> getCachedAccountDetail(int id);

  Future<void> cacheTransactions(int accountId, List<TransactionModel> transactions);
  Future<List<TransactionModel>> getCachedTransactions(int accountId);
}
