import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/stop.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/bustimes/models/vehicle_type.dart';
import 'package:route_log/models/api_has_fetched.dart';
import 'package:route_log/models/favourite_list.dart';
import 'package:route_log/models/favourite_operator.dart';
import 'package:route_log/models/favourite_service.dart';
import 'package:route_log/models/favourite_vehicles.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/models/route_checklist_item.dart';
// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

enum TableKey {
  operator('operator'),
  vehicle('vehicle'),
  vehicleType('vehicle_type'),
  livery('livery'),
  garage('garage'),
  service('service'),
  stop('stop');

  final String name;
  const TableKey(this.name);
}

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'route_log.db');
    print(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(Operator.sqlTable);
    await db.execute(Livery.sqlTable);
    await db.execute(VehicleType.sqlTable);
    await db.execute(Stop.sqlTable);
    await db.execute(Vehicle.sqlTable);
    await db.execute(Service.sqlTable);
    await db.execute(FavouriteOperator.sqlTable);
    await db.execute(FavouriteVehicles.sqlTable);
    await db.execute(FavouriteService.sqlTable);
    await db.execute(FavouriteList.sqlTable);
    await db.execute(RouteChecklist.sqlTable);
    await db.execute(RouteChecklistItem.sqlTable);
    await db.execute(ApiHasFetched.sqlTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations later
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> insertMany(
    TableKey table,
    List<Map<String, dynamic>> values, {
    Future<void> Function()? updateCache,
  }) async {
    if (values.isEmpty) return;

    final database = await db;

    await database.transaction((txn) async {
      for (final row in values) {
        await txn.insert(
          table.name,
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    if (updateCache != null) await updateCache();
  }

  void insertManyInBackground(
    TableKey table,
    List<Map<String, dynamic>> values, {
    Future<void> Function()? updateCache,
  }) {
    unawaited(insertMany(table, values, updateCache: updateCache));
  }
}
