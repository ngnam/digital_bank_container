// lib/domain/entities/transfer_entity.dart
enum TransferType {
  internal,   // Nội bộ
  external,   // Liên ngân hàng
}

enum TransferStatus {
  pending,
  success,
  failed,
}

class TransferEntity {
  final String id; // transactionId
  final String sourceAccountId;
  final String targetAccount;
  final double amount;
  final String currency; // 'VND' or 'USD'
  final TransferType type;
  final String description;
  final TransferStatus status;
  final DateTime createdAt;

  const TransferEntity({
    required this.id,
    required this.sourceAccountId,
    required this.targetAccount,
    required this.amount,
    required this.currency,
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}
