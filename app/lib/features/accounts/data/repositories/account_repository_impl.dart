import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';
import '../datasources/account_local_datasource.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remote;
  final AccountLocalDataSource local;
  AccountRepositoryImpl({required this.remote, required this.local});

  @override
  Future<List<AccountEntity>> getAccounts({int page = 0, int size = 20, String? sort, String? ifNoneMatch}) async {
    try {
      final accounts = await remote.getAccounts(page: page, size: size, sort: sort, ifNoneMatch: ifNoneMatch);
      await local.cacheAccounts(accounts);
      return accounts;
    } catch (_) {
      return local.getCachedAccounts();
    }
  }

  @override
  Future<AccountEntity> getAccountDetail(int id, {String? ifNoneMatch, String? ifModifiedSince}) async {
    try {
      final account = await remote.getAccountDetail(id, ifNoneMatch: ifNoneMatch, ifModifiedSince: ifModifiedSince);
      await local.cacheAccountDetail(account);
      return account;
    } catch (_) {
      return (await local.getCachedAccountDetail(id))!;
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions(int accountId, {int page = 0, int size = 20, String? from, String? to, String? type, String? ifModifiedSince}) async {
    try {
      final txs = await remote.getTransactions(accountId, page: page, size: size, from: from, to: to, type: type, ifModifiedSince: ifModifiedSince);
      await local.cacheTransactions(accountId, txs);
      return txs;
    } catch (_) {
      return local.getCachedTransactions(accountId);
    }
  }
}
