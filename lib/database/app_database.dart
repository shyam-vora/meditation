import 'package:flutter/material.dart';
import 'package:meditation/models/moods_model.dart';
import 'package:meditation/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

const String fileName = 'moods_sqfliteddd4_db.db';

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
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        is_admin INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        assetImagePath TEXT DEFAULT NULL,
        count INTEGER DEFAULT 1
      )
    ''');

    // Initialize system admin user
    await db.insert(
        'users',
        {
          'username': 'System Admin',
          'email': 'admin@system.com',
          'password': 'admin123',
          'is_admin': 1
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> createMoods(MoodsModel moodsModel) async {
    final db = await database;
    await db.insert('moods', moodsModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> createOrIncrementMood(MoodsModel moodsModel) async {
    final db = await database;

    // Check if mood exists
    final List<Map<String, dynamic>> result = await db.query(
      'moods',
      where: 'name = ?',
      whereArgs: [moodsModel.name],
    );

    if (result.isEmpty) {
      // Insert new mood
      await db.insert('moods', moodsModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      // Increment count
      await db.rawUpdate('''
        UPDATE moods 
        SET count = count + 1 
        WHERE name = ?
      ''', [moodsModel.name]);
    }
  }

  Future<List<MoodsModel?>> realAllMoods() async {
    final db = await instance.database;
    final result = await db.query('moods');
    return result.map((json) => MoodsModel.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    return db.close();
  }

  Future<void> delete(int id) async {
    final db = await database;
    try {
      await db.delete(
        'moods',
        where: "id = ?", // Use the column name here
        whereArgs: [id], // Pass the id value as a parameter
      );
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      columns: ['id', 'username', 'email', 'password', 'is_admin'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<bool> isAdminUser(String email) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      columns: ['is_admin'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return maps.first['is_admin'] == 1;
    }
    return false;
  }

  Future<List<MoodsModel>> getMoodsByUsage() async {
    final db = await instance.database;
    final result = await db.query(
      'moods',
      orderBy: 'count DESC',
    );
    return result.map((json) => MoodsModel.fromMap(json)).toList();
  }

  Future<int> getTotalMoodsPlayed() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(count) as total FROM moods');
    return (result.first['total'] as int?) ?? 0;
  }
}
