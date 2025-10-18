import '../entities/account.dart';

abstract class AccountRepository {
  Future<Account> getAccount(String id);
}
