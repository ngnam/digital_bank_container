import '../repositories/account_repository.dart';
import '../entities/account_entity.dart';

class GetAccounts {
  final AccountRepository repository;
  GetAccounts(this.repository);

  Future<List<AccountEntity>> call({int page = 0, int size = 20, String? sort, String? ifNoneMatch}) {
    return repository.getAccounts(page: page, size: size, sort: sort, ifNoneMatch: ifNoneMatch);
  }
}
