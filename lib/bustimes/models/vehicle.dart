import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/_base_query.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/bustimes/models/vehicle_type.dart';
import 'package:route_log/models/api_has_fetched.dart';

class VehicleQuery implements BaseQuery {
  int? id;
  String? slug;
  String? operator;
  int? vehicleType;
  int? livery;
  bool? withdrawn;
  String? search;
  String? fleetCode;
  String? reg;
  String? code;
  String? ordering;

  VehicleQuery({
    this.id,
    this.slug,
    this.operator,
    this.vehicleType,
    this.livery,
    this.withdrawn,
    this.search,
    this.fleetCode,
    this.reg,
    this.code,
    this.ordering,
  });

  static const List<String> keys = [
    'id',
    'slug',
    'operator',
    'vehicle_type',
    'livery',
    'withdrawn',
    'search',
    'fleet_code',
    'reg',
    'code',
    'ordering',
  ];

  @override
  Map<String, String> toMap() {
    final map = <String, String>{};

    if (id != null) map['id'] = id.toString();
    if (slug != null) map['slug'] = slug!;
    if (operator != null) map['operator'] = operator!;
    if (vehicleType != null) {
      map['vehicle_type'] = vehicleType.toString();
    }
    if (livery != null) map['livery'] = livery.toString();
    if (withdrawn != null) {
      map['withdrawn'] = withdrawn! ? 'true' : 'false';
    }
    if (search != null) map['search'] = search!;
    if (fleetCode != null) map['fleet_code'] = fleetCode!;
    if (reg != null) map['reg'] = reg!;
    if (code != null) map['code'] = code!;
    if (ordering != null) map['ordering'] = ordering!;

    return map;
  }

  @override
  factory VehicleQuery.buildFromMap(Map<String, dynamic> map) {
    bool? parseBool(String key) {
      final v = map[key];
      if (v == null) return null;
      return v.toString() == 'true';
    }

    int? parseInt(String key) {
      final v = map[key];
      if (v == null) return null;
      return int.tryParse(v.toString());
    }

    return VehicleQuery(
      id: parseInt('id'),
      slug: map['slug']?.toString(),
      operator: map['operator']?.toString(),
      vehicleType: parseInt('vehicle_type'),
      livery: parseInt('livery'),
      withdrawn: parseBool('withdrawn'),
      search: map['search']?.toString(),
      fleetCode: map['fleet_code']?.toString(),
      reg: map['reg']?.toString(),
      code: map['code']?.toString(),
      ordering: map['ordering']?.toString(),
    );
  }
}

class Vehicle implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS vehicle (
      id INTEGER PRIMARY KEY,
      slug TEXT NOT NULL,
      fleet_number INTEGER,
      fleet_code TEXT,
      reg TEXT,
      vehicle_type_id INTEGER REFERENCES vehicle_type(id),
      livery_id INTEGER REFERENCES livery(id),
      operator_noc TEXT NOT NULL REFERENCES operator(noc),
      branding TEXT,
      name TEXT,
      notes TEXT,
      withdrawn INTEGER NOT NULL
    );
  ''';

  final int id;
  final String slug;
  final int? fleetNumber;
  final String? fleetCode;
  final String? reg;

  VehicleType? vehicleType;
  Livery? livery;
  Operator operator;

  final String branding;
  final String name;
  final String notes;
  final bool withdrawn;

  Vehicle({
    required this.id,
    required this.slug,
    this.fleetNumber,
    this.fleetCode,
    this.reg,
    required this.vehicleType,
    this.livery,
    required this.operator,
    required this.branding,
    required this.name,
    required this.notes,
    required this.withdrawn,
  });

  @override
  factory Vehicle.buildFromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? 0,
      slug: map['slug'] ?? '',
      fleetNumber: map['fleet_number'],
      fleetCode: map['fleet_code'],
      reg: map['reg'],

      vehicleType:
          map['vehicle_type'] is Map<String, dynamic>
              ? VehicleType.buildFromMap(map['vehicle_type'])
              : VehicleType.cache[map['vehicle_type_id']],

      livery:
          map['livery'] is Map<String, dynamic>
              ? Livery.cache[map['livery']['id']]
              : Livery.cache[map['livery_id']],

      operator:
          Operator.cache[map['operator'] is Map<String, dynamic>
              ? map['operator']['id']
              : map['operator_noc']] ??
          Operator.buildFromMap({
            "noc":
                map['operator'] is Map<String, dynamic>
                    ? map['operator']['id']
                    : map['operator_noc'],
          }),

      branding: map['branding'] ?? '',
      name: map['name'] ?? '',
      notes: map['notes'] ?? '',
      withdrawn:
          map['withdrawn'] is bool
              ? map['withdrawn']
              : (map['withdrawn'] ?? 0) == 1,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'fleet_number': fleetNumber,
      'fleet_code': fleetCode,
      'reg': reg,
      'vehicle_type_id': vehicleType?.id,
      'livery_id': livery?.id,
      'operator_noc': operator.noc,
      'branding': branding,
      'name': name,
      'notes': notes,
      'withdrawn': withdrawn ? 1 : 0,
    };
  }

  // ----- SQL Functions -----

  static Future<List<Vehicle>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('vehicle');

    return rows.map((row) => Vehicle.buildFromMap(row)).toList();
  }

  static Future<Vehicle?> getById(int id) async {
    final db = await AppDatabase.instance.db;

    final row = await db.query(
      'vehicle',
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (row.isEmpty) return null;
    return Vehicle.buildFromMap(row[0]);
  }

  static Future<List<Vehicle>> getAllByNoc(String noc) async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query(
      'vehicle',
      where: 'operator_noc = ?',
      whereArgs: [noc],
    );

    return rows.map((row) => Vehicle.buildFromMap(row)).toList();
  }

  static Future<List<Vehicle>> getAllForOperator(String noc) async {
    final db = await AppDatabase.instance.db;

    final rows = await db.rawQuery(
      "SELECT * FROM vehicles WHERE ',' || operator || ',' LIKE ?",
      ['%,$noc,%'],
    );

    return rows.map((row) => Vehicle.buildFromMap(row)).toList();
  }

  // ----- API Functions -----
  static Future<List<Vehicle>> getAllApi(
    VehicleQuery query,
    int offset, {
    bool refresh = false,
    bool fetchAll = false,
  }) async {
    return await ApiHasFetched.fullNew(
      ApiHasFetchedName.vehicleQuery,
      "vehicle_query_${query.toMap().toString()}",
      () async => (await Vehicle.getAll()),
      Vehicle.buildFromMap,
      "vehicles",
      offset,
      query: query.toMap(),
      insertInto: TableKey.vehicle,
      refresh: refresh,
      getAll: fetchAll,
    );
  }

  // Future<List<VehicleTrip>> getTrips(
  //   VehicleTripQuery query, {
  //   bool refresh = false,
  // }) async {
  //   query.vehicle = id;
  //   return await ApiManager.getAllPaginated(
  //     ApiOptions(
  //       endpoint: 'trips',
  //       fromMap: VehicleTrip.buildFromMap,
  //       query: {...query.toMap(), 'limit': '1000'},
  //     ),
  //   );
  // }
}
