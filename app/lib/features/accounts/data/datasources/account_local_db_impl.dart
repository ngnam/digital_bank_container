import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import 'account_local_db.dart';

class AccountLocalDbImpl implements AccountLocalDb {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'accounts.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id INTEGER PRIMARY KEY,
            name TEXT,
            accountNumber TEXT,
            balance REAL,
            isOffline INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY,
            accountId INTEGER,
            description TEXT,
            amount REAL,
            date TEXT,
            isOffline INTEGER
          )
        ''');
      },
    );
  }

  @override
  Future<List<AccountEntity>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts');
    return maps.map((e) => AccountEntity(
      id: e['id'] as int,
      name: e['name'] as String,
      accountNumber: e['accountNumber'] as String,
      balance: e['balance'] as double,
      isOffline: (e['isOffline'] as int) == 1,
    )).toList();
  }

  @override
  Future<void> cacheAccounts(List<AccountEntity> accounts) async {
    final db = await database;
    final batch = db.batch();
    for (final acc in accounts) {
      batch.insert('accounts', {
        'id': acc.id,
        'name': acc.name,
        'accountNumber': acc.accountNumber,
        'balance': acc.balance,
        'isOffline': acc.isOffline ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<AccountEntity?> getAccountDetail(int id) async {
    final db = await database;
    final maps = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final e = maps.first;
    return AccountEntity(
      id: e['id'] as int,
      name: e['name'] as String,
      accountNumber: e['accountNumber'] as String,
      balance: e['balance'] as double,
      isOffline: (e['isOffline'] as int) == 1,
    );
  }

  @override
  Future<void> cacheAccountDetail(AccountEntity account) async {
    final db = await database;
    await db.insert('accounts', {
      'id': account.id,
      'name': account.name,
      'accountNumber': account.accountNumber,
      'balance': account.balance,
      'isOffline': account.isOffline ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<TransactionEntity>> getTransactions(int accountId, {int page = 1, int pageSize = 20}) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      limit: pageSize,
      offset: (page - 1) * pageSize,
      orderBy: 'date DESC',
    );
    return maps.map((e) => TransactionEntity(
      id: e['id'] as int,
      accountId: e['accountId'] as int,
      description: e['description'] as String,
      amount: e['amount'] as double,
      date: e['date'] as String,
      isOffline: (e['isOffline'] as int) == 1,
    )).toList();
  }

  @override
  Future<void> cacheTransactions(int accountId, List<TransactionEntity> transactions) async {
    final db = await database;
    final batch = db.batch();
    for (final tx in transactions) {
      batch.insert('transactions', {
        'id': tx.id,
        'accountId': tx.accountId,
        'description': tx.description,
        'amount': tx.amount,
        'date': tx.date,
        'isOffline': tx.isOffline ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('accounts');
    await db.delete('transactions');
  }
}
