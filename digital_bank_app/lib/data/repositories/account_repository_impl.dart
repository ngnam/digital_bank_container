import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/remote/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remote;

  AccountRepositoryImpl({AccountRemoteDataSource? remote}) : remote = remote ?? AccountRemoteDataSource();

  @override
  Future<List<Account>> getAccounts() async {
    // For demo, try to fetch a single account and return a list, otherwise fallback to mock data
    try {
      final a = await remote.fetchAccount('1');
      return [a];
    } catch (_) {
      return [
        Account(id: '1', name: 'Tài khoản chính', number: '0123456789', balance: 12500000.5, currency: 'VND'),
        Account(id: '2', name: 'Tiết kiệm', number: '0987654321', balance: 5000.0, currency: 'USD'),
      ];
    }
  }
}
