import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/api_manager.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/models/api_has_fetched.dart';

class VehicleType implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS vehicle_type (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      style TEXT NOT NULL,
      fuel TEXT NOT NULL,
      double_decker INTEGER NOT NULL,
      coach INTEGER NOT NULL,
      electric INTEGER NOT NULL
    );
  ''';

  final int id;
  final String name;
  final String style;
  final String fuel;
  final bool doubleDecker;
  final bool coach;
  final bool electric;

  VehicleType({
    required this.id,
    required this.name,
    required this.style,
    required this.fuel,
    required this.doubleDecker,
    required this.coach,
    required this.electric,
  });

  @override
  factory VehicleType.buildFromMap(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      style: json['style'] ?? '',
      fuel: json['fuel'] ?? '',
      doubleDecker:
          json['double_decker'] is bool
              ? json['double_decker']
              : (json['double_decker'] ?? 0) == 1,
      coach: json['coach'] is bool ? json['coach'] : (json['coach'] ?? 0) == 1,
      electric:
          json['electric'] is bool
              ? json['electric']
              : (json['electric'] ?? 0) == 1,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'style': style,
      'fuel': fuel,
      'double_decker': doubleDecker ? 1 : 0,
      'coach': coach ? 1 : 0,
      'electric': electric ? 1 : 0,
    };
  }

  static Map<int, VehicleType> cache = {};

  static Future<void> updateCache() async {
    final vehicleTypes = await VehicleType.getAll();

    cache = {
      for (final vehicleType in vehicleTypes) vehicleType.id: vehicleType,
    };
  }

  static Future<List<VehicleType>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('vehicle_type');

    return rows.map((row) => VehicleType.buildFromMap(row)).toList();
  }

  static Future<List<VehicleType>> getAllApi({bool force = false}) async {
    await VehicleType.updateCache();
    return ApiHasFetched.full(
      ApiHasFetchedName.vehicleTypes,
      "",
      () => VehicleType.getAll(),
      () => ApiManager.getAllPaginated<VehicleType>(
        ApiOptions(
          endpoint: 'vehicletypes',
          query: {'limit': '1000'},
          fromMap: VehicleType.buildFromMap,
        ),
      ),
      updateCache: VehicleType.updateCache,
      insertInto: TableKey.vehicleType,
      skip: force,
    );
  }

  Future<List<Vehicle>> getVehicles(
    VehicleQuery query, {
    bool refresh = false,
  }) async {
    query.vehicleType = id;
    return await ApiHasFetched.full(
      ApiHasFetchedName.operatorVehicles,
      id.toString(),
      () async =>
          (await Vehicle.getAll())
              .where((v) => v.vehicleType?.id == id)
              .toList(),
      () async => await Vehicle.getAllApi(query),
      skip: refresh,
      insertInto: TableKey.vehicle,
    );
  }
}
