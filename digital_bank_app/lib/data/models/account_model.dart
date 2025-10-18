import '../../domain/entities/account.dart';

class AccountModel extends Account {
  AccountModel({required String id, required String name, required String number, required double balance, String currency = 'VND'})
      : super(id: id, name: name, number: number, balance: balance, currency: currency);

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'VND',
    );
  }
}
