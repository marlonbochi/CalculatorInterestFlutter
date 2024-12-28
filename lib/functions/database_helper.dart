import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Singleton Pattern
  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  // Table and Database Details
  final String tableName = 'history';
  final String columnId = 'id';
  final String columnDesposit = 'desposit';
  final String columnInterest = 'interest';
  final String columnMonths = 'months';

  // Initialize Database
  Future<Database> get database async {
    if (_database != null) return _database!;

    databaseFactory = databaseFactoryFfiWeb;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'calculator.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
					CREATE TABLE $tableName (
						$columnId INTEGER PRIMARY KEY AUTOINCREMENT,
						$columnDesposit TEXT NOT NULL,
						$columnInterest TEXT NOT NULL,
						$columnMonths TEXT NOT NULL
					)
				''');
      },
    );
  }

  // Insert Data
  Future<int> insertItem(
      String desposit, String interest, String months) async {
    final db = await database;
    return await db.insert(
      tableName,
      {
        columnDesposit: desposit,
        columnInterest: interest,
        columnMonths: months
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get All Data
  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await database;
    return await db.query(tableName);
  }

  // Update Data
  Future<int> updateItem(
      int id, String desposit, String interest, String months) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        columnDesposit: desposit,
        columnInterest: interest,
        columnMonths: months
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Delete Data
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllItems() async {
    final db = await database;
    await db.delete(tableName);
  }

  // Close Database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
