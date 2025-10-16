class TemplateModel {
  final int id;
  final String name;
  final String accountNumber;
  final String bankCode;

  TemplateModel({required this.id, required this.name, required this.accountNumber, required this.bankCode});

  factory TemplateModel.fromJson(Map<String, dynamic> j) => TemplateModel(
    id: j['id'] as int,
    name: j['name'] as String,
    accountNumber: j['accountNumber'] as String,
    bankCode: j['bankCode'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'accountNumber': accountNumber, 'bankCode': bankCode};
}
