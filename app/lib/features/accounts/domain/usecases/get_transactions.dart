import '../repositories/account_repository.dart';
import '../entities/transaction_entity.dart';

class GetTransactions {
  final AccountRepository repository;
  GetTransactions(this.repository);

  Future<List<TransactionEntity>> call(int accountId, {int page = 0, int size = 20, String? from, String? to, String? type, String? ifModifiedSince}) {
    return repository.getTransactions(accountId, page: page, size: size, from: from, to: to, type: type, ifModifiedSince: ifModifiedSince);
  }
}
