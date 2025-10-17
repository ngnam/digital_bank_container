import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../domain/models/template.dart';
import '../domain/models/schedule.dart';
import 'payment_local_db.dart';

class PaymentLocalDbImpl implements PaymentLocalDb {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'payments.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE templates (
          id INTEGER PRIMARY KEY,
          name TEXT,
          accountNumber TEXT,
          bankCode TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE schedules (
          id INTEGER PRIMARY KEY,
          name TEXT,
          cron TEXT,
          fromAccountId INTEGER,
          amount REAL
        )
      ''');
      await db.execute('''
        CREATE TABLE pending_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          payload TEXT,
          createdAt TEXT,
          attempts INTEGER DEFAULT 0
        )
      ''');
    });
    return _db!;
  }

  @override
  Future<void> init() async { await database; }

  @override
  Future<List<TemplateModel>> getTemplates() async {
    final db = await database;
    final rows = await db.query('templates');
    return rows.map((r) => TemplateModel.fromJson(r)).toList();
  }

  @override
  Future<void> saveTemplate(TemplateModel t) async {
    final db = await database;
    await db.insert('templates', t.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    final db = await database;
    final rows = await db.query('schedules');
    return rows.map((r) => ScheduleModel.fromJson(r)).toList();
  }

  @override
  Future<void> saveSchedule(ScheduleModel s) async {
    final db = await database;
    await db.insert('schedules', s.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> addPendingPayment(Map<String, dynamic> payload) async {
    final db = await database;
    await db.insert('pending_payments', {'payload': jsonEncode(payload), 'createdAt': DateTime.now().toIso8601String(), 'attempts': 0});
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingPayments() async {
    final db = await database;
    final rows = await db.query('pending_payments', orderBy: 'createdAt ASC');
    return rows;
  }

  @override
  Future<void> removePendingPayment(int id) async {
    final db = await database;
    await db.delete('pending_payments', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> incrementPendingAttempts(int id) async {
    final db = await database;
    await db.rawUpdate('UPDATE pending_payments SET attempts = attempts + 1 WHERE id = ?', [id]);
  }
}
