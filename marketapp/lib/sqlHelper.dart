import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLHelper {
  static Database? _db;

  // Initialize the database
  static Future<void> initDb() async {
    // Ensure database is initialized only once
    if (_db != null) {
      return;
    }

    // Initializing the database engine
    sqfliteFfiInit();

    // Setting up the database path
    var databaseFactory = databaseFactoryFfi;
    String dbPath = await databaseFactory.getDatabasesPath() + 'my_database.db';

    // Open the database
    _db = await databaseFactory.openDatabase(dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int version) async {
            // Creating tables
            await db.execute(
                'CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY, name TEXT, value TEXT)');
          },
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            // Handle database upgrades if needed
          },
        ));
  }

  // Getter for database instance
  static Database? get db {
    return _db;
  }

  static Future<void> createTable(
      String tableName, List<String> columns) async {
    final db = _db;
    if (db == null) {
      throw Exception("Database not initialized");
    }

    String columnDefinitions = columns.join(', ');
    String sql = 'CREATE TABLE IF NOT EXISTS $tableName ($columnDefinitions)';
    await db.execute(sql);
  }
}
