import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/api_manager.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:sqflite/sqflite.dart';

enum ApiHasFetchedName {
  serviceStops('service_stop'),
  serviceQuery("service_query"),
  stopQuery("stop_query"),
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

  static Future<void> setOffsetComplete(
    ApiHasFetchedName name,
    String key,
    int offset,
  ) async {
    final db = await AppDatabase.instance.db;

    await db.insert('api_has_fetched', {
      'name': "${name.name}_offset_$offset",
      'key': key,
      'fetched_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> setOffsetDone(ApiHasFetchedName name, String key) async {
    final db = await AppDatabase.instance.db;

    await db.insert('api_has_fetched', {
      'name': "${name.name}_offset_done",
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

  static Future<bool> getOffsetComplete(
    ApiHasFetchedName name,
    String key,
    int offset,
  ) async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query(
      'api_has_fetched',
      where: "name = ? AND key = ?",
      whereArgs: ["${name.name}_offset_$offset", key],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  static Future<bool> getOffsetDone(ApiHasFetchedName name, String key) async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query(
      'api_has_fetched',
      where: "name = ? AND key = ?",
      whereArgs: ["${name.name}_offset_done", key],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  static Future<void> deleteOffsets(ApiHasFetchedName name, String key) async {
    final db = await AppDatabase.instance.db;

    await db.delete(
      'api_has_fetched',
      where: "name LIKE CONCAT(?, '_offset_%') AND key = ?",
      whereArgs: [name.name, key],
    );
  }

  // If the offset has already been made, return the full list
  // Otherwise, fetch the new offset, insert it all, then return the full list
  //
  // 1. If bool(refresh) is true, delete all offsets and fetch at int(offset)
  //    - Fetching new ones should overwrite old ones
  // 2. Fetch all from function(getLocal)
  // 3. Check if bool(offset) has been stored,
  //    yes = return 2.,
  //    no = fetch int(offset), store in DB, and add to function(getLocal)
  static Future<List<T>> fullNew<T extends BaseModel>(
    ApiHasFetchedName name,
    String key,
    Future<List<T>> Function() getLocal,
    T Function(Map<String, dynamic>) build,
    String path,
    int offset, {
    Map<String, dynamic>? query,
    TableKey? insertInto,
    bool refresh = false,
    bool getAll = false,
  }) async {
    if (getAll) {
      List<T> objects = await ApiManager.getAllPaginated(
        ApiOptions(
          endpoint: path,
          fromMap: build,
          query: {if (query != null) ...query},
        ),
      );

      if (insertInto != null) {
        AppDatabase.instance.insertManyInBackground(
          insertInto,
          objects.map((x) => x.toMap()).toList(),
        );
      }

      return objects;
    }

    // Check if should reset fully
    if (refresh) {
      await ApiHasFetched.deleteOffsets(name, key);
    }

    // Whether or not to complete early
    if (await ApiHasFetched.getOffsetComplete(name, key, offset)) {
      return await getLocal();
    }

    // Fetch the current offset
    final fetched =
        ((await ApiManager.get(
              ApiOptions(
                endpoint: path,
                fromMap: build,
                query: {
                  if (query != null) ...query,
                  'offset': offset.toString(),
                },
              ),
            )))['results']
            as List;
    final objects = fetched.map((x) => build(x));

    // Combine into local
    List<T> finished = [...await getLocal(), ...objects];

    // Insert things
    await ApiHasFetched.setOffsetComplete(name, key, offset);
    if (objects.isEmpty) {
      await ApiHasFetched.setOffsetDone(name, key);
    }

    if (insertInto != null) {
      AppDatabase.instance.insertManyInBackground(
        insertInto,
        objects.map((x) => x.toMap()).toList(),
      );
    }

    return finished;
  }

  static Future<List<T>> full<T extends BaseModel>(
    ApiHasFetchedName name,
    String key,
    Future<List<T>> Function() exists,
    Future<List<T>> Function() doesNotExist, {
    bool skip = false,
    TableKey? insertInto,
    Future<void> Function()? updateCache,
    int? offset,
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
