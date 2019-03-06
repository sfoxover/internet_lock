import 'dart:async';
import 'dart:io';
import 'package:internet_lock/models/website.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class WebsiteDBProvider {
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "websites.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE websites ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "start_url TEXT,"
          "fav_icon_url TEXT,"
          "allowed_urls TEXT"
          ")");
    });
  }

  addWebsite(Website site) async {
    try {
      final db = await database;
      // get the biggest id in the table
      var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM websites");
      int id = table.first["id"];
      //insert to the table using the new id
      var raw = await db.rawInsert(
          "INSERT Into websites (id,title,start_url,fav_icon_url,allowed_urls)"
          " VALUES (?,?,?,?,?)",
          [id, site.title, site.startUrl, site.favIconUrl, site.allowedUrls]);
      return raw;
    } catch (e) {
      print("Exception in WebsiteDBProvider::addWebsite, ${e.toString()}");
      return -1;
    }
  }

  updateWebsite(Website site) async {
    final db = await database;
    var res = await db.update("websites", site.toJson(),
        where: "id = ?", whereArgs: [site.id]);
    return res;
  }

  getWebsite(int id) async {
    final db = await database;
    var res = await db.query("websites", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Website.fromJson(res.first) : null;
  }

  Future<List<Website>> getAllWebsites() async {
    try {
      final db = await database;
      var res = await db.query("websites", orderBy: "title");
      List<Website> list =
          res.isNotEmpty ? res.map((c) => Website.fromJson(c)).toList() : [];
      return list;
    } catch (e) {
      print("Exception in WebsiteDBProvider::getAllWebsites, ${e.toString()}");
      return null;
    }
  }

  deleteWebsite(int id) async {
    final db = await database;
    return db.delete("websites", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from websites");
  }

  isEmpty() async {
    try {
      final db = await database;
      var result = await db.rawQuery("SELECT COUNT(*) from websites");
      bool empty = (result == null || Sqflite.firstIntValue(result) == 0);
      return empty;
    } catch (e) {
      print("Exception in WebsiteDBProvider::isEmpty, ${e.toString()}");
    }
    return true;
  }
}
