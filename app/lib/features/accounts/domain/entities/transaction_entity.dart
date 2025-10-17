class TransactionEntity {
  final int id;
  final String type;
  final double amount;
  final String description;
  final DateTime timestamp;
  final String? currency;

  TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.currency,
  });
}
