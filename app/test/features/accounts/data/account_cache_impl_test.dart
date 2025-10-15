import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/accounts/data/cache/account_cache_impl.dart';
import 'package:app/features/accounts/domain/entities/account_entity.dart';

void main() {
  group('AccountCacheImpl', () {
    late AccountCacheImpl cache;
    setUp(() {
      cache = AccountCacheImpl();
      cache.clear();
    });

    test('cache and get accounts', () {
      final accounts = [
        AccountEntity(id: 1, name: 'A', accountNumber: '001', balance: 1000, isOffline: false),
        AccountEntity(id: 2, name: 'B', accountNumber: '002', balance: 2000, isOffline: true),
      ];
      cache.cacheAccounts(accounts);
      expect(cache.accounts?.length, 2);
      expect(cache.accountDetails[1]?.name, 'A');
    });
  });
}
