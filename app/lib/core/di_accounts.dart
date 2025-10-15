import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import '../features/accounts/domain/repositories/account_repository.dart';
import '../features/accounts/data/repositories/account_repository_impl.dart';
import '../features/accounts/data/datasources/account_remote_datasource.dart';
import '../features/accounts/data/datasources/account_local_db.dart';
import '../features/accounts/data/datasources/account_local_db_impl.dart';
import '../features/accounts/data/cache/account_cache.dart';
import '../features/accounts/data/cache/account_cache_impl.dart';
import '../features/accounts/data/datasources/transaction_local_db.dart';
import '../features/accounts/data/datasources/transaction_local_db_impl.dart';

final getIt = GetIt.instance;

@module
abstract class AccountsModule {
  @lazySingleton
  AccountRepository provideAccountRepository(
    AccountRemoteDatasource remote,
    AccountLocalDb local,
    AccountCache cache,
  ) => AccountRepositoryImpl(remote, local, cache);

  @lazySingleton
  AccountRemoteDatasource provideAccountRemoteDatasource() => MockAccountRemoteDatasource();

  @lazySingleton
  AccountLocalDb provideAccountLocalDb() => AccountLocalDbImpl();

  @lazySingleton
  AccountCache provideAccountCache() => AccountCacheImpl();

  @lazySingleton
  TransactionLocalDb provideTransactionLocalDb() => TransactionLocalDbImpl();
}
