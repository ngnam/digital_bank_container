// lib/data/repositories/transfer_repository.dart
import 'dart:async';
import 'dart:math';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/transfer_repository.dart';

/// Mock Payment API
/// /api/v1/transfers/internal
/// /api/v1/transfers/external
/// Trả về JSON: {transactionId, status, amount, targetAccount, createdAt}
class TransferRepositoryImpl implements TransferRepository {
  // Lưu idempotencyKey -> transactionId để mô phỏng duplicate
  final Map<String, String> _idempotencyMemo = {};

  @override
  Future<TransferEntity> postTransfer(TransferPayload payload) async {
    // Thêm header Idempotency-Key: mô phỏng bằng map
    if (_idempotencyMemo.containsKey(payload.idempotencyKey)) {
      // duplicate
      throw TransferDuplicateException('Giao dịch đã được xử lý trước đó');
    }

    await Future.delayed(const Duration(milliseconds: 600)); // simulate latency

    // Mock một số lỗi ngẫu nhiên (ví dụ: số dư không đủ)
    if (payload.amount <= 0) {
      throw TransferApiException('Số tiền không hợp lệ');
    }
    // Mock rule: nếu amount > 10_000_000 VND thì coi là thiếu số dư
    if (payload.currency == 'VND' && payload.amount > 10000000) {
      throw TransferApiException('Số dư không đủ');
    }

    final transactionId = _randomId();
    _idempotencyMemo[payload.idempotencyKey] = transactionId;

    return TransferEntity(
      id: transactionId,
      sourceAccountId: payload.sourceAccountId,
      targetAccount: payload.targetAccount,
      amount: payload.amount,
      currency: payload.currency,
      type: payload.type,
      description: payload.description,
      status: TransferStatus.success,
      createdAt: DateTime.now(),
    );
  }

  String _randomId() {
    final rnd = Random();
    return 'TX-${DateTime.now().millisecondsSinceEpoch}-${rnd.nextInt(100000)}';
  }
}

class TransferApiException implements Exception {
  final String message;
  TransferApiException(this.message);
  @override
  String toString() => message;
}

class TransferDuplicateException implements Exception {
  final String message;
  TransferDuplicateException(this.message);
  @override
  String toString() => message;
}
