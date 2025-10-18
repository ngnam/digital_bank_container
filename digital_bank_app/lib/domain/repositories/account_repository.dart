import '../entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAccounts();
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
}
