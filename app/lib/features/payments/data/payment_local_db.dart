import '../domain/models/template.dart';
import '../domain/models/schedule.dart';

abstract class PaymentLocalDb {
  Future<void> init();
  Future<List<TemplateModel>> getTemplates();
  Future<void> saveTemplate(TemplateModel t);
  Future<List<ScheduleModel>> getSchedules();
  Future<void> saveSchedule(ScheduleModel s);
  // pending payments queue for offline retry
  Future<void> addPendingPayment(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getPendingPayments();
  Future<void> removePendingPayment(int id);
  Future<void> incrementPendingAttempts(int id);
}
