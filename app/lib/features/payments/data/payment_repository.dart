import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/models/payment_request.dart';
import '../domain/models/payment_response.dart';
import '../domain/models/template.dart';
import '../domain/models/schedule.dart';
import 'payment_local_db.dart';

abstract class PaymentRepository {
  Future<PaymentResponse> createInternal(PaymentRequest req);
  Future<PaymentResponse> createExternal(PaymentRequest req);
  Future<PaymentResponse> confirm(String paymentId, String otp);

  // Debug / admin helpers (optional)
  Future<List<Map<String, dynamic>>> getPendingRaw();
  Future<void> removePendingById(int id);
  Future<void> retryPendingById(int id);

  Future<List<TemplateModel>> getTemplates();
  Future<void> saveTemplate(TemplateModel t);
  Future<List<ScheduleModel>> getSchedules();
  Future<void> saveSchedule(ScheduleModel s);
}

class MockPaymentRepository implements PaymentRepository {
  final Dio dio;
  final List<TemplateModel> _templates = [];
  final List<ScheduleModel> _schedules = [];
  final PaymentLocalDb? localDb;

  MockPaymentRepository(this.dio, {this.localDb}) {
    _initLocal();
    _initConnectivity();
  }

  Future<void> _initLocal() async {
    if (localDb != null) {
      await localDb!.init();
      final t = await localDb!.getTemplates();
      final s = await localDb!.getSchedules();
      _templates.addAll(t);
      _schedules.addAll(s);
    }
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _retryPending();
      }
    });
  }

  @override
  Future<PaymentResponse> createInternal(PaymentRequest req) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // Simulate pending 2FA
      final resp = PaymentResponse(id: DateTime.now().millisecondsSinceEpoch.toString(), status: 'PENDING_2FA');
      // persist request for retry if localDb available
      if (localDb != null) {
        await localDb!.addPendingPayment({'type': 'internal', 'request': req.toJsonInternal(), 'paymentId': resp.id});
      }
      return resp;
    } catch (e) {
      if (localDb != null) {
        await localDb!.addPendingPayment({'type': 'internal', 'request': req.toJsonInternal()});
      }
      rethrow;
    }
  }

  @override
  Future<PaymentResponse> createExternal(PaymentRequest req) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final resp = PaymentResponse(id: DateTime.now().millisecondsSinceEpoch.toString(), status: 'PENDING_2FA');
      if (localDb != null) {
        await localDb!.addPendingPayment({'type': 'external', 'request': req.toJsonExternal(), 'paymentId': resp.id});
      }
      return resp;
    } catch (e) {
      if (localDb != null) {
        await localDb!.addPendingPayment({'type': 'external', 'request': req.toJsonExternal()});
      }
      rethrow;
    }
  }

  Future<void> _retryPending() async {
    if (localDb == null) return;
    try {
      final rows = await localDb!.getPendingPayments();
      for (final r in rows) {
        final id = r['id'] as int;
        final payloadStr = r['payload'] as String;
        final payload = jsonDecode(payloadStr) as Map<String, dynamic>;
        try {
          if (payload['type'] == 'internal') {
            final reqJson = payload['request'] as Map<String, dynamic>;
            // Reconstruct minimal PaymentRequest
            final req = PaymentRequest(
              fromAccountId: reqJson['fromAccountId'] as int,
              toAccountId: reqJson['toAccountId'] as int?,
              amount: (reqJson['amount'] as num).toDouble(),
              description: reqJson['description'] as String?,
            );
            await createInternal(req);
          } else if (payload['type'] == 'external') {
            final reqJson = payload['request'] as Map<String, dynamic>;
            final req = PaymentRequest(
              fromAccountId: reqJson['fromAccountId'] as int,
              toBankCode: reqJson['toBankCode'] as String?,
              toAccountNumber: reqJson['toAccountNumber'] as String?,
              toName: reqJson['toName'] as String?,
              amount: (reqJson['amount'] as num).toDouble(),
              description: reqJson['description'] as String?,
            );
            await createExternal(req);
          }
          // On success remove pending entry
          await localDb!.removePendingPayment(id);
        } catch (e) {
          // ignore individual failures; keep in queue for later
        }
      }
    } catch (_) {}
  }

  // Debug helpers
  @override
  Future<List<Map<String, dynamic>>> getPendingRaw() async {
    if (localDb == null) return [];
    return await localDb!.getPendingPayments();
  }

  @override
  Future<void> removePendingById(int id) async {
    if (localDb == null) return;
    await localDb!.removePendingPayment(id);
  }

  @override
  Future<void> retryPendingById(int id) async {
    if (localDb == null) return;
    final rows = await localDb!.getPendingPayments();
    final row = rows.firstWhere((r) => (r['id'] as int) == id, orElse: () => {});
    if (row.isEmpty) return;
    // increment attempts counter before retrying to reflect user action
    await localDb!.incrementPendingAttempts(id);
    final payloadStr = row['payload'] as String;
    final payload = jsonDecode(payloadStr) as Map<String, dynamic>;
    try {
      if (payload['type'] == 'internal') {
        final reqJson = payload['request'] as Map<String, dynamic>;
        final req = PaymentRequest(
          fromAccountId: reqJson['fromAccountId'] as int,
          toAccountId: reqJson['toAccountId'] as int?,
          amount: (reqJson['amount'] as num).toDouble(),
          description: reqJson['description'] as String?,
        );
        await createInternal(req);
      } else if (payload['type'] == 'external') {
        final reqJson = payload['request'] as Map<String, dynamic>;
        final req = PaymentRequest(
          fromAccountId: reqJson['fromAccountId'] as int,
          toBankCode: reqJson['toBankCode'] as String?,
          toAccountNumber: reqJson['toAccountNumber'] as String?,
          toName: reqJson['toName'] as String?,
          amount: (reqJson['amount'] as num).toDouble(),
          description: reqJson['description'] as String?,
        );
        await createExternal(req);
      }
      await localDb!.removePendingPayment(id);
    } catch (e) {
      // leave in queue on failure
      rethrow;
    }
  }

  @override
  Future<PaymentResponse> confirm(String paymentId, String otp) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (otp == '0000') return PaymentResponse(id: paymentId, status: 'SUCCESS');
    throw Exception('Invalid OTP');
  }

  @override
  Future<List<TemplateModel>> getTemplates() async => List.from(_templates);

  @override
  Future<void> saveTemplate(TemplateModel t) async {
    _templates.removeWhere((e) => e.id == t.id);
    _templates.add(t);
    if (localDb != null) await localDb!.saveTemplate(t);
  }

  @override
  Future<List<ScheduleModel>> getSchedules() async => List.from(_schedules);

  @override
  Future<void> saveSchedule(ScheduleModel s) async {
    _schedules.removeWhere((e) => e.id == s.id);
    _schedules.add(s);
    if (localDb != null) await localDb!.saveSchedule(s);
  }
}
