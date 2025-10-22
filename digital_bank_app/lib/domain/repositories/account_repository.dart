import '../entities/account.dart';
import '../entities/transaction_entity.dart';

abstract class AccountRepository {
  Future<List<Account>> getAccounts();
  Future<double> getBalance(String accountId);
  Future<List<TransactionEntity>> getTransactions(String accountId);
}

class MockAccountRepository implements AccountRepository {
  @override
  Future<List<Account>> getAccounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Account(id: '1', name: 'Tài khoản chính', number: '0123456789', balance: 12500000.5, currency: 'VND'),
      Account(id: '2', name: 'Tiết kiệm', number: '0987654321', balance: 5000.0, currency: 'USD'),
    ];
  }

  @override
  Future<double> getBalance(String accountId) async {
    final list = await getAccounts();
    final a = list.firstWhere((e) => e.id == accountId, orElse: () => list.first);
    return a.balance;
  }

  @override
  Future<List<TransactionEntity>> getTransactions(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      TransactionEntity(id: 't1', accountId: accountId, date: DateTime.now().subtract(const Duration(days: 1)), amount: -150000.0, description: 'Thanh toán hóa đơn'),
      TransactionEntity(id: 't2', accountId: accountId, date: DateTime.now().subtract(const Duration(days: 3)), amount: 2000000.0, description: 'Chuyển tiền'),
    ];
  }
}
