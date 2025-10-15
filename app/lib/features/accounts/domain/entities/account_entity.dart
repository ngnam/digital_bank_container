class AccountEntity {
  final int id;
  final String accountNumber;
  final String ownerName;
  final String currency;
  final double? balance;
  final DateTime? updatedAt;

  AccountEntity({
    required this.id,
    required this.accountNumber,
    required this.ownerName,
    required this.currency,
    this.balance,
    this.updatedAt,
  });
}
