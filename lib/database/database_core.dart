import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseCore {
  static final DatabaseCore _instance = DatabaseCore._internal();
  static Database? _database;

  factory DatabaseCore() => _instance;

  DatabaseCore._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'portfolio_tracker.db');
    return await openDatabase(
      path,
      version: 3,  // Increment version number
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE assets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        current_price REAL NOT NULL,
        total_quantity REAL NOT NULL,
        average_purchase_price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE asset_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        asset_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        quantity REAL,
        price REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY(asset_id) REFERENCES assets(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Fix inconsistent date formats in transactions
      var transactions = await db.query('asset_transactions');
      for (var transaction in transactions) {
        String date = transaction['date'] as String;
        if (!date.endsWith('Z')) {
          DateTime localDate = DateTime.parse(date);
          String utcDate = localDate.toUtc().toIso8601String();
          String dateWithZ = utcDate.endsWith('Z') ? utcDate : '${utcDate}Z';
          
          await db.update(
            'asset_transactions',
            {'date': dateWithZ},
            where: 'id = ?',
            whereArgs: [transaction['id']],
          );
        }
      }
    }

    if (oldVersion < 3) {
      // Fix current prices based on most recent transactions
      await db.transaction((txn) async {
        final assets = await txn.query('assets');
        
        for (final asset in assets) {
          final latestTransaction = await txn.query(
            'asset_transactions',
            where: 'asset_id = ?',
            whereArgs: [asset['id']],
            orderBy: 'date DESC',
            limit: 1
          );

          if (latestTransaction.isNotEmpty) {
            await txn.update(
              'assets',
              {'current_price': latestTransaction.first['price']},
              where: 'id = ?',
              whereArgs: [asset['id']]
            );
          }
        }
      });
    }
  }
}