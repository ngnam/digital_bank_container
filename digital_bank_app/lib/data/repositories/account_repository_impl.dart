import '../../domain/entities/account.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/remote/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remote;

  AccountRepositoryImpl({AccountRemoteDataSource? remote})
      : remote = remote ?? AccountRemoteDataSource();

  @override
  Future<List<Account>> getAccounts() async {
    // For demo, try to fetch a single account and return a list, otherwise fallback to mock data
    try {
      final a = await remote.fetchAccount('1');
      return [a];
    } catch (_) {
      return [
        Account(
            id: '1',
            name: 'Tài khoản chính',
            number: '0123456789',
            balance: 12500000000,
            currency: 'VND'),
        Account(
            id: '2',
            name: 'Tiết kiệm',
            number: '0987654321',
            balance: 500000.0,
            currency: 'USD'),
      ];
    }
  }

  @override
  Future<double> getBalance(String accountId) async {
    try {
      final a = await remote.fetchAccount(accountId);
      return a.balance;
    } catch (_) {
      final list = await getAccounts();
      final a =
          list.firstWhere((e) => e.id == accountId, orElse: () => list.first);
      return a.balance;
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions(String accountId) async {
    try {
      // remote fetch not implemented; fallback
      throw Exception('remote not implemented');
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        TransactionEntity(
            id: 't1',
            accountId: accountId,
            date: DateTime.now().subtract(const Duration(days: 1)),
            amount: -150000.0,
            description: 'Thanh toán hóa đơn'),
        TransactionEntity(
            id: 't2',
            accountId: accountId,
            date: DateTime.now().subtract(const Duration(days: 3)),
            amount: 2000000.0,
            description: 'Chuyển tiền'),
      ];
    }
  }
}
