import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  AccountModel({
    required int id,
    required String accountNumber,
    required String ownerName,
    required String currency,
    double? balance,
    DateTime? updatedAt,
  }) : super(
          id: id,
          accountNumber: accountNumber,
          ownerName: ownerName,
          currency: currency,
          balance: balance,
          updatedAt: updatedAt,
        );

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
