import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'post_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('posts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Get the standard mobile database directory
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Open the database with standard mobile factory
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

  // CRUD: Create
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

  // CRUD: Update
  Future<int> update(Post post) async {
    final db = await instance.database;
    return db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // CRUD: Delete
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }
}
