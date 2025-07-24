// // lib/core/database/database_service.dart
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import '../models/api_request.dart';

// class DatabaseService {
//   static const _dbName = 'api_tester.db';
//   static const _tableName = 'requests';
//   Database? _db;

//   // Singleton pattern to ensure only one instance of the database service
//   DatabaseService._privateConstructor();
//   static final DatabaseService instance = DatabaseService._privateConstructor();

//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await init();
//     return _db!;
//   }

//   Future<Database> init() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, _dbName);
//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }

//   // Create the table when the database is first created
//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $_tableName(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         method TEXT NOT NULL,
//         url TEXT NOT NULL,
//         headers TEXT NOT NULL,
//         params TEXT NOT NULL,
//         body TEXT NOT NULL
//       )
//     ''');
//   }

//   // Method to get all saved requests from the database
//   Future<List<ApiRequest>> getRequests() async {
//     final db = await instance.database;
//     final List<Map<String, dynamic>> maps = await db.query(_tableName);
//     return List.generate(maps.length, (i) {
//       return ApiRequest.fromDbMap(maps[i]);
//     });
//   }

//   // Method to insert a new request into the database
//   Future<void> insertRequest(ApiRequest request) async {
//     final db = await instance.database;
//     await db.insert(
//       _tableName,
//       request.toDbMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Method to delete a request from the database
//   Future<void> deleteRequest(int id) async {
//     final db = await instance.database;
//     await db.delete(
//       _tableName,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }

// lib/core/database/database_service.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/api_request.dart';

class DatabaseService {
  static const _dbName = 'api_tester.db';
  static const _tableName = 'requests';
  Database? _db;

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await init();
    return _db!;
  }

  Future<Database> init() async {
    // sqflite_common_ffi on desktop uses a custom path.
    // getDatabasesPath() will correctly return the AppData/Roaming folder path.
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    // This openDatabase call will now use the FFI factory we set in main.dart
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        method TEXT NOT NULL,
        url TEXT NOT NULL,
        headers TEXT NOT NULL,
        params TEXT NOT NULL,
        body TEXT NOT NULL,
        bodyType INTEGER NOT NULL,
        formDataText TEXT NOT NULL
      )
    ''');
  }

  Future<List<ApiRequest>> getRequests() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return ApiRequest.fromDbMap(maps[i]);
    });
  }

  Future<void> insertRequest(ApiRequest request) async {
    final db = await instance.database;
    await db.insert(
      _tableName,
      request.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRequest(int id) async {
    final db = await instance.database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}