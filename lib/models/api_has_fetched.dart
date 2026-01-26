import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:sqflite/sqflite.dart';

enum ApiHasFetchedName {
  serviceStops('service_stop'),
  serviceQuery("service_query"),
  operatorVehicles('operator_vehicles'),
  liveryVehicles('livery_vehicles'),
  operatorRoutes('operator_routes'),
  vehicleTypes('vehicle_types'),
  vehicleQuery("vehicle_query"),
  vehicleTypeVehicles('vehicle_type_vehicles'),
  liveries('liveries'),
  operators('operators');

  final String name;
  const ApiHasFetchedName(this.name);
}

class ApiHasFetched {
  static String sqlTable = '''
    CREATE TABLE IF NOT EXISTS api_has_fetched (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      key TEXT NOT NULL,
      fetched_at TEXT NOT NULL
    );
  ''';

  int id;
  String name;
  String key;
  DateTime fetchedAt;

  ApiHasFetched({
    required this.id,
    required this.name,
    required this.key,
    required this.fetchedAt,
  });

  factory ApiHasFetched.fromMap(Map<String, dynamic> map) {
    return ApiHasFetched(
      id: map['id'],
      name: map['name'],
      key: map['key'],
      fetchedAt:
          map['fetched_at'] != null
              ? DateTime.parse(map['fetched_at'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'key': key,
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }

  // ----- SQL Functions -----
  static Future<void> insert(ApiHasFetchedName name, String key) async {
    final db = await AppDatabase.instance.db;

    await db.insert('api_has_fetched', {
      'name': name.name,
      'key': key,
      'fetched_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<bool> get(ApiHasFetchedName name, String key) async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query(
      'api_has_fetched',
      where: "name = ? AND key = ?",
      whereArgs: [name.name, key],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  static Future<List<T>> full<T extends BaseModel>(
    ApiHasFetchedName name,
    String key,
    Future<List<T>> Function() exists,
    Future<List<T>> Function() doesNotExist, {
    bool skip = false,
    TableKey? insertInto,
    Future<void> Function()? updateCache,
  }) async {
    if (skip) {
      return await doesNotExist();
    }

    bool keyExists = await ApiHasFetched.get(name, key);

    if (keyExists) {
      return await exists();
    } else {
      final result = await doesNotExist();
      await ApiHasFetched.insert(name, key);

      if (insertInto != null) {
        AppDatabase.instance.insertManyInBackground(
          insertInto,
          result.map((x) => x.toMap()).toList(),
        );

        if (updateCache != null) await updateCache();
      }

      return result;
    }
  }
}
