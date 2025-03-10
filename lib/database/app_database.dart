import 'package:flutter/material.dart';
import 'package:meditation/models/moods_model.dart';
import 'package:meditation/models/notification_model.dart';
import 'package:meditation/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/suggestion_model.dart';

const String fileName = 'moods44gdyh_db.db';

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
        is_admin INTEGER DEFAULT 0,
        profile_picture TEXT
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

    await db.execute('''
      CREATE TABLE suggestions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        image_path TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        created_on TEXT NOT NULL
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
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'moods',
        where: 'name = ?',
        whereArgs: [moodsModel.name],
      );

      if (result.isEmpty) {
        await db.insert(
          'moods',
          moodsModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await db.rawUpdate(
          'UPDATE moods SET count = count + 1 WHERE name = ?',
          [moodsModel.name],
        );
      }
    } catch (e) {
      debugPrint("Error in createOrIncrementMood: $e");
      rethrow;
    }
  }

  Future<List<MoodsModel>> realAllMoods() async {
    final db = await instance.database;
    final result = await db.query('moods');
    return result
        .where((map) => map.isNotEmpty)
        .map((json) => MoodsModel.fromMap(json))
        .toList();
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
      columns: [
        'id',
        'username',
        'email',
        'password',
        'is_admin',
        'profile_picture'
      ],
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

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
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

  // CRUD Operations for Suggestions
  Future<int> createSuggestion(Suggestion suggestion) async {
    final db = await database;
    return await db.insert('suggestions', suggestion.toMap());
  }

  Future<List<Suggestion>> getAllSuggestions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('suggestions');
    return List.generate(maps.length, (i) => Suggestion.fromMap(maps[i]));
  }

  Future<int> updateSuggestion(Suggestion suggestion) async {
    final db = await database;
    return await db.update(
      'suggestions',
      suggestion.toMap(),
      where: 'id = ?',
      whereArgs: [suggestion.id],
    );
  }

  Future<int> deleteSuggestion(int id) async {
    final db = await database;
    return await db.delete(
      'suggestions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Notifications
  Future<int> createNotification(NotificationModel notification) async {
    final db = await database;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('notifications', orderBy: 'created_on DESC');
    return List.generate(
        maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  Future<int> updateNotification(NotificationModel notification) async {
    final db = await database;
    return await db.update(
      'notifications',
      notification.toMap(),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
