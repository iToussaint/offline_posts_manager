import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'post_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Add this
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('posts.db');
    return _database!;
  }

  // ... inside your _initDB method
  Future<Database> _initDB(String filePath) async {
    // Check if NOT on web before accessing Platform
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } else {
      throw Exception("SQLite is not supported on the Web for this lab.");
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
  }

  // CRUD: Create [cite: 9]
  Future<int> create(Post post) async {
    final db = await instance.database;
    return await db.insert('posts', post.toMap());
  }

  // CRUD: Read All
  Future<List<Post>> readAllPosts() async {
    final db = await instance.database;
    final result = await db.query('posts', orderBy: 'id DESC');
    return result.map((json) => Post.fromMap(json)).toList();
  }

  // CRUD: Update [cite: 10]
  Future<int> update(Post post) async {
    final db = await instance.database;
    return db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // CRUD: Delete [cite: 11]
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }
}
