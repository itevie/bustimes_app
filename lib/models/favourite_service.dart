import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/service.dart';

class FavouriteService {
  static String sqlTable = '''
    CREATE TABLE IF NOT EXISTS favourite_service (
      id INTEGER PRIMARY KEY REFERENCES service(id),
      added_at TEXT NOT NULL
    );
  ''';

  int id;
  DateTime addedAt;

  FavouriteService({required this.id, required this.addedAt});

  factory FavouriteService.fromMap(Map<String, dynamic> map) {
    return FavouriteService(
      id: map['id'] ?? 0,
      addedAt:
          map['added_at'] != null
              ? DateTime.parse(map['added_at'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'added_at': addedAt.toIso8601String()};
  }

  static Map<int, FavouriteService> cache = {};

  static Future<void> updateCache() async {
    final services = await FavouriteService.getAll();

    cache = {for (final service in services) service.id: service};
  }

  // ----- SQL Functions -----
  static Future<List<FavouriteService>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('favourite_service');

    return rows.map((row) => FavouriteService.fromMap(row)).toList();
  }

  static Future<List<Service>> getAllAsObject() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.rawQuery('''
      SELECT * FROM service WHERE id IN (SELECT id FROM favourite_service)
    ''');

    return rows.map((row) => Service.buildFromMap(row)).toList();
  }

  static Future<bool> update(int id) async {
    final db = await AppDatabase.instance.db;

    if (FavouriteService.cache.containsKey(id)) {
      await db.delete('favourite_service', where: 'id = ?', whereArgs: [id]);
      await FavouriteService.updateCache();
      return false;
    } else {
      await db.insert('favourite_service', {
        'id': id,
        'added_at': DateTime.now().toIso8601String(),
      });
      await FavouriteService.updateCache();
      return true;
    }
  }
}
