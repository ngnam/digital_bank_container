class TransactionEntity {
  final String id;
  final String accountId;
  final DateTime date;
  final double amount;
  final String description;

  TransactionEntity({required this.id, required this.accountId, required this.date, required this.amount, required this.description});
}
