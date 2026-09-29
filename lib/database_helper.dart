import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'main.dart'; // เพื่อใช้ class Diary

class DatabaseHelper {
  static Database? _db;

  // เปิดฐานข้อมูล (เปิดครั้งเดียว ใช้ซ้ำ)
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'mydiary.db'), // ที่อยู่ไฟล์ DB
      version: 1,
      onCreate: (db, version) {
        // สร้างตาราง (รันครั้งแรกครั้งเดียว)
        db.execute(
          'CREATE TABLE diaries('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL, '
          'content TEXT NOT NULL, '
          'date TEXT NOT NULL,'
          'mood TEXT NOT NULL,'
          'quote TEXT NOT NULL)',
        );
        db.execute(
          'CREATE TABLE pokemons('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'number INTEGER NOT NULL, '
          'name TEXT NOT NULL, '
          'remark TEXT NOT NULL,'
          'date TEXT NOT NULL,',
        );
      },
    );
    return _db!;
  }

  // เพิ่มบันทึก
  static Future<void> insert(Poke pokemon) async {
    final db = await database;
    await db.insert('pokemons', pokemon.toMap());
  }

  // อ่านบันทึกทั้งหมด
  static Future<List<Diary>> getAll() async {
    final db = await database;
    final maps = await db.query('diaries', orderBy: 'id DESC');
    return maps.map((map) => Diary.fromMap(map)).toList();
  }

  static Future<List<Poke>> getPokemon() async {
    final db = await database;
    final maps = await db.query('pokemons', orderBy: 'id DESC');
    return maps.map((map) => Poke.fromMap(map)).toList();
  }

  // ลบบันทึก
  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete('pokemons', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> update(Poke pokemon) async {
    final db = await database;
    await db.update(
      'pokemons',
      pokemon.toMap(),
      where: 'id = ?',
      whereArgs: [pokemon.id],
    );
  }

  // ค้นหาบันทึก
  static Future<List<Diary>> search(String keyword) async {
    final db = await database;
    final maps = await db.query(
      'diaries',
      where: 'title LIKE ? OR content LIKE ? OR mood LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );
    return maps.map((map) => Diary.fromMap(map)).toList();
  }
}
