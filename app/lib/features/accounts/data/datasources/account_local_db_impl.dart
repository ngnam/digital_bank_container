import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// removed unused model imports
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
            ownerName TEXT,
            currency TEXT,
            accountNumber TEXT,
            balance REAL,
            updatedAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY,
            accountId INTEGER,
            type TEXT,
            amount REAL,
            description TEXT,
            timestamp TEXT
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
      ownerName: e['ownerName'] as String,
      currency: e['currency'] as String,
      accountNumber: e['accountNumber'] as String,
      balance: e['balance'] != null ? (e['balance'] as num).toDouble() : null,
      updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt'] as String) : null,
    )).toList();
  }

  @override
  Future<void> cacheAccounts(List<AccountEntity> accounts) async {
    final db = await database;
    final batch = db.batch();
    for (final acc in accounts) {
      batch.insert('accounts', {
        'id': acc.id,
        'ownerName': acc.ownerName,
        'currency': acc.currency,
        'accountNumber': acc.accountNumber,
        'balance': acc.balance,
        'updatedAt': acc.updatedAt?.toIso8601String(),
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
      ownerName: e['ownerName'] as String,
      currency: e['currency'] as String,
      accountNumber: e['accountNumber'] as String,
      balance: e['balance'] != null ? (e['balance'] as num).toDouble() : null,
      updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt'] as String) : null,
    );
  }

  @override
  Future<void> cacheAccountDetail(AccountEntity account) async {
    final db = await database;
    await db.insert('accounts', {
      'id': account.id,
      'ownerName': account.ownerName,
      'currency': account.currency,
      'accountNumber': account.accountNumber,
      'balance': account.balance,
      'updatedAt': account.updatedAt?.toIso8601String(),
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
      orderBy: 'timestamp DESC',
    );
    return maps.map((e) => TransactionEntity(
      id: e['id'] as int,
      type: e['type'] as String,
      amount: e['amount'] != null ? (e['amount'] as num).toDouble() : 0.0,
      description: e['description'] as String,
      timestamp: e['timestamp'] != null ? DateTime.parse(e['timestamp'] as String) : DateTime.now(),
    )).toList();
  }

  @override
  Future<void> cacheTransactions(int accountId, List<TransactionEntity> transactions) async {
    final db = await database;
    final batch = db.batch();
    for (final tx in transactions) {
      batch.insert('transactions', {
        'id': tx.id,
        'accountId': accountId,
        'type': tx.type,
        'description': tx.description,
        'amount': tx.amount,
        'timestamp': tx.timestamp.toIso8601String(),
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
