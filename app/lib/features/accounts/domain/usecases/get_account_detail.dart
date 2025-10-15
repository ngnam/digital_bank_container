import '../repositories/account_repository.dart';
import '../entities/account_entity.dart';

class GetAccountDetail {
  final AccountRepository repository;
  GetAccountDetail(this.repository);

  Future<AccountEntity> call(int id, {String? ifNoneMatch, String? ifModifiedSince}) {
    return repository.getAccountDetail(id, ifNoneMatch: ifNoneMatch, ifModifiedSince: ifModifiedSince);
  }
}
