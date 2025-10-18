import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/remote/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remote;

  AccountRepositoryImpl({AccountRemoteDataSource? remote}) : remote = remote ?? AccountRemoteDataSource();

  @override
  Future<Account> getAccount(String id) async {
    return remote.fetchAccount(id);
  }
}
