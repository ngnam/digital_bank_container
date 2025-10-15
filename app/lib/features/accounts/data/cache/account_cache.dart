import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class AccountCache {
  List<AccountEntity>? get accounts;
  set accounts(List<AccountEntity>? value);

  Map<int, AccountEntity> get accountDetails;
  Map<int, List<TransactionEntity>> get transactions;

  void cacheAccounts(List<AccountEntity> accounts);
  void cacheAccountDetail(AccountEntity account);
  void cacheTransactions(int accountId, List<TransactionEntity> transactions);
  void clear();
}
