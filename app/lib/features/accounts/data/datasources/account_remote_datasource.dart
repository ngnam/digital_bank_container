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
    // Mock nhiều tài khoản
    return [
      AccountModel(id: 1, accountNumber: '123456789', ownerName: 'Nguyen Van A', currency: 'VND', balance: 1000000),
      AccountModel(id: 2, accountNumber: '987654321', ownerName: 'Tran Thi B', currency: 'USD', balance: 5000),
      AccountModel(id: 3, accountNumber: '555666777', ownerName: 'Le Van C', currency: 'EUR', balance: 1200.5),
    ];
  }

  @override
  Future<AccountModel> getAccountDetail(int id, {String? ifNoneMatch, String? ifModifiedSince}) async {
    // Mock chi tiết theo id
    if (id == 1) {
      return AccountModel(id: 1, accountNumber: '123456789', ownerName: 'Nguyen Van A', currency: 'VND', balance: 1000000000, updatedAt: DateTime.now());
    } else if (id == 2) {
      return AccountModel(id: 2, accountNumber: '987654321', ownerName: 'Tran Thi B', currency: 'USD', balance: 50000, updatedAt: DateTime.now());
    } else {
      return AccountModel(id: 3, accountNumber: '555666777', ownerName: 'Le Van C', currency: 'EUR', balance: 12200.5, updatedAt: DateTime.now());
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(int accountId, {int page = 0, int size = 20, String? from, String? to, String? type, String? ifModifiedSince}) async {
    // Mock lịch sử giao dịch theo accountId
    if (accountId == 1) {
      return [
        TransactionModel(id: 101, type: 'DEBIT', amount: 50000, currency: 'VND', description: 'Transfer to B', timestamp: DateTime.now().subtract(const Duration(days: 1))),
        TransactionModel(id: 102, type: 'CREDIT', amount: 200000, currency: 'VND', description: 'Salary', timestamp: DateTime.now().subtract(const Duration(days: 2))),
      ];
    } else if (accountId == 2) {
      return [
        TransactionModel(id: 201, type: 'DEBIT', amount: 1000, currency: 'USD', description: 'Buy USD', timestamp: DateTime.now().subtract(const Duration(days: 3))),
        TransactionModel(id: 202, type: 'CREDIT', amount: 3000, currency: 'USD', description: 'Deposit', timestamp: DateTime.now().subtract(const Duration(days: 4))),
      ];
    } else {
      return [
        TransactionModel(id: 301, type: 'DEBIT', amount: 500, currency: 'EUR', description: 'Buy EUR', timestamp: DateTime.now().subtract(const Duration(days: 5))),
        TransactionModel(id: 302, type: 'CREDIT', amount: 700, currency: 'EUR', description: 'Deposit', timestamp: DateTime.now().subtract(const Duration(days: 6))),
      ];
    }
  }
}
