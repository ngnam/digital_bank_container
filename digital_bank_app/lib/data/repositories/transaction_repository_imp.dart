// lib/data/repositories/transaction_repository.dart
import 'dart:math';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final List<TransactionEntity> _store = _generateMock();
  final List<String> _accounts = const ['ACC-001', 'ACC-002', 'ACC-003'];

  static List<TransactionEntity> _generateMock() {
    final rnd = Random(2025);
    final accounts = ['ACC-001', 'ACC-002', 'ACC-003'];
    final types = [
      TransactionType.deposit,
      TransactionType.withdrawal,
      TransactionType.transfer,
      TransactionType.payment,
    ];
    final statuses = [
      TransactionStatus.pending,
      TransactionStatus.success,
      TransactionStatus.failed,
    ];

    final List<TransactionEntity> data = [];
    for (int i = 0; i < 30; i++) {
      final accountId = accounts[rnd.nextInt(accounts.length)];
      final type = types[rnd.nextInt(types.length)];
      final status = statuses[rnd.nextInt(statuses.length)];
      final baseAmount = (rnd.nextDouble() * 5000000 + 20000).roundToDouble();
      final sign = (type == TransactionType.deposit) ? 1.0 : -1.0;
      final amount = baseAmount * sign;
      final date = DateTime.now().subtract(Duration(
        days: rnd.nextInt(25),
        hours: rnd.nextInt(23),
        minutes: rnd.nextInt(59),
      ));
      final description = switch (type) {
        TransactionType.deposit => 'Nạp tiền vào tài khoản',
        TransactionType.withdrawal => 'Rút tiền khỏi tài khoản',
        TransactionType.transfer => 'Chuyển tiền tới người nhận',
        TransactionType.payment => 'Thanh toán hóa đơn dịch vụ',
        _ => 'Giao dịch'
      };

      data.add(TransactionEntity(
        id: '${i + 1}',
        accountId: accountId,
        date: date,
        amount: amount,
        description: description,
        type: type,
        status: status,
        currency: 'VND',
      ));
    }

    // mới nhất lên đầu
    data.sort((a, b) => b.date.compareTo(a.date));
    return data;
  }

  @override
  Future<List<TransactionEntity>> fetchTransactions({
    required int page,
    required int pageSize,
    required TransactionFilters filters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400)); // simulate latency

    Iterable<TransactionEntity> result = _store;

    if (filters.accountId != null && filters.accountId!.isNotEmpty) {
      result = result.where((t) => t.accountId == filters.accountId);
    }
    if (filters.type != TransactionType.all) {
      result = result.where((t) => t.type == filters.type);
    }
    if (filters.from != null) {
      result = result.where((t) => !t.date.isBefore(filters.from!));
    }
    if (filters.to != null) {
      result = result.where((t) => !t.date.isAfter(filters.to!));
    }

    final list = result.toList()..sort((a, b) => b.date.compareTo(a.date));

    // pagination
    final start = (page - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  @override
  Future<List<String>> fetchAccounts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _accounts;
  }
}
