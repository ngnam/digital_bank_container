class Account {
  final String id;
  final String name;
  final String number;
  final double balance;
  final String currency; // 'VND' or 'USD'

  Account({required this.id, required this.name, required this.number, required this.balance, this.currency = 'VND'});
}
