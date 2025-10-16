import '../models/account_model.dart';
import '../models/transaction_model.dart';
import 'account_local_datasource.dart';

class DummyAccountLocalDataSource implements AccountLocalDataSource {
  @override
  Future<void> cacheAccounts(List<AccountModel> accounts) async {}

  @override
  Future<List<AccountModel>> getCachedAccounts() async => [];

  @override
  Future<void> cacheAccountDetail(AccountModel account) async {}

  @override
  Future<AccountModel?> getCachedAccountDetail(int id) async => null;

  @override
  Future<void> cacheTransactions(int accountId, List<TransactionModel> transactions) async {}

  @override
  Future<List<TransactionModel>> getCachedTransactions(int accountId) async => [];
}
