class ScheduleModel {
  final int id;
  final String name;
  final String cron; // simplified recurrence expression
  final int fromAccountId;
  final double amount;

  ScheduleModel({required this.id, required this.name, required this.cron, required this.fromAccountId, required this.amount});

  factory ScheduleModel.fromJson(Map<String, dynamic> j) => ScheduleModel(
    id: j['id'] as int,
    name: j['name'] as String,
    cron: j['cron'] as String,
    fromAccountId: j['fromAccountId'] as int,
    amount: (j['amount'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'cron': cron, 'fromAccountId': fromAccountId, 'amount': amount};
}
