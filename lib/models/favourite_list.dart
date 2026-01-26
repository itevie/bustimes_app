import 'package:route_log/app_database.dart';

class FavouriteList {
  static String sqlTable = '''
    CREATE TABLE IF NOT EXISTS favourite_list (
      id INTEGER PRIMARY KEY REFERENCES route_checklist(id),
      added_at TEXT NOT NULL
    );
  ''';

  int id;
  DateTime addedAt;

  FavouriteList({required this.id, required this.addedAt});

  factory FavouriteList.fromMap(Map<String, dynamic> map) {
    return FavouriteList(
      id: map['id'],
      addedAt:
          map['added_at'] != null
              ? DateTime.parse(map['added_at'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'added_at': addedAt.toIso8601String()};
  }

  static Map<int, FavouriteList> cache = {};

  static Future<void> updateCache() async {
    final lists = await FavouriteList.getAll();

    cache = {for (final list in lists) list.id: list};
  }

  // ----- SQL Functions -----
  static Future<List<FavouriteList>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('favourite_list');

    return rows.map((row) => FavouriteList.fromMap(row)).toList();
  }

  static Future<bool?> update(int id) async {
    final db = await AppDatabase.instance.db;

    if (FavouriteList.cache.containsKey(id)) {
      await db.delete('favourite_list', where: 'id = ?', whereArgs: [id]);
      await FavouriteList.updateCache();
      return false;
    } else {
      if (FavouriteList.cache.length >= 3) {
        return null;
      }

      await db.insert('favourite_list', {
        'id': id,
        'added_at': DateTime.now().toIso8601String(),
      });
      await FavouriteList.updateCache();
      return true;
    }
  }
}
