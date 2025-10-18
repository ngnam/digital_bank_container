import '../../domain/entities/account.dart';

class AccountModel extends Account {
  AccountModel({required super.id, required super.name, required super.balance});

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
