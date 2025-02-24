import 'package:flutter/material.dart';
import 'package:meditation/models/moods_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

const String fileName = 'moods_sqflite_database.db';
const String tableName = 'moods';

class AppDatabase {
  AppDatabase._init();
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDB(fileName);
    return _database!;
  }

  Future<Database> _initializeDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      assetImagePath TEXT DEFAULT NULL
      )
    ''');
  }

Future<void> createMoods(MoodsModel moodsModel) async {
  final db = await database;
  await db.insert(tableName, moodsModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

  Future<List<MoodsModel?>> realAllMoods() async {
    final db = await instance.database;
    final result = await db.query(tableName);
    return result.map((json) => MoodsModel.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    return db.close();
  }

  Future<void> delete(int id) async {
    final db = await database;
    try {
      await db.delete(tableName,
          where: "$id = ?",
          whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
