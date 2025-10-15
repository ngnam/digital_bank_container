import '../models/account_model.dart';
import '../models/transaction_model.dart';

abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> getAccounts({int page = 0, int size = 20, String? sort, String? ifNoneMatch});
  Future<AccountModel> getAccountDetail(int id, {String? ifNoneMatch, String? ifModifiedSince});
  Future<List<TransactionModel>> getTransactions(int accountId, {int page = 0, int size = 20, String? from, String? to, String? type, String? ifModifiedSince});
}

class MockAccountRemoteDataSource implements AccountRemoteDataSource {
  @override
  Future<List<AccountModel>> getAccounts({int page = 0, int size = 20, String? sort, String? ifNoneMatch}) async {
    // Mock data
    return [
      AccountModel(id: 1, accountNumber: '123456789', ownerName: 'Nguyen Van A', currency: 'VND', balance: 1000000),
    ];
  }

  @override
  Future<AccountModel> getAccountDetail(int id, {String? ifNoneMatch, String? ifModifiedSince}) async {
    return AccountModel(id: id, accountNumber: '123456789', ownerName: 'Nguyen Van A', currency: 'VND', balance: 1000000, updatedAt: DateTime.now());
  }

  @override
  Future<List<TransactionModel>> getTransactions(int accountId, {int page = 0, int size = 20, String? from, String? to, String? type, String? ifModifiedSince}) async {
    return [
      TransactionModel(id: 101, type: 'DEBIT', amount: 50000, description: 'Transfer to B', timestamp: DateTime.now().subtract(const Duration(days: 1))),
    ];
  }
}
