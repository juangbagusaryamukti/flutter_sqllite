import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'kindacode.db'),
      version: 2,
      onCreate: (Database database, int version) async {
        await database.execute(
          """
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT,
            description TEXT,
            imagePath TEXT,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
          """,
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE items ADD COLUMN imagePath TEXT');
        }
      },
    );
  }

  // Mengambil semua data dari tabel items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  // Mengambil satu data berdasarkan id
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Menambahkan item baru
  static Future<int> createItem(
      String title, String? description, String? imagePath) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'imagePath': imagePath
    };
    return await db.insert('items', data);
  }

  // Memperbarui item berdasarkan id
  static Future<int> updateItem(
      int id, String title, String? description, String? imagePath) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'createdAt': DateTime.now().toString()
    };
    return await db.update('items', data, where: "id = ?", whereArgs: [id]);
  }

  // Menghapus item berdasarkan id
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    await db.delete(
      'items',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
