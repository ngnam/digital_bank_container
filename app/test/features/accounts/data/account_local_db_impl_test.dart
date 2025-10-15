import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/accounts/data/datasources/account_local_db_impl.dart';
import 'package:app/features/accounts/domain/entities/account_entity.dart';

void main() {
  group('AccountLocalDbImpl', () {
    late AccountLocalDbImpl db;

    setUp(() async {
      db = AccountLocalDbImpl();
      await db.clearAll();
    });

    test('cache and get accounts', () async {
      final accounts = [
        AccountEntity(id: 1, name: 'A', accountNumber: '001', balance: 1000, isOffline: false),
        AccountEntity(id: 2, name: 'B', accountNumber: '002', balance: 2000, isOffline: true),
      ];
      await db.cacheAccounts(accounts);
      final result = await db.getAccounts();
      expect(result.length, 2);
      expect(result[0].name, 'A');
      expect(result[1].isOffline, true);
    });
  });
}
