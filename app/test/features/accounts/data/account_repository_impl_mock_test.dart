import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:app/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:app/features/accounts/data/datasources/account_local_db.dart';
import 'package:app/features/accounts/data/cache/account_cache.dart';
import 'package:app/features/accounts/domain/entities/account_entity.dart';

class FakeRemote implements AccountRemoteDatasource {
  @override
  Future<List<AccountEntity>> fetchAccounts() async => [
    AccountEntity(id: 1, name: 'A', accountNumber: '001', balance: 1000, isOffline: false),
  ];
  @override
  Future<AccountEntity> fetchAccountDetail(int id) async => AccountEntity(id: id, name: 'A', accountNumber: '001', balance: 1000, isOffline: false);
}

class FakeLocal implements AccountLocalDb {
  List<AccountEntity> _accounts = [];
  @override
  Future<List<AccountEntity>> getAccounts() async => _accounts;
  @override
  Future<void> cacheAccounts(List<AccountEntity> accounts) async => _accounts = accounts;
  @override
  Future<AccountEntity?> getAccountDetail(int id) async => _accounts.firstWhere((e) => e.id == id, orElse: () => null);
  @override
  Future<void> cacheAccountDetail(AccountEntity account) async {}
  @override
  Future<void> clearAll() async {}
  @override
  Future<List> getTransactions(int accountId, {int page = 1, int pageSize = 20}) async => [];
  @override
  Future<void> cacheTransactions(int accountId, List transactions) async {}
}

class FakeCache implements AccountCache {
  @override
  List<AccountEntity>? accounts;
  @override
  final Map<int, AccountEntity> accountDetails = {};
  @override
  final Map<int, List> transactions = {};
  @override
  void cacheAccounts(List<AccountEntity> accounts) { this.accounts = accounts; }
  @override
  void cacheAccountDetail(AccountEntity account) { accountDetails[account.id] = account; }
  @override
  void cacheTransactions(int accountId, List txs) { transactions[accountId] = txs; }
  @override
  void clear() { accounts = null; accountDetails.clear(); transactions.clear(); }
}

void main() {
  test('AccountRepositoryImpl fetches from remote and caches', () async {
    final repo = AccountRepositoryImpl(FakeRemote(), FakeLocal(), FakeCache());
    final accounts = await repo.getAccounts();
    expect(accounts.length, 1);
    expect(accounts[0].name, 'A');
  });
}
