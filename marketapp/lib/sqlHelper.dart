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

  // Check if a date already exists in the table
  static Future<bool> dateExists(
      Database db, String tableName, String date) async {
    var result = await db.rawQuery(
      'SELECT date FROM "$tableName" WHERE date = ?',
      [date],
    );
    return result.isNotEmpty;
  }

  // Insert data into the table
  static Future<void> insertData(
      Database db, String tableName, Map<String, String> data) async {
    Batch batch = db.batch();

    for (var entry in data.entries) {
      bool exists = await dateExists(db, tableName, entry.key);
      if (!exists) {
        batch.rawInsert(
          'INSERT INTO "$tableName" (date, price) VALUES (?, ?)',
          [entry.key, entry.value],
        );
      }
    }

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

  // Retrieve all data from the specified table
  static Future<List<Map<String, dynamic>>> getAllData(String tableName) async {
    final Database db = await initializeDB();
    try {
      return await db.query('"$tableName"');
    } catch (e) {
      throw Exception('Error retrieving data from $tableName: $e');
    }
  }
}
