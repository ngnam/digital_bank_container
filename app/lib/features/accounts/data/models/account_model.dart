import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  AccountModel({
    required super.id,
    required super.accountNumber,
    required super.ownerName,
    required super.currency,
    super.balance,
    super.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        id: json['id'],
        accountNumber: json['accountNumber'],
        ownerName: json['ownerName'],
        currency: json['currency'],
        balance: (json['balance'] as num?)?.toDouble(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountNumber': accountNumber,
        'ownerName': ownerName,
        'currency': currency,
        'balance': balance,
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
