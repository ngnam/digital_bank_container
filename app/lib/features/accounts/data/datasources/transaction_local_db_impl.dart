import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_local_db.dart';

class TransactionLocalDbImpl implements TransactionLocalDb {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transactions.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY,
            accountId INTEGER,
            type TEXT,
            description TEXT,
            amount REAL,
            timestamp TEXT
          )
        ''');
      },
    );
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
      type: e['type'] as String,
      amount: (e['amount'] as num).toDouble(),
      description: e['description'] as String,
      timestamp: DateTime.parse(e['timestamp'] as String),
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
    await db.delete('transactions');
  }
}
