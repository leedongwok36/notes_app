import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes_v2.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        colorHex TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> create(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> readAll() async {
    final db = await instance.database;
    final maps = await db.query('notes', orderBy: 'updatedAt DESC');
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;
    return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}