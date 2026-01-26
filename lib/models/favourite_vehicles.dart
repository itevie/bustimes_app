import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/vehicle.dart';

class FavouriteVehicles {
  static String sqlTable = '''
    CREATE TABLE IF NOT EXISTS favourite_vehicle (
      id INTEGER PRIMARY KEY REFERENCES vehicle(id),
      added_at TEXT NOT NULL
    );
  ''';

  int id;
  DateTime addedAt;

  FavouriteVehicles({required this.id, required this.addedAt});

  factory FavouriteVehicles.fromMap(Map<String, dynamic> map) {
    return FavouriteVehicles(
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

  static Map<int, FavouriteVehicles> cache = {};

  static Future<void> updateCache() async {
    final vehicles = await FavouriteVehicles.getAll();

    cache = {for (final vehicle in vehicles) vehicle.id: vehicle};
  }

  // ----- SQL Functions -----
  static Future<List<FavouriteVehicles>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('favourite_vehicle');

    return rows.map((row) => FavouriteVehicles.fromMap(row)).toList();
  }

  static Future<List<Vehicle>> getAllAsObject() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.rawQuery('''
      SELECT * FROM vehicle WHERE id IN (SELECT id FROM favourite_vehicle)
    ''');

    return rows.map((row) => Vehicle.buildFromMap(row)).toList();
  }

  static Future<bool> update(int id) async {
    final db = await AppDatabase.instance.db;

    if (FavouriteVehicles.cache.containsKey(id)) {
      await db.delete('favourite_vehicle', where: 'id = ?', whereArgs: [id]);
      await FavouriteVehicles.updateCache();
      return false;
    } else {
      await db.insert('favourite_vehicle', {
        'id': id,
        'added_at': DateTime.now().toIso8601String(),
      });
      await FavouriteVehicles.updateCache();
      return true;
    }
  }
}
