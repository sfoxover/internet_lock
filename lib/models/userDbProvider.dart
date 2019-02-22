import 'dart:async';
import 'dart:io';
import 'package:internet_lock/models/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class UserDBProvider {
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "users.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE users ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "pin TEXT,"
          "created_date TEXT"
          ")");
    });
  }

  add(User user) async {
    try {
      final db = await database;
      // get the biggest id in the table
      var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM users");
      int id = table.first["id"];
      //insert to the table using the new id
      var raw = await db.rawInsert(
          "INSERT Into users (id,name,pin,created_date)"
          " VALUES (?,?,?,?)",
          [id, user.name, user.pin, user.createdDate]);
      return raw;
    } catch (e) {
      print("Exception in UserDBProvider::add, ${e.toString()}");
      return -1;
    }
  }

  update(User user) async {
    final db = await database;
    var res = await db
        .update("users", user.toJson(), where: "id = ?", whereArgs: [user.id]);
    return res;
  }

  get(int id) async {
    final db = await database;
    var result = await db.query("users", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? User.fromJson(result.first) : null;
  }

  Future<List<User>> getAll() async {
    try {
      final db = await database;
      var res = await db.query("users", orderBy: "name");
      List<User> list =
          res.isNotEmpty ? res.map((c) => User.fromJson(c)).toList() : [];
      return list;
    } catch (e) {
      print("Exception in UserDBProvider::getAll, ${e.toString()}");
      return null;
    }
  }

  delete(int id) async {
    final db = await database;
    return db.delete("users", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from users");
  }

  Future<bool> isEmpty() async {
    try {
      final db = await database;
      var result = await db.rawQuery("SELECT COUNT(*) from users");
      return (result != null);
    } catch (e) {
      print("Exception in UserDBProvider::isEmpty, ${e.toString()}");
    }
    return true;
  }
}
