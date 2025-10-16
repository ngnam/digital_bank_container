import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import '../features/accounts/domain/repositories/account_repository.dart';
import '../features/accounts/data/repositories/account_repository_impl.dart';
import '../features/accounts/data/datasources/account_local_datasource.dart';
import '../features/accounts/data/datasources/dummy_account_local_datasource.dart';
import '../features/accounts/data/cache/account_cache.dart';
import '../features/accounts/data/cache/account_cache_impl.dart';
import '../features/accounts/data/datasources/transaction_local_db.dart';
import '../features/accounts/data/datasources/transaction_local_db_impl.dart';
import '../features/accounts/data/datasources/account_remote_datasource.dart';

final getIt = GetIt.instance;

@module
abstract class AccountsModule {
  @lazySingleton
  AccountRepository provideAccountRepository(
    AccountRemoteDataSource remote,
    AccountLocalDataSource local,
    AccountCache cache,
  ) => AccountRepositoryImpl(remote: remote, local: local);

  @lazySingleton
  AccountRemoteDataSource provideAccountRemoteDatasource() => MockAccountRemoteDataSource();

  @lazySingleton
  AccountLocalDataSource provideAccountLocalDb() => DummyAccountLocalDataSource();

  @lazySingleton
  AccountCache provideAccountCache() => AccountCacheImpl();

  @lazySingleton
  TransactionLocalDb provideTransactionLocalDb() => TransactionLocalDbImpl();
}
