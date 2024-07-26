import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

class sqlHelper {
  // Initialize the database factory for FFI
  static void initializeFactory() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  // Initialize the database
  static Future<Database> initializeDB() async {
    initializeFactory();
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'data.db'),
      onCreate: (database, version) async {
        // The onCreate callback is only executed if the database doesn't exist
      },
      version: 1,
    );
  }

  // Check if the table exists
  static Future<bool> checkTableExists(Database db, String tableName) async {
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // Create a new table
  static Future<void> createTable(Database db, String tableName) async {
    await db.execute('''
      CREATE TABLE "$tableName" (
        date TEXT PRIMARY KEY,
        price TEXT
      )
    ''');
  }

  // Insert data into the table
  static Future<void> insertData(
      Database db, String tableName, Map<String, String> data) async {
    Batch batch = db.batch();

    data.forEach((date, price) {
      batch.insert(
        tableName,
        {'date': date, 'price': price},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  }

  // Create or insert data into the table
  static Future<void> createOrInsertData(
      String tableName, Map<String, String> data) async {
    final Database db = await initializeDB();

    // Check if the table already exists
    bool tableExists = await checkTableExists(db, tableName);

    // If the table doesn't exist, create it
    if (!tableExists) {
      await createTable(db, tableName);
    }

    // Insert data into the table
    await insertData(db, tableName, data);
  }
}
