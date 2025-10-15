import 'account_cache.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';

class AccountCacheImpl implements AccountCache {
  @override
  List<AccountEntity>? accounts;

  @override
  final Map<int, AccountEntity> accountDetails = {};

  @override
  final Map<int, List<TransactionEntity>> transactions = {};

  @override
  void cacheAccounts(List<AccountEntity> accounts) {
    this.accounts = accounts;
    for (final acc in accounts) {
      accountDetails[acc.id] = acc;
    }
  }

  @override
  void cacheAccountDetail(AccountEntity account) {
    accountDetails[account.id] = account;
  }

  @override
  void cacheTransactions(int accountId, List<TransactionEntity> txs) {
    transactions[accountId] = txs;
  }

  @override
  void clear() {
    accounts = null;
    accountDetails.clear();
    transactions.clear();
  }
}
