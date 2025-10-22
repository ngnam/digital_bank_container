import '../entities/transfer_entity.dart';

class TransferPayload {
  final String sourceAccountId;
  final String targetAccount;
  final double amount;
  final String currency;
  final TransferType type;
  final String description;
  final String idempotencyKey;

  TransferPayload({
    required this.sourceAccountId,
    required this.targetAccount,
    required this.amount,
    required this.currency,
    required this.type,
    required this.description,
    required this.idempotencyKey,
  });
}

abstract class TransferRepository {
  Future<TransferEntity> postTransfer(TransferPayload payload);
}
